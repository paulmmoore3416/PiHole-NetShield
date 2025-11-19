import json
import os
import subprocess
from subprocess import CompletedProcess
from gui.app import app

import pytest

@pytest.fixture
def client(monkeypatch):
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_status_not_installed(monkeypatch, client):
    monkeypatch.setattr('os.path.exists', lambda path: False)
    rv = client.get('/api/status')
    data = rv.get_json()
    assert data.get('installed') is False


def test_start_service(monkeypatch, client):
    cp = CompletedProcess(args=['systemctl', 'start', 'pihole-FTL'], returncode=0, stdout='ok', stderr='')
    monkeypatch.setattr('subprocess.run', lambda *a, **k: cp)
    rv = client.post('/api/start')
    assert rv.status_code == 200
    data = rv.get_json()
    assert data['ok'] is True


def test_add_blocklist(monkeypatch, client):
    cp = CompletedProcess(args=['/usr/local/bin/custom_blocklist_manager.sh', 'add'], returncode=0, stdout='ok', stderr='')
    monkeypatch.setattr('subprocess.run', lambda *a, **k: cp)
    rv = client.post('/api/add-blocklist', json={'url': 'http://example.com/list', 'name': 'testlist'})
    data = rv.get_json()
    assert data['ok'] is True


def test_features_read_write(tmp_path, monkeypatch, client):
    fp = tmp_path / 'features.json'
    fp.write_text(json.dumps({'blocklist_manager': True, 'performance_monitoring': False}))
    monkeypatch.setenv('FEATURES_PATH', str(fp))

    rv = client.get('/api/features')
    data = rv.get_json()
    assert data['ok'] is True
    assert data['features']['blocklist_manager'] is True

    rv2 = client.post('/api/features', json={'performance_monitoring': True})
    data2 = rv2.get_json()
    assert data2['ok'] is True
    assert data2['features']['performance_monitoring'] is True
