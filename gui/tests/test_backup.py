import json
from subprocess import CompletedProcess
from gui.app import app

import pytest

@pytest.fixture
def client(monkeypatch):
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_rsync_backup(monkeypatch, client):
    cp = CompletedProcess(args=['sudo', '/usr/local/bin/backup_restore.sh', 'backup'], returncode=0, stdout='Backup created', stderr='')
    monkeypatch.setattr('subprocess.run', lambda *a, **k: cp)
    rv = client.post('/api/rsync-backup')
    data = rv.get_json()
    assert data['ok'] is True
