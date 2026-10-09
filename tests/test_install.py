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
        self.env = patch.dict(os.environ, {"HOME": str(self.home)})
        self.env.start()
        self.addCleanup(self.env.stop)
        self.links = INSTALLER["parse_config"](ROOT / "config.conf")
        self.parser = argparse.ArgumentParser()
        # Any installation/removal in these tests must stay in the test home.
        for _, _, target in self.links:
            self.assertTrue(target.is_relative_to(self.home))

    def select(self, *tools):
        return INSTALLER["select_tools"](self.links, list(tools), self.parser)

    def cli(self, action, *tools):
        return subprocess.run(
            [sys.executable, "-B", str(ROOT / "install"), action, *tools],
            cwd=self.scratch,
            capture_output=True,
            text=True,
        )

    def test_available_tools(self):
        self.assertEqual(
            {tool for tool, _, _ in self.links},
            {"agents", "claude", "codex", "dsh", "gdb", "git", "herdr",
             "nvim", "omp", "pi", "tmux", "vim", "yazi", "zsh"},
        )

    def test_agent_selection_includes_only_its_destination(self):
        for tool in ("agents", "claude", "codex", "dsh", "omp", "pi"):
            with self.subTest(tool=tool):
                selected = self.select(tool)
                self.assertTrue(selected)
                self.assertEqual(
                    set(selected),
                    {(src, tgt) for _, src, tgt in self.links
                     if tgt.is_relative_to(self.home / f".{tool}")},
                )
        self.assertIn(
            ((ROOT / "agents/shared/AGENTS.md").resolve(), self.home / ".dsh/AGENTS.md"),
            self.select("dsh"),
        )
        for tool in ("claude", "codex", "dsh", "omp", "pi"):
            self.assertTrue(any("skills" in target.parts for _, target in self.select(tool)))

    def test_multiple_tools_and_default_all(self):
        self.assertEqual(
            set(self.select("claude", "codex", "dsh", "claude")),
            set(self.select("claude") + self.select("codex") + self.select("dsh")),
        )
        self.assertEqual(self.select(), [(src, tgt) for _, src, tgt in self.links])

    def test_unknown_tool_lists_individual_agents_without_writes(self):
        result = self.cli("--install", "not-a-tool")
        self.assertEqual(result.returncode, 2)
        for tool in ("claude", "codex", "dsh", "nvim", "vim"):
            self.assertIn(tool, result.stderr)
        self.assertEqual(list(self.home.iterdir()), [])

    @unittest.skipIf(INSTALLER["IS_WINDOWS"], "Symlink behavior is Linux-specific")
    def test_cli_install_and_remove_per_tool(self):
        for tool in ("nvim", "claude", "codex", "dsh", "vim"):
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
        config = repo / "config.conf"
        config.write_text(
            "./agents/shared/claude.txt:$HOME/.claude/config.txt\n"
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

    def test_agent_target_under_config_directory(self):
        config = self.scratch / "config.conf"
        config.write_text(
            "./agents/shared/config.json:$HOME/.config/example-agent/config.json\n",
            encoding="utf-8",
        )
        links = INSTALLER["parse_config"](config)
        self.assertEqual(links[0][0], "example-agent")


if __name__ == "__main__":
    unittest.main()
