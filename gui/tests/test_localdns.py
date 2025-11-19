import json
from subprocess import CompletedProcess
import pytest
from gui.app import app

@pytest.fixture
def client(monkeypatch):
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_localdns_list(monkeypatch, tmp_path, client):
    # Create a fake local list
    fp = tmp_path / 'local.list'
    fp.write_text('192.168.1.10 nas.local\n')
    monkeypatch.setenv('FEATURES_PATH', '/tmp/does-not-exist')
    # monkeypatch local_dns script path
    monkeypatch.setattr('subprocess.run', lambda *a, **k: CompletedProcess(args=[], returncode=0, stdout='192.168.1.10 nas.local\n', stderr=''))
    rv = client.get('/api/localdns')
    data = rv.get_json()
    assert data['ok']
    assert 'nas.local' in data['output']


def test_add_localdns(monkeypatch, client):
    cp = CompletedProcess(args=['sudo', '/usr/local/bin/local_dns.sh', 'add'], returncode=0, stdout='Added nas.local', stderr='')
    monkeypatch.setattr('subprocess.run', lambda *a, **k: cp)
    rv = client.post('/api/localdns', json={'ip':'192.168.1.20', 'name':'nas.local'})
    data = rv.get_json()
    assert data['ok'] is True


def test_remove_localdns(monkeypatch, client):
    cp = CompletedProcess(args=['sudo', '/usr/local/bin/local_dns.sh', 'remove'], returncode=0, stdout='Removed nas.local', stderr='')
    monkeypatch.setattr('subprocess.run', lambda *a, **k: cp)
    rv = client.delete('/api/localdns', json={'name':'nas.local'})
    data = rv.get_json()
    assert data['ok'] is True
