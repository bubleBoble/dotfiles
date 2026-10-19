import argparse
import logging
import runpy
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = runpy.run_path(str(ROOT / "install"))


class TestInstaller:
    @pytest.fixture(autouse=True)
    def installer_environment(self, tmp_path, monkeypatch):
        self.scratch = tmp_path.resolve()
        self.home = self.scratch / "home"
        self.home.mkdir()
        self.appdata = self.scratch / "AppData/Roaming"
        monkeypatch.setenv("HOME", str(self.home))
        monkeypatch.setenv("USERPROFILE", str(self.home))
        monkeypatch.setenv("APPDATA", str(self.appdata))
        config_name = "config_windows.conf" if INSTALLER["IS_WINDOWS"] else "config_linux.conf"
        self.links = INSTALLER["parse_config"](ROOT / config_name)
        self.parser = argparse.ArgumentParser()
        # Any installation/removal in these tests must stay in the test home.
        for _, _, target in self.links:
            assert target.is_relative_to(self.home) or target.is_relative_to(self.appdata)

    def select(self, *tools):
        return INSTALLER["select_tools"](self.links, list(tools), self.parser)

    def cli(self, action, *tools):
        return subprocess.run(
            [sys.executable, "-B", str(ROOT / "install"), action, *tools],
            cwd=self.scratch,
            capture_output=True,
            text=True,
            input="",
        )

    @pytest.fixture
    def windows_install(self, monkeypatch):
        repo = self.scratch / "repo"
        source = repo / "settings"
        source.mkdir(parents=True)
        (source / "config.json").write_text("repository config", encoding="utf-8")
        (source / "nested").mkdir()
        (source / "nested/theme.json").write_text("repository theme", encoding="utf-8")
        (source / "new.json").write_text("new config", encoding="utf-8")
        (repo / "config_windows.conf").write_text(
            "[selected]\n./settings:$HOME/settings\n[other]\n./settings/config.json:$HOME/other.json\n",
            encoding="utf-8",
        )
        target = self.home / "settings"
        target.mkdir()
        (target / "config.json").write_text("installed config", encoding="utf-8")
        (target / "nested").mkdir()
        (target / "nested/theme.json").write_text("installed theme", encoding="utf-8")
        (target / "local.json").write_text("local only", encoding="utf-8")
        other = self.home / "other.json"
        other.write_text("other tool", encoding="utf-8")
        globals_ = INSTALLER["main"].__globals__
        monkeypatch.setitem(globals_, "IS_WINDOWS", True)
        monkeypatch.setitem(globals_, "__file__", str(repo / "install"))
        monkeypatch.setattr(sys, "argv", ["install", "install", "selected"])
        return source, target, other

    def test_windows_install_confirms_listed_overwrites_before_writing(
        self, windows_install, monkeypatch, capsys
    ):
        source, target, other = windows_install

        def confirm(prompt):
            listed = capsys.readouterr().out
            assert str(target / "config.json") in listed
            assert str(target / "nested/theme.json") in listed
            assert str(target / "local.json") not in listed
            assert str(other) not in listed
            assert (target / "config.json").read_text() == "installed config"
            assert not (target / "new.json").exists()
            return " YES "

        monkeypatch.setattr("builtins.input", confirm)
        INSTALLER["main"]()

        for name in ("config.json", "nested/theme.json", "new.json"):
            assert (target / name).read_bytes() == (source / name).read_bytes()
            assert not (target / name).is_symlink()
        assert (target / "local.json").read_text() == "local only"
        assert other.read_text() == "other tool"

    @pytest.mark.parametrize("answer", ["", "n", "anything", None])
    def test_windows_install_without_confirmation_changes_nothing(
        self, windows_install, monkeypatch, answer
    ):
        _, target, other = windows_install

        def decline(prompt):
            if answer is None:
                raise EOFError
            return answer

        monkeypatch.setattr("builtins.input", decline)
        INSTALLER["main"]()

        assert (target / "config.json").read_text() == "installed config"
        assert (target / "nested/theme.json").read_text() == "installed theme"
        assert (target / "local.json").read_text() == "local only"
        assert not (target / "new.json").exists()
        assert other.read_text() == "other tool"

    def test_windows_fresh_install_copies_without_prompt(self, windows_install, monkeypatch):
        source, _, other = windows_install
        monkeypatch.setattr(sys, "argv", ["install", "install", "other"])
        other.unlink()
        INSTALLER["main"]()
        assert other.read_bytes() == (source / "config.json").read_bytes()
        assert not other.is_symlink()

    @pytest.mark.parametrize("source_is_directory", [False, True])
    def test_windows_install_replaces_conflicting_destination_type(
        self, windows_install, monkeypatch, capsys, source_is_directory
    ):
        source = self.scratch / "source"
        target = self.home / "conflicting"
        if source_is_directory:
            source.mkdir()
            (source / "config").write_text("repository config", encoding="utf-8")
            target.write_text("old file", encoding="utf-8")
        else:
            source.write_text("repository config", encoding="utf-8")
            target.mkdir()
            (target / "old-config").write_text("old config", encoding="utf-8")

        def confirm(prompt):
            listed = capsys.readouterr().out
            assert str(target) in listed
            if not source_is_directory:
                assert str(target / "old-config") in listed
                assert (target / "old-config").read_text() == "old config"
            return "y"

        monkeypatch.setattr("builtins.input", confirm)
        INSTALLER["install_config"]([(source, target)])

        installed = target / "config" if source_is_directory else target
        assert installed.read_text() == "repository config"
        assert not (target / "old-config").exists()

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Creating symlinks needs Windows privileges")
    def test_windows_copy_replaces_symlink_without_changing_its_referent(
        self, windows_install, monkeypatch
    ):
        source, target, _ = windows_install
        external = self.home / "external"
        external.mkdir()
        (external / "theme.json").write_text("external config", encoding="utf-8")
        (target / "nested/theme.json").unlink()
        (target / "nested").rmdir()
        (target / "nested").symlink_to(external, target_is_directory=True)
        monkeypatch.setattr("builtins.input", lambda prompt: "y")

        INSTALLER["main"]()

        assert not (target / "nested").is_symlink()
        assert (target / "nested/theme.json").read_bytes() == (source / "nested/theme.json").read_bytes()
        assert (external / "theme.json").read_text() == "external config"

    def test_directory_wildcards_exclude_files_but_regular_wildcards_keep_them(self):
        source = self.scratch / "skills"
        skill = source / "example"
        skill.mkdir(parents=True)
        (skill / "SKILL.md").write_text("Example skill", encoding="utf-8")
        readme = source / "README.md"
        readme.write_text("Category documentation", encoding="utf-8")
        config = self.scratch / "config_linux.conf"
        config.write_text(
            f"[skills]\n./skills/*/:{self.home}/directories/*\n./skills/*:{self.home}/all/*\n",
            encoding="utf-8",
        )

        assert set(INSTALLER["parse_config"](config)) == {
            ("skills", skill, self.home / "directories/example"),
            ("skills", skill, self.home / "all/example"),
            ("skills", readme, self.home / "all/README.md"),
        }

    def test_agent_selection_includes_only_its_destination(self):
        for tool in ("agents", "claude", "codex", "dsh", "omp", "pi"):
            selected = self.select(tool)
            assert selected
            assert set(selected) == {
                (src, tgt)
                for owner, src, tgt in self.links
                if tgt.is_relative_to(self.home / f".{tool}") or (tool == "dsh" and owner == "dsh")
            }
        assert (
            (ROOT / "agents/shared/AGENTS.md").resolve(),
            self.home / ".dsh/AGENTS.md",
        ) in self.select("dsh")
        for tool in ("claude", "codex", "dsh", "omp", "pi"):
            assert any("skills" in target.parts for _, target in self.select(tool))

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Desktop launcher is Linux-specific")
    def test_dsh_selection_includes_desktop_integration(self):
        selected = set(self.select("dsh"))
        for name, destination in (
            ("dsh-desktop", ".local/bin/dsh-desktop"),
            ("dsh-desktop.desktop", ".local/share/applications/dsh-desktop.desktop"),
            ("dsh-desktop.svg", ".local/share/icons/hicolor/scalable/apps/dsh-desktop.svg"),
        ):
            assert (
                (ROOT / "agents/dsh/linux_desktop_app" / name).resolve(),
                self.home / destination,
            ) in selected
        assert not any(
            src.parent == ROOT / "agents/dsh/linux_desktop_app" for src, _ in self.select("claude")
        )

    def test_dsh_profile_maps_only_portable_files(self):
        profile = self.home / ".dsh/profiles/web"
        names = {"cordis.yml", "cordis.patch.yml", "package.json", "pnpm-workspace.yaml"}
        assert {
            (src, target)
            for src, target in self.select("dsh")
            if target.is_relative_to(self.home / ".dsh/profiles")
        } == {((ROOT / "agents/dsh/profiles/web" / name).resolve(), profile / name) for name in names}
        assert not any(target == self.home / ".dsh" for _, target in self.select("dsh"))

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Symlink behavior is Linux-specific")
    def test_dsh_installs_background_theme_directory(self):
        source = ROOT / "agents/dsh/any-background"
        target = self.home / ".dsh/.dsh-any-background-data"
        assert (source.resolve(), target) in self.select("dsh")
        result = self.cli("install", "dsh")
        assert result.returncode == 0, result.stderr
        assert target.is_symlink()
        assert target.resolve() == source.resolve()
        assert (target / "theme-config.json").read_bytes() == (source / "theme-config.json").read_bytes()

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Existing targets are preserved on Linux")
    def test_dsh_preserves_existing_background_theme(self):
        target = self.home / ".dsh/.dsh-any-background-data"
        target.mkdir(parents=True)
        theme = target / "theme-config.json"
        theme.write_text("{}", encoding="utf-8")
        result = self.cli("install", "dsh")
        assert result.returncode == 0, result.stderr
        assert not target.is_symlink()
        assert theme.read_text(encoding="utf-8") == "{}"

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Existing targets are preserved on Linux")
    def test_dsh_install_preserves_existing_profile(self):
        profile = self.home / ".dsh/profiles/web"
        profile.mkdir(parents=True)
        target = profile / "cordis.patch.yml"
        target.write_text("[]\n", encoding="utf-8")
        result = self.cli("install", "dsh")
        assert result.returncode == 0, result.stderr
        assert not target.is_symlink()
        assert target.read_text(encoding="utf-8") == "[]\n"
        assert "dsh plugin --profile web install" in result.stdout

    def test_multiple_tools_and_default_all(self):
        assert set(self.select("claude", "codex", "dsh", "claude")) == set(
            self.select("claude") + self.select("codex") + self.select("dsh")
        )
        assert self.select() == [(src, tgt) for _, src, tgt in self.links]

    def test_unknown_tool_fails_without_writes(self):
        result = self.cli("install", "not-a-tool")
        assert result.returncode == 2
        assert list(self.home.iterdir()) == []

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Symlink behavior is Linux-specific")
    def test_cli_install_and_remove_per_tool(self):
        for tool in ("claude", "codex", "dsh", "vim", "zed", "agents"):
            result = self.cli("install", tool)
            assert result.returncode == 0, result.stderr
            selected = self.select(tool)
            for src, target in selected:
                assert target.is_symlink(), str(target)
                assert target.resolve() == src
            for other, _, target in self.links:
                if other != tool:
                    assert not target.is_symlink(), str(target)
            result = self.cli("remove", tool)
            assert result.returncode == 0, result.stderr
            for _, target in selected:
                assert not target.exists(), str(target)
                assert not target.is_symlink(), str(target)

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Symlink behavior is Linux-specific")
    def test_removing_one_agent_preserves_another(self):
        result = self.cli("install", "claude", "dsh")
        assert result.returncode == 0, result.stderr
        result = self.cli("remove", "dsh")
        assert result.returncode == 0, result.stderr
        for _, target in self.select("claude"):
            assert target.is_symlink()
        for _, target in self.select("dsh"):
            assert not target.is_symlink()

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Existing targets are preserved on Linux")
    def test_install_preserves_existing_files(self):
        target = self.home / ".dsh/AGENTS.md"
        target.parent.mkdir()
        target.write_text("keep me", encoding="utf-8")
        result = self.cli("install", "dsh")
        assert result.returncode == 0, result.stderr
        assert not target.is_symlink()
        assert target.read_text(encoding="utf-8") == "keep me"

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Symlink behavior is Linux-specific")
    def test_remove_preserves_regular_files_unless_requested(self):
        target = self.home / ".vim/vimrc"
        target.parent.mkdir()
        target.write_text("keep me", encoding="utf-8")

        result = self.cli("remove", "vim")
        assert result.returncode == 0, result.stderr
        assert target.read_text(encoding="utf-8") == "keep me"

        result = self.cli("remove", "--include-files", "vim")
        assert result.returncode == 0, result.stderr
        assert not target.exists()

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
            assert source.is_relative_to(self.scratch)
            assert target.is_relative_to(self.home)
            source.write_text("old", encoding="utf-8")
            target.parent.mkdir(parents=True)
            target.write_text("new", encoding="utf-8")
        selected = INSTALLER["select_tools"](links, ["dsh"], self.parser)
        INSTALLER["sync_back"](selected, include_files=True)
        assert (repo / "agents/shared/dsh.txt").read_text() == "new"
        assert (repo / "agents/shared/claude.txt").read_text() == "old"

    def test_sync_back_directories_require_include_files(self):
        source = self.scratch / "repo/settings"
        source.mkdir(parents=True)
        (source / "config.txt").write_text("repository version", encoding="utf-8")
        (source / "keep.txt").write_text("repository only", encoding="utf-8")
        target = self.home / "settings"
        target.mkdir()
        (target / "config.txt").write_text("installed edits", encoding="utf-8")
        missing_source = self.scratch / "repo/new-settings"
        new_target = self.home / "new-settings"
        new_target.mkdir()
        (new_target / "config.txt").write_text("new configuration", encoding="utf-8")
        links = [(source, target), (missing_source, new_target)]

        INSTALLER["sync_back"](links, include_files=False)
        assert (source / "config.txt").read_text() == "repository version"
        assert (source / "keep.txt").read_text() == "repository only"
        assert not missing_source.exists()

        INSTALLER["sync_back"](links, include_files=True)
        assert (source / "config.txt").read_text() == "installed edits"
        assert not (source / "keep.txt").exists()
        assert (missing_source / "config.txt").read_text() == "new configuration"

    @pytest.mark.skipif(INSTALLER["IS_WINDOWS"], reason="Symlink behavior is Linux-specific")
    def test_sync_back_never_replaces_symlink_targets(self):
        source = self.scratch / "config.txt"
        source.write_text("repository version", encoding="utf-8")
        target = self.home / "config.txt"
        target.symlink_to(source)

        INSTALLER["sync_back"]([(source, target)], include_files=True)
        assert source.read_text() == "repository version"
        assert target.is_symlink()
        assert target.resolve() == source

    def test_sections_control_selection_independent_of_paths(self, monkeypatch):
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
        with monkeypatch.context() as patcher:
            patcher.setitem(globals_, "__file__", str(repo / "install"))
            patcher.setattr(sys, "argv", ["install", "install", "alpha"])
            INSTALLER["main"]()
            for target, content in alpha_targets:
                assert target.read_text(encoding="utf-8") == content
            assert not beta_target.exists()

            patcher.setattr(sys, "argv", ["install", "install", "beta"])
            INSTALLER["main"]()
            patcher.setattr(sys, "argv", ["install", "remove", "alpha"])
            INSTALLER["main"]()
            for target, _ in alpha_targets:
                assert not target.exists()
            assert beta_target.read_text(encoding="utf-8") == "first configuration"

    def test_windows_rejects_linux_only_tools(self):
        links = INSTALLER["parse_config"](ROOT / "config_windows.conf")
        for tool in ("tmux", "zsh"):
            with pytest.raises(SystemExit) as error:
                INSTALLER["select_tools"](links, [tool], self.parser)
            assert error.value.code == 2
        assert all(
            target.is_relative_to(self.home / ".dsh")
            for _, target in INSTALLER["select_tools"](links, ["dsh"], self.parser)
        )

    def test_invalid_sections_abort_before_installing_anything(self, monkeypatch, caplog):
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
            caplog.clear()
            (repo / "config_linux.conf").write_text(config, encoding="utf-8")
            with monkeypatch.context() as patcher:
                patcher.setitem(globals_, "IS_WINDOWS", False)
                patcher.setitem(globals_, "__file__", str(repo / "install"))
                patcher.setattr(sys, "argv", ["install", "install"])
                with caplog.at_level(logging.ERROR, logger="dotfiles"), pytest.raises(SystemExit) as error:
                    INSTALLER["main"]()
            assert error.value.code == 1
            assert any(
                record.name == "dotfiles" and record.levelno >= logging.ERROR for record in caplog.records
            )
            assert not (self.home / "valid").exists()

    def test_invalid_targets_abort_before_installing_anything(self, monkeypatch, caplog):
        repo = self.scratch / "repo"
        repo.mkdir()
        (repo / "source").write_text("config", encoding="utf-8")
        globals_ = INSTALLER["main"].__globals__
        monkeypatch.delenv("DOTFILES_UNDEFINED", raising=False)
        for target in (
            "$DOTFILES_UNDEFINED/config",
            "${DOTFILES_UNDEFINED}/config",
            "%DOTFILES_UNDEFINED%/config",
            "relative/config",
        ):
            caplog.clear()
            (repo / "config_linux.conf").write_text(
                f"[tool]\n./source:$HOME/valid\n./source:{target}\n",
                encoding="utf-8",
            )
            with monkeypatch.context() as patcher:
                patcher.setitem(globals_, "IS_WINDOWS", False)
                patcher.setitem(globals_, "__file__", str(repo / "install"))
                patcher.setattr(sys, "argv", ["install", "install"])
                with caplog.at_level(logging.ERROR, logger="dotfiles"), pytest.raises(SystemExit) as error:
                    INSTALLER["main"]()
            assert error.value.code == 1
            assert any(
                record.name == "dotfiles" and record.levelno >= logging.ERROR for record in caplog.records
            )
            assert not (self.home / "valid").exists()

    def test_windows_manifest_is_used_for_install_sync_back_and_remove(self, monkeypatch):
        repo = self.scratch / "repo"
        (repo / "zed").mkdir(parents=True)
        source = repo / "zed/settings.json"
        source.write_text('{"theme": "original"}', encoding="utf-8")
        (repo / "config_windows.conf").write_text(
            "[zed]\n./zed/settings.json:$APPDATA/zed/settings.json\n",
            encoding="utf-8",
        )
        (repo / "config_linux.conf").write_text(
            "[zed]\n./zed/settings.json:$HOME/.config/zed/settings.json\n",
            encoding="utf-8",
        )
        target = self.appdata / "zed/settings.json"
        globals_ = INSTALLER["main"].__globals__
        with monkeypatch.context() as patcher:
            patcher.setitem(globals_, "IS_WINDOWS", True)
            patcher.setitem(globals_, "__file__", str(repo / "install"))
            patcher.setattr(sys, "argv", ["install", "install"])
            INSTALLER["main"]()
            assert not target.is_symlink()
            assert target.read_text(encoding="utf-8") == '{"theme": "original"}'
            target.write_text('{"theme": "edited"}', encoding="utf-8")
            assert source.read_text(encoding="utf-8") == '{"theme": "original"}'
            patcher.setattr(sys, "argv", ["install", "sync-back", "zed"])
            INSTALLER["main"]()
            assert source.read_text(encoding="utf-8") == '{"theme": "original"}'
            assert target.read_text(encoding="utf-8") == '{"theme": "edited"}'
            patcher.setattr(
                sys,
                "argv",
                ["install", "sync-back", "--include-files", "zed"],
            )
            INSTALLER["main"]()
            assert source.read_text(encoding="utf-8") == '{"theme": "edited"}'
            patcher.setattr(sys, "argv", ["install", "remove", "zed"])
            INSTALLER["main"]()
            assert not target.exists()
            assert target.with_name("settings.json.old").read_text(encoding="utf-8") == '{"theme": "edited"}'
        assert not (self.home / ".config/zed").exists()
