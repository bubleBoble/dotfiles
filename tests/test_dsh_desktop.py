import os
import runpy
import signal
import stat
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock, call

import pytest

ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = ROOT / "agents/dsh/linux_desktop_app/dsh-desktop"
BASE_URL = "http://127.0.0.1:3080"
LAUNCH_URL = BASE_URL + "/?token=test-token_123"
BROWSER = "/mock/bin/google-chrome-stable"


class TestDesktopLauncher:
    @pytest.fixture(autouse=True)
    def launcher_context(self, tmp_path, monkeypatch):
        self.scratch = tmp_path
        self.home = self.scratch / "home"
        self.home.mkdir()
        self.state_home = self.scratch / "state"
        self.config_home = self.scratch / "config"
        for name in tuple(os.environ):
            monkeypatch.delenv(name)
        for name, value in {
            "HOME": str(self.home),
            "XDG_STATE_HOME": str(self.state_home),
            "XDG_CONFIG_HOME": str(self.config_home),
            "PATH": "/usr/bin:/bin",
        }.items():
            monkeypatch.setenv(name, value)

        # Importing the launcher must not import a GUI or start real I/O.
        with monkeypatch.context() as safety:
            safety.setitem(sys.modules, "gi", None)
            forbidden = Mock(side_effect=AssertionError("real I/O forbidden"))
            safety.setattr(subprocess, "Popen", forbidden)
            safety.setattr(subprocess, "run", forbidden)
            safety.setattr(os, "killpg", forbidden)
            safety.setattr(os, "kill", forbidden)
            safety.setattr(urllib.request.OpenerDirector, "open", forbidden)
            self.module = runpy.run_path(str(LAUNCHER))

        # run_path returns a copy; patch the dictionary the functions actually use.
        self.globals = self.module["main"].__globals__
        self.process = Mock(pid=424242)
        self.process.poll.return_value = None
        self.process.wait.return_value = 0
        self.browser_process = Mock(pid=434343)
        self.browser_process.poll.return_value = None
        self.browser_process.wait.return_value = 0
        self.popen = Mock(return_value=self.process)
        self.killpg = Mock()
        self.os = SimpleNamespace(**{name: getattr(os, name) for name in dir(os)})
        self.os.killpg = self.killpg
        self.os.kill = Mock(side_effect=AssertionError("individual process signals forbidden"))
        self.os.umask = Mock(return_value=0o022)
        self.shutil = SimpleNamespace(
            **{name: getattr(self.globals["shutil"], name) for name in dir(self.globals["shutil"])}
        )
        self.shutil.which = Mock(return_value=None)
        self.http = Mock()
        self.http.open.side_effect = AssertionError("real HTTP forbidden")
        self.status = Mock(return_value=None)
        self.browser = Mock(return_value=BROWSER)
        self.environment = Mock(return_value=("/mock/bin/dsh", {"PATH": "/mock/bin"}))
        self.start = Mock(return_value=(self.process, LAUNCH_URL))
        self.stop = Mock()
        self.window = Mock()
        self.clock = SimpleNamespace(monotonic=Mock(return_value=0), sleep=Mock())
        self.signals = SimpleNamespace(**{name: getattr(signal, name) for name in dir(signal)})
        self.signals.signal = Mock(return_value=signal.SIG_DFL)
        self.signals.getsignal = Mock(return_value=signal.SIG_DFL)
        self.group_exists = Mock(return_value=False)
        replacements = {
            "os": self.os,
            "shutil": self.shutil,
            "subprocess": SimpleNamespace(
                Popen=self.popen,
                DEVNULL=subprocess.DEVNULL,
                STDOUT=subprocess.STDOUT,
                TimeoutExpired=subprocess.TimeoutExpired,
                run=Mock(side_effect=AssertionError("external commands forbidden")),
            ),
            "HTTP": self.http,
            "time": self.clock,
            "signal": self.signals,
            "group_exists": self.group_exists,
            "browser_command": self.browser,
            "dsh_environment": self.environment,
            "status": self.status,
            "start_server": self.start,
            "stop_server": self.stop,
            "run_window": self.window,
        }
        for name, value in replacements.items():
            monkeypatch.setitem(self.globals, name, value)

        self.monkeypatch = monkeypatch
        yield

    def original(self, name):
        return self.module[name]

    def main(self, *args):
        return self.original("main")(list(args))

    def start_server(self):
        log = self.scratch / "server.log"
        with self.monkeypatch.context() as monkeypatch:
            monkeypatch.setitem(self.globals, "start_server", self.original("start_server"))
            return self.original("start_server")(log)

    def run_window(self):
        self.popen.return_value = self.browser_process
        return self.original("run_window")(
            LAUNCH_URL,
            self.scratch / "chrome",
            self.scratch / "browser.log",
        )

    def test_base_url_is_fixed_loopback(self):
        assert self.module["BASE_URL"] == BASE_URL

    def test_browser_command_prefers_chrome_stable(self):
        self.shutil.which.return_value = BROWSER
        assert self.original("browser_command")() == BROWSER
        self.shutil.which.assert_called_once_with("google-chrome-stable")

    def test_browser_command_falls_back_to_installed_chromium(self):
        self.shutil.which.side_effect = [None, None, "/mock/bin/chromium"]
        assert self.original("browser_command")() == "/mock/bin/chromium"
        assert self.shutil.which.call_args_list == [
            call("google-chrome-stable"),
            call("google-chrome"),
            call("chromium"),
        ]

    def test_missing_browser_raises_launcher_error_without_processes(self):
        with pytest.raises(self.module["LauncherError"]):
            self.original("browser_command")()
        assert self.shutil.which.call_args_list == [
            call("google-chrome-stable"),
            call("google-chrome"),
            call("chromium"),
            call("chromium-browser"),
        ]
        self.start.assert_not_called()
        self.popen.assert_not_called()
        self.killpg.assert_not_called()

    def test_status_returns_http_response_status(self):
        response = Mock(status=200)
        self.http.open.return_value.__enter__ = Mock(return_value=response)
        self.http.open.return_value.__exit__ = Mock(return_value=False)
        self.http.open.side_effect = None
        assert self.original("status")(BASE_URL) == 200
        self.http.open.assert_called_once_with(BASE_URL, timeout=2)

    def test_status_reports_http_errors_but_connection_errors_are_absent(self):
        for error, expected in (
            (urllib.error.HTTPError(BASE_URL, 401, "unauthorized", {}, None), 401),
            (urllib.error.URLError("not listening"), None),
            (OSError("connection refused"), None),
        ):
            try:
                self.http.open.side_effect = error
                assert self.original("status")(BASE_URL) == expected
            finally:
                if isinstance(error, urllib.error.HTTPError):
                    error.close()

    def test_logged_url_uses_latest_local_startup_url(self):
        log = self.scratch / "server.log"
        assert self.original("logged_url")(log) is None
        log.write_text(
            "dsh web: http://example.invalid/?token=ignored\n"
            "dsh web: http://127.0.0.1:3080/?token=old\n"
            "dsh web: " + LAUNCH_URL + "\n",
            encoding="utf-8",
        )
        assert self.original("logged_url")(log) == LAUNCH_URL

    def test_dsh_environment_keeps_selected_executable_bin_on_path(self):
        command = self.home / "node/bin/dsh"
        with self.monkeypatch.context() as monkeypatch:
            monkeypatch.setenv("DSH_DESKTOP_DSH", str(command))
            monkeypatch.setattr(self.os, "access", Mock(return_value=True))
            actual, environment = self.original("dsh_environment")()
        assert actual == str(command)
        assert environment["PATH"].split(os.pathsep)[0] == str(command.parent)
        assert str(self.home / ".local/bin") in environment["PATH"].split(os.pathsep)

    def test_dsh_environment_finds_newest_nvm_with_matching_node(self):
        nvm = self.home / ".nvm"
        for version in ("v20.1.0", "v26.11.1"):
            directory = nvm / "versions/node" / version / "bin"
            directory.mkdir(parents=True)
            command = directory / "dsh"
            command.write_text("fixture", encoding="utf-8")
            command.chmod(0o755)
            (directory / "node").write_text("fixture", encoding="utf-8")
        actual, environment = self.original("dsh_environment")()
        expected = nvm / "versions/node/v26.11.1/bin"
        assert actual == str(expected / "dsh")
        assert environment["PATH"].split(os.pathsep)[0] == str(expected)

    def test_check_does_not_start_window_server_or_write_state(self, capsys):
        self.status.return_value = 401
        assert self.main("--check") == 0
        self.browser.assert_called_once_with()
        self.environment.assert_called_once_with()
        assert BROWSER in capsys.readouterr().out
        self.start.assert_not_called()
        self.stop.assert_not_called()
        self.window.assert_not_called()
        self.popen.assert_not_called()
        self.killpg.assert_not_called()
        self.os.umask.assert_not_called()
        self.signals.signal.assert_not_called()
        assert not self.state_home.exists()
        assert not self.config_home.exists()
        assert list(self.home.iterdir()) == []

    def test_existing_external_server_is_never_adopted_or_stopped(self):
        for response in (200, 303, 401, 500):
            self.status.return_value = response
            with pytest.raises(self.module["LauncherError"]):
                self.main()
            self.start.assert_not_called()
            self.stop.assert_not_called()
            self.window.assert_not_called()
            self.popen.assert_not_called()
            self.killpg.assert_not_called()

    def test_missing_browser_fails_before_server_start(self):
        self.browser.side_effect = self.module["LauncherError"]("Chrome missing")
        with pytest.raises(self.module["LauncherError"]):
            self.main()
        self.start.assert_not_called()
        self.window.assert_not_called()
        self.stop.assert_not_called()

    def test_window_close_stops_owned_server_after_window_returns(self):
        events = []
        self.browser.side_effect = lambda: events.append("browser") or BROWSER
        self.start.side_effect = lambda log: events.append("start") or (self.process, LAUNCH_URL)
        self.window.side_effect = lambda url, profile, log: events.append("window")
        self.stop.side_effect = lambda process: events.append("stop")
        assert self.main() == 0
        assert events == ["browser", "start", "window", "stop"]
        self.stop.assert_called_once_with(self.process)
        self.window.assert_called_once_with(
            LAUNCH_URL,
            self.config_home / "dsh-desktop/chrome",
            self.state_home / "dsh-desktop/browser.log",
        )

    def test_window_failure_still_stops_owned_server(self):
        error = RuntimeError("window failed")
        self.window.side_effect = error
        with pytest.raises(RuntimeError) as caught:
            self.main()
        assert caught.value is error
        self.stop.assert_called_once_with(self.process)

    def test_window_keyboard_interrupt_still_stops_owned_server(self):
        self.window.side_effect = KeyboardInterrupt()
        with pytest.raises(KeyboardInterrupt):
            self.main()
        self.stop.assert_called_once_with(self.process)

    def test_main_restores_startup_and_browser_wait_signal_handlers(self):
        assert self.main() == 0
        interrupt = self.original("interrupt_startup")
        assert self.signals.signal.call_args_list == [
            call(signal.SIGINT, interrupt),
            call(signal.SIGTERM, interrupt),
            call(signal.SIGINT, signal.SIG_DFL),
            call(signal.SIGTERM, signal.SIG_DFL),
        ]
        for signum in (signal.SIGINT, signal.SIGTERM):
            with pytest.raises(KeyboardInterrupt):
                interrupt(signum, None)

    def test_overlapping_launch_returns_without_second_server_or_window(self):
        def while_window_open(url, profile, log):
            assert self.main() == 0
            self.start.assert_called_once()
            self.window.assert_called_once()
            self.stop.assert_not_called()

        self.window.side_effect = while_window_open
        assert self.main() == 0
        self.start.assert_called_once()
        self.stop.assert_called_once_with(self.process)
        # Closing the window releases the lock for a later launch.
        self.window.side_effect = None
        assert self.main() == 0
        assert self.start.call_count == 2
        assert self.window.call_count == 2
        assert self.stop.call_count == 2

    def test_launch_uses_private_state_log_and_chrome_profile(self):
        def started(log):
            assert log == self.state_home / "dsh-desktop/server.log"
            log.write_text("mock server log\n", encoding="utf-8")
            return self.process, LAUNCH_URL

        def opened(url, profile, log):
            profile = Path(profile)
            assert profile == self.config_home / "dsh-desktop/chrome"
            assert log == self.state_home / "dsh-desktop/browser.log"
            assert profile.is_relative_to(self.scratch)
            assert profile.is_dir()
            assert stat.S_IMODE(profile.stat().st_mode) == 0o700

        self.start.side_effect = started
        self.window.side_effect = opened
        assert self.main() == 0
        state = self.state_home / "dsh-desktop"
        assert stat.S_IMODE(state.stat().st_mode) == 0o700
        assert (state / "server.log").is_file()
        self.os.umask.assert_called_once_with(0o077)

    def test_start_server_returns_owned_process_and_ready_url(self):
        self.status.return_value = 303
        with self.monkeypatch.context() as monkeypatch:
            monkeypatch.setitem(self.globals, "logged_url", Mock(return_value=LAUNCH_URL))
            result = self.start_server()
        assert result == (self.process, LAUNCH_URL)
        arguments, options = self.popen.call_args
        assert arguments[0] == [
            "/mock/bin/dsh",
            "web",
            "--no-open",
            "--host",
            "127.0.0.1",
            "--port",
            "3080",
        ]
        assert options["cwd"] == self.home
        assert options["env"] == {"PATH": "/mock/bin"}
        assert options["start_new_session"] is True
        assert options["stdin"] == subprocess.DEVNULL
        assert options["stderr"] == subprocess.STDOUT
        self.status.assert_called_once_with(LAUNCH_URL)
        assert stat.S_IMODE((self.scratch / "server.log").stat().st_mode) == 0o600
        self.stop.assert_not_called()

    def test_start_server_waits_for_authenticated_readiness(self):
        self.status.side_effect = [401, 200]
        with self.monkeypatch.context() as monkeypatch:
            monkeypatch.setitem(self.globals, "logged_url", Mock(return_value=LAUNCH_URL))
            assert self.start_server() == (self.process, LAUNCH_URL)
        assert self.status.call_args_list == [call(LAUNCH_URL), call(LAUNCH_URL)]
        self.stop.assert_not_called()

    def test_startup_process_exit_cleans_owned_group(self):
        self.process.poll.return_value = 7
        with pytest.raises(self.module["LauncherError"]):
            self.start_server()
        self.stop.assert_called_once_with(self.process)

    def test_startup_timeout_cleans_owned_group(self):
        self.clock.monotonic.side_effect = [0, 0, 1000]
        with self.monkeypatch.context() as monkeypatch:
            monkeypatch.setitem(self.globals, "logged_url", Mock(return_value=None))
            with pytest.raises(self.module["LauncherError"]):
                self.start_server()
        self.stop.assert_called_once_with(self.process)

    def test_any_startup_exception_including_keyboard_interrupt_cleans_owned_group(self):
        for error in (OSError("log failed"), RuntimeError("poll failed"), KeyboardInterrupt()):
            self.stop.reset_mock()
            self.process.poll.side_effect = error
            with pytest.raises(type(error)) as caught:
                self.start_server()
            assert caught.value is error
            self.stop.assert_called_once_with(self.process)

    def test_startup_log_close_failure_cleans_process_already_spawned(self):
        error = OSError("log close failed")
        log = Mock()
        stream = log.open.return_value
        stream.__enter__ = Mock(return_value=Mock())
        stream.__exit__ = Mock(side_effect=error)
        with pytest.raises(OSError) as caught:
            self.original("start_server")(log)
        assert caught.value is error
        self.popen.assert_called_once()
        self.stop.assert_called_once_with(self.process)

    def test_browser_wait_uses_isolated_app_flags_and_private_log(self):
        self.run_window()
        arguments, options = self.popen.call_args
        assert arguments[0] == [
            BROWSER,
            "--user-data-dir=" + str(self.scratch / "chrome"),
            "--app=" + LAUNCH_URL,
            "--no-first-run",
            "--no-default-browser-check",
            "--disable-background-mode",
        ]
        assert options["stdin"] == subprocess.DEVNULL
        assert options["stderr"] == subprocess.STDOUT
        assert options["start_new_session"] is True
        assert options["close_fds"] is True
        self.browser_process.wait.assert_called_once_with()
        self.stop.assert_called_once_with(self.browser_process)
        assert stat.S_IMODE((self.scratch / "browser.log").stat().st_mode) == 0o600
        self.killpg.assert_not_called()

    def test_browser_close_waits_then_cleans_browser_and_server(self):
        events = []
        self.popen.return_value = self.browser_process
        self.browser_process.wait.side_effect = lambda: events.append("browser closed") or 0
        self.stop.side_effect = lambda process: events.append(
            "stop browser" if process is self.browser_process else "stop server",
        )
        with self.monkeypatch.context() as monkeypatch:
            monkeypatch.setitem(self.globals, "run_window", self.original("run_window"))
            assert self.main() == 0
        assert events == ["browser closed", "stop browser", "stop server"]
        assert self.stop.call_args_list == [
            call(self.browser_process),
            call(self.process),
        ]

    def test_abnormal_browser_exit_cleans_browser_and_server(self):
        self.popen.return_value = self.browser_process
        self.browser_process.wait.return_value = 7
        with self.monkeypatch.context() as monkeypatch:
            monkeypatch.setitem(self.globals, "run_window", self.original("run_window"))
            with pytest.raises(self.module["LauncherError"]) as caught:
                self.main()
        assert "7" in str(caught.value)
        assert self.stop.call_args_list == [
            call(self.browser_process),
            call(self.process),
        ]

    def test_browser_wait_interruption_cleans_both_owned_groups(self):
        self.popen.return_value = self.browser_process
        self.browser_process.wait.side_effect = KeyboardInterrupt()
        with self.monkeypatch.context() as monkeypatch:
            monkeypatch.setitem(self.globals, "run_window", self.original("run_window"))
            with pytest.raises(KeyboardInterrupt):
                self.main()
        assert self.stop.call_args_list == [
            call(self.browser_process),
            call(self.process),
        ]
        assert self.signals.signal.call_args_list[-2:] == [
            call(signal.SIGINT, signal.SIG_DFL),
            call(signal.SIGTERM, signal.SIG_DFL),
        ]

    def test_browser_log_close_failure_cleans_browser_already_spawned(self):
        error = OSError("browser log close failed")
        log = Mock()
        stream = log.open.return_value
        stream.__enter__ = Mock(return_value=Mock())
        stream.__exit__ = Mock(side_effect=error)
        self.popen.return_value = self.browser_process
        with pytest.raises(OSError) as caught:
            self.original("run_window")(LAUNCH_URL, self.scratch / "chrome", log)
        assert caught.value is error
        self.popen.assert_called_once()
        self.browser_process.wait.assert_not_called()
        self.stop.assert_called_once_with(self.browser_process)

    def test_browser_spawn_failure_never_stops_an_unowned_process(self):
        error = OSError("browser unavailable")
        self.popen.side_effect = error
        with pytest.raises(OSError) as caught:
            self.run_window()
        assert caught.value is error
        self.stop.assert_not_called()
        self.killpg.assert_not_called()

    def test_stop_server_terminates_group_waits_and_kills_leftover_children(self):
        self.group_exists.return_value = True
        self.clock.monotonic.side_effect = [0, 1000]
        self.original("stop_server")(self.process)
        assert call(self.process.pid, signal.SIGTERM) in self.killpg.call_args_list
        assert call(self.process.pid, signal.SIGKILL) in self.killpg.call_args_list
        assert call(timeout=10) in self.process.wait.call_args_list
        self.process.terminate.assert_not_called()
        self.process.kill.assert_not_called()

    def test_stop_server_timeout_escalates_and_reaps_leader(self):
        self.group_exists.return_value = True
        self.clock.monotonic.side_effect = [0, 1000]
        self.process.wait.side_effect = [subprocess.TimeoutExpired("dsh", 10), None]
        self.original("stop_server")(self.process)
        assert call(self.process.pid, signal.SIGTERM) in self.killpg.call_args_list
        assert call(self.process.pid, signal.SIGKILL) in self.killpg.call_args_list
        assert call(timeout=10) in self.process.wait.call_args_list
        assert call(timeout=5) in self.process.wait.call_args_list

    def test_stop_server_ignores_already_gone_process_group(self):
        self.killpg.side_effect = ProcessLookupError()
        self.original("stop_server")(self.process)
        self.process.wait.assert_called()

    def test_stop_server_cleans_children_when_leader_already_exited(self):
        self.process.poll.return_value = 0
        self.group_exists.return_value = True
        self.clock.monotonic.side_effect = [0, 1000]
        self.original("stop_server")(self.process)
        assert call(self.process.pid, signal.SIGKILL) in self.killpg.call_args_list
        self.process.wait.assert_called()
