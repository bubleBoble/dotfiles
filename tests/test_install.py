import argparse
import contextlib
import io
import os
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
INSTALLER = runpy.run_path(str(ROOT / "install"))


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-install-test-")
        self.addCleanup(self.temp.cleanup)
        self.scratch = Path(self.temp.name).resolve()
        self.home = self.scratch / "home"
        self.home.mkdir()
        self.appdata = self.scratch / "AppData/Roaming"
        self.env = patch.dict(os.environ, {
            "HOME": str(self.home),
            "USERPROFILE": str(self.home),
            "APPDATA": str(self.appdata),
        })
        self.env.start()
        self.addCleanup(self.env.stop)
        config_name = "config_windows.conf" if INSTALLER["IS_WINDOWS"] else "config_linux.conf"
        self.links = INSTALLER["parse_config"](ROOT / config_name)
        self.parser = argparse.ArgumentParser()
        # Any installation/removal in these tests must stay in the test home.
        for _, _, target in self.links:
            self.assertTrue(
                target.is_relative_to(self.home) or target.is_relative_to(self.appdata)
            )

    def select(self, *tools):
        return INSTALLER["select_tools"](self.links, list(tools), self.parser)

    def cli(self, action, *tools):
        return subprocess.run(
            [sys.executable, "-B", str(ROOT / "install"), action, *tools],
            cwd=self.scratch,
            capture_output=True,
            text=True,
        )

    def test_directory_wildcards_exclude_files_but_regular_wildcards_keep_them(self):
        source = self.scratch / "skills"
        skill = source / "example"
        skill.mkdir(parents=True)
        (skill / "SKILL.md").write_text("Example skill", encoding="utf-8")
        readme = source / "README.md"
        readme.write_text("Category documentation", encoding="utf-8")
        config = self.scratch / "config_linux.conf"
        config.write_text(
            "[skills]\n"
            f"./skills/*/:{self.home}/directories/*\n"
            f"./skills/*:{self.home}/all/*\n",
            encoding="utf-8",
        )

        self.assertEqual(
            set(INSTALLER["parse_config"](config)),
            {
                ("skills", skill, self.home / "directories/example"),
                ("skills", skill, self.home / "all/example"),
                ("skills", readme, self.home / "all/README.md"),
            },
        )

    def test_agent_selection_includes_only_its_destination(self):
        for tool in ("agents", "claude", "codex", "dsh", "omp", "pi"):
            with self.subTest(tool=tool):
                selected = self.select(tool)
                self.assertTrue(selected)
                self.assertEqual(
                    set(selected),
                    {(src, tgt) for owner, src, tgt in self.links
                     if tgt.is_relative_to(self.home / f".{tool}")
                     or (tool == "dsh" and owner == "dsh")},
                )
        self.assertIn(
            ((ROOT / "agents/shared/AGENTS.md").resolve(), self.home / ".dsh/AGENTS.md"),
            self.select("dsh"),
        )
        for tool in ("claude", "codex", "dsh", "omp", "pi"):
            self.assertTrue(any("skills" in target.parts for _, target in self.select(tool)))

    @unittest.skipIf(INSTALLER["IS_WINDOWS"], "Desktop launcher is Linux-specific")
    def test_dsh_selection_includes_desktop_integration(self):
        selected = set(self.select("dsh"))
        for name, destination in (
            ("dsh-desktop", ".local/bin/dsh-desktop"),
            ("dsh-desktop.desktop", ".local/share/applications/dsh-desktop.desktop"),
            ("dsh-desktop.svg", ".local/share/icons/hicolor/scalable/apps/dsh-desktop.svg"),
        ):
            self.assertIn(((ROOT / "agents/dsh/linux_desktop_app" / name).resolve(), self.home / destination), selected)
        self.assertFalse(any(src.parent == ROOT / "agents/dsh/linux_desktop_app" for src, _ in self.select("claude")))

    def test_dsh_profile_maps_only_portable_files(self):
        profile = self.home / ".dsh/profiles/web"
        names = {"cordis.yml", "cordis.patch.yml", "package.json", "pnpm-workspace.yaml"}
        self.assertEqual(
            {(src, target) for src, target in self.select("dsh")
             if target.is_relative_to(self.home / ".dsh/profiles")},
            {((ROOT / "agents/dsh/profiles/web" / name).resolve(), profile / name)
             for name in names},
        )
        self.assertFalse(any(target == self.home / ".dsh" for _, target in self.select("dsh")))

    @unittest.skipIf(INSTALLER["IS_WINDOWS"], "Symlink behavior is Linux-specific")
    def test_dsh_installs_background_theme_directory(self):
        source = ROOT / "agents/dsh/any-background"
        target = self.home / ".dsh/.dsh-any-background-data"
        self.assertIn((source.resolve(), target), self.select("dsh"))
        result = self.cli("--install", "dsh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(target.is_symlink())
        self.assertEqual(target.resolve(), source.resolve())
        self.assertEqual(
            (target / "theme-config.json").read_bytes(),
            (source / "theme-config.json").read_bytes(),
        )

    def test_dsh_preserves_existing_background_theme(self):
        target = self.home / ".dsh/.dsh-any-background-data"
        target.mkdir(parents=True)
        theme = target / "theme-config.json"
        theme.write_text("{}", encoding="utf-8")
        result = self.cli("--install", "dsh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(target.is_symlink())
        self.assertEqual(theme.read_text(encoding="utf-8"), "{}")

    def test_dsh_install_preserves_existing_profile(self):
        profile = self.home / ".dsh/profiles/web"
        profile.mkdir(parents=True)
        target = profile / "cordis.patch.yml"
        target.write_text("[]\n", encoding="utf-8")
        result = self.cli("--install", "dsh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(target.is_symlink())
        self.assertEqual(target.read_text(encoding="utf-8"), "[]\n")
        self.assertIn("dsh plugin --profile web install", result.stdout)

    def test_multiple_tools_and_default_all(self):
        self.assertEqual(
            set(self.select("claude", "codex", "dsh", "claude")),
            set(self.select("claude") + self.select("codex") + self.select("dsh")),
        )
        self.assertEqual(self.select(), [(src, tgt) for _, src, tgt in self.links])

    def test_unknown_tool_fails_without_writes(self):
        result = self.cli("--install", "not-a-tool")
        self.assertEqual(result.returncode, 2)
        self.assertEqual(list(self.home.iterdir()), [])

    @unittest.skipIf(INSTALLER["IS_WINDOWS"], "Symlink behavior is Linux-specific")
    def test_cli_install_and_remove_per_tool(self):
        for tool in ("claude", "codex", "dsh", "vim", "zed", "agents"):
            with self.subTest(tool=tool):
                result = self.cli("--install", tool)
                self.assertEqual(result.returncode, 0, result.stderr)
                selected = self.select(tool)
                for src, target in selected:
                    self.assertTrue(target.is_symlink(), str(target))
                    self.assertEqual(target.resolve(), src)
                for other, _, target in self.links:
                    if other != tool:
                        self.assertFalse(target.is_symlink(), str(target))
                result = self.cli("--remove", tool)
                self.assertEqual(result.returncode, 0, result.stderr)
                for _, target in selected:
                    self.assertFalse(target.exists(), str(target))
                    self.assertFalse(target.is_symlink(), str(target))

    @unittest.skipIf(INSTALLER["IS_WINDOWS"], "Symlink behavior is Linux-specific")
    def test_removing_one_agent_preserves_another(self):
        result = self.cli("--install", "claude", "dsh")
        self.assertEqual(result.returncode, 0, result.stderr)
        result = self.cli("--remove", "dsh")
        self.assertEqual(result.returncode, 0, result.stderr)
        for _, target in self.select("claude"):
            self.assertTrue(target.is_symlink())
        for _, target in self.select("dsh"):
            self.assertFalse(target.is_symlink())

    def test_install_preserves_existing_files(self):
        target = self.home / ".dsh/AGENTS.md"
        target.parent.mkdir()
        target.write_text("keep me", encoding="utf-8")
        result = self.cli("--install", "dsh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(target.is_symlink())
        self.assertEqual(target.read_text(encoding="utf-8"), "keep me")

    def test_sync_back_is_scoped_to_selected_agent(self):
        repo = self.scratch / "repo"
        (repo / "agents/shared").mkdir(parents=True)
        config = repo / "config_linux.conf"
        config.write_text(
            "[claude]\n"
            "./agents/shared/claude.txt:$HOME/.claude/config.txt\n"
            "[dsh]\n"
            "./agents/shared/dsh.txt:$HOME/.dsh/config.txt\n",
            encoding="utf-8",
        )
        links = INSTALLER["parse_config"](config)
        for _, source, target in links:
            self.assertTrue(source.is_relative_to(self.scratch))
            self.assertTrue(target.is_relative_to(self.home))
            source.write_text("old", encoding="utf-8")
            target.parent.mkdir(parents=True)
            target.write_text("new", encoding="utf-8")
        selected = INSTALLER["select_tools"](links, ["dsh"], self.parser)
        with contextlib.redirect_stdout(io.StringIO()):
            INSTALLER["sync_back"](selected)
        self.assertEqual((repo / "agents/shared/dsh.txt").read_text(), "new")
        self.assertEqual((repo / "agents/shared/claude.txt").read_text(), "old")

    def test_sections_control_selection_independent_of_paths(self):
        repo = self.scratch / "repo"
        assets = repo / "assets"
        assets.mkdir(parents=True)
        (assets / "first").write_text("first configuration", encoding="utf-8")
        (assets / "second").write_text("second configuration", encoding="utf-8")
        config_name = "config_windows.conf" if INSTALLER["IS_WINDOWS"] else "config_linux.conf"
        (repo / config_name).write_text(
            "# Ownership does not follow source or destination names.\n"
            "[alpha]\n"
            "./assets/*:$HOME/.local/bin/*\n"
            "\n"
            "[beta]\n"
            "./assets/first:$APPDATA/alpha/config\n"
            "[alpha]\n"
            "./assets/first:$HOME/.config/beta/config\n",
            encoding="utf-8",
        )
        alpha_targets = (
            (self.home / ".local/bin/first", "first configuration"),
            (self.home / ".local/bin/second", "second configuration"),
            (self.home / ".config/beta/config", "first configuration"),
        )
        beta_target = self.appdata / "alpha/config"
        globals_ = INSTALLER["main"].__globals__
        with patch.dict(globals_, {"__file__": str(repo / "install")}), \
             contextlib.redirect_stdout(io.StringIO()):
            with patch.object(sys, "argv", ["install", "--install", "alpha"]):
                INSTALLER["main"]()
            for target, content in alpha_targets:
                self.assertEqual(target.read_text(encoding="utf-8"), content)
            self.assertFalse(beta_target.exists())

            with patch.object(sys, "argv", ["install", "--install", "beta"]):
                INSTALLER["main"]()
            with patch.object(sys, "argv", ["install", "--remove", "alpha"]):
                INSTALLER["main"]()
            for target, _ in alpha_targets:
                self.assertFalse(target.exists())
            self.assertEqual(beta_target.read_text(encoding="utf-8"), "first configuration")

    def test_windows_rejects_linux_only_tools(self):
        links = INSTALLER["parse_config"](ROOT / "config_windows.conf")
        for tool in ("tmux", "zsh"):
            with self.subTest(tool=tool), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as error:
                    INSTALLER["select_tools"](links, [tool], self.parser)
                self.assertEqual(error.exception.code, 2)
        self.assertTrue(all(
            target.is_relative_to(self.home / ".dsh")
            for _, target in INSTALLER["select_tools"](links, ["dsh"], self.parser)
        ))

    def test_invalid_sections_abort_before_installing_anything(self):
        repo = self.scratch / "repo"
        repo.mkdir()
        (repo / "source").write_text("config", encoding="utf-8")
        globals_ = INSTALLER["main"].__globals__
        for config in (
            "./source:$HOME/valid\n",
            "[tool]\n./source:$HOME/valid\n[]\n",
            "[tool]\n./source:$HOME/valid\n[broken\n",
            "[tool]\n./source:$HOME/valid\n[two tools]\n",
        ):
            with self.subTest(config=config):
                (repo / "config_linux.conf").write_text(config, encoding="utf-8")
                with patch.dict(globals_, {"IS_WINDOWS": False, "__file__": str(repo / "install")}), \
                     patch.object(sys, "argv", ["install", "--install"]), \
                     self.assertLogs("dotfiles", level="ERROR"):
                    with self.assertRaises(SystemExit) as error:
                        INSTALLER["main"]()
                self.assertEqual(error.exception.code, 1)
                self.assertFalse((self.home / "valid").exists())

    def test_invalid_targets_abort_before_installing_anything(self):
        repo = self.scratch / "repo"
        repo.mkdir()
        (repo / "source").write_text("config", encoding="utf-8")
        globals_ = INSTALLER["main"].__globals__
        for target in (
            "$DOTFILES_UNDEFINED/config",
            "${DOTFILES_UNDEFINED}/config",
            "%DOTFILES_UNDEFINED%/config",
            "relative/config",
        ):
            with self.subTest(target=target), patch.dict(os.environ):
                os.environ.pop("DOTFILES_UNDEFINED", None)
                (repo / "config_linux.conf").write_text(
                    "[tool]\n"
                    "./source:$HOME/valid\n"
                    f"./source:{target}\n",
                    encoding="utf-8",
                )
                with patch.dict(globals_, {"IS_WINDOWS": False, "__file__": str(repo / "install")}), \
                     patch.object(sys, "argv", ["install", "--install"]), \
                     self.assertLogs("dotfiles", level="ERROR"):
                    with self.assertRaises(SystemExit) as error:
                        INSTALLER["main"]()
                self.assertEqual(error.exception.code, 1)
                self.assertFalse((self.home / "valid").exists())

    def test_windows_manifest_is_used_for_install_sync_back_and_remove(self):
        repo = self.scratch / "repo"
        (repo / "zed").mkdir(parents=True)
        source = repo / "zed/settings.json"
        source.write_text('{"theme": "original"}', encoding="utf-8")
        (repo / "config_windows.conf").write_text(
            "[zed]\n"
            "./zed/settings.json:$APPDATA/zed/settings.json\n",
            encoding="utf-8",
        )
        (repo / "config_linux.conf").write_text(
            "[zed]\n"
            "./zed/settings.json:$HOME/.config/zed/settings.json\n",
            encoding="utf-8",
        )
        target = self.appdata / "zed/settings.json"
        globals_ = INSTALLER["main"].__globals__
        with patch.dict(globals_, {"IS_WINDOWS": True, "__file__": str(repo / "install")}), \
             contextlib.redirect_stdout(io.StringIO()):
            with patch.object(sys, "argv", ["install", "--install"]):
                INSTALLER["main"]()
            self.assertFalse(target.is_symlink())
            self.assertEqual(target.read_text(encoding="utf-8"), '{"theme": "original"}')
            target.write_text('{"theme": "edited"}', encoding="utf-8")
            self.assertEqual(source.read_text(encoding="utf-8"), '{"theme": "original"}')
            with patch.object(sys, "argv", ["install", "--sync-back", "zed"]):
                INSTALLER["main"]()
            self.assertEqual(source.read_text(encoding="utf-8"), '{"theme": "edited"}')
            with patch.object(sys, "argv", ["install", "--remove", "zed"]):
                INSTALLER["main"]()
            self.assertFalse(target.exists())
            self.assertEqual(
                target.with_name("settings.json.old").read_text(encoding="utf-8"),
                '{"theme": "edited"}',
            )
        self.assertFalse((self.home / ".config/zed").exists())


if __name__ == "__main__":
    unittest.main()
