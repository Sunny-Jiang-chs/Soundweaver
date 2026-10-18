from pathlib import Path

import pytest

from audiovttforge import job


@pytest.mark.parametrize('name', ['ffmpeg', 'ffprobe'])
def test_installed_tools_work_without_developer_paths(tmp_path: Path, monkeypatch, name: str) -> None:
    executable = tmp_path / '应用 安装' / 'Soundweaver.exe'
    tool = executable.parent / 'tools' / 'ffmpeg' / f'{name}.exe'
    tool.parent.mkdir(parents=True)
    tool.write_bytes(b'tool')
    monkeypatch.setattr(job.sys, 'frozen', True, raising=False)
    monkeypatch.setattr(job.sys, 'executable', str(executable))
    monkeypatch.delenv(f'AUDIOVTTFORGE_{name.upper()}', raising=False)
    monkeypatch.setenv('PATH', '')
    monkeypatch.setattr(job, f'DEFAULT_{name.upper()}', tmp_path / 'not-installed.exe')
    resolved = job.JobSpec.from_dict({'audio': [], 'images': [], 'output': str(tmp_path / 'out.mp4')})
    assert getattr(resolved, name) == tool
    direct = job.JobSpec(audio=(), images=(), assignments=(), output=tmp_path / 'out.mp4')
    assert getattr(direct, name) == tool


def test_user_tool_overrides_bundled_tool(tmp_path: Path, monkeypatch) -> None:
    executable = tmp_path / 'Soundweaver.exe'
    bundled = tmp_path / 'tools' / 'ffmpeg' / 'ffmpeg.exe'
    bundled.parent.mkdir(parents=True)
    bundled.write_bytes(b'tool')
    monkeypatch.setattr(job.sys, 'frozen', True, raising=False)
    monkeypatch.setattr(job.sys, 'executable', str(executable))
    selected = tmp_path / 'custom.exe'
    monkeypatch.setenv('AUDIOVTTFORGE_FFMPEG', str(selected))
    assert job.default_ffmpeg() == selected
    explicit = tmp_path / 'explicit.exe'
    assert job.resolve_tool(explicit, 'AUDIOVTTFORGE_FFMPEG', bundled, 'ffmpeg') == explicit
