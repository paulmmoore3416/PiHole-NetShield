#!/usr/bin/env python3
from flask import Flask, render_template, request, jsonify, redirect, url_for
import subprocess
import os
import shlex

app = Flask(__name__)

# Basic (very lightweight) token authentication - set via environment variable GUI_TOKEN
# For production use, use a proper auth strategy such as OAuth2 or nginx+httpauth with HTTPS

def check_token(req):
    token = os.environ.get('GUI_TOKEN', None)
    if not token:
        # no token configured -> allow local-only access
        return True
    auth = req.headers.get('Authorization')
    if not auth:
        return False
    return auth == f"Bearer {token}"

@app.route('/')
def index():
    if not check_token(request):
        return ("Unauthorized", 401)
    status = _pihole_status()
    return render_template('index.html', status=status)

@app.route('/api/status')
def api_status():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    status = _pihole_status()
    return jsonify(status)

@app.route('/api/start', methods=['POST'])
def api_start():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    out = _systemctl('start', 'pihole-FTL')
    return jsonify({'ok': True, 'result': out})

@app.route('/api/stop', methods=['POST'])
def api_stop():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    out = _systemctl('stop', 'pihole-FTL')
    return jsonify({'ok': True, 'result': out})

@app.route('/api/restart', methods=['POST'])
def api_restart():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    out = _systemctl('restart', 'pihole-FTL')
    return jsonify({'ok': True, 'result': out})

@app.route('/api/update', methods=['POST'])
def api_update():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    # run the update script that was created earlier
    cmd = ['/usr/local/bin/auto_update.sh']
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return jsonify({'ok': proc.returncode == 0, 'stdout': proc.stdout, 'stderr': proc.stderr})

@app.route('/api/backup', methods=['POST'])
def api_backup():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    cmd = ['/usr/local/bin/backup_restore.sh', 'backup']
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return jsonify({'ok': proc.returncode == 0, 'stdout': proc.stdout, 'stderr': proc.stderr})

@app.route('/api/add-blocklist', methods=['POST'])
def api_add_blocklist():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    data = request.json or {}
    url = data.get('url')
    name = data.get('name')
    if not url or not name:
        return jsonify({'error': 'url and name are required'}), 400
    cmd = ['/usr/local/bin/custom_blocklist_manager.sh', 'add', url, name]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return jsonify({'ok': proc.returncode == 0, 'stdout': proc.stdout, 'stderr': proc.stderr})

@app.route('/api/update-blocklists', methods=['POST'])
def api_update_blocklists():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    cmd = ['/usr/local/bin/custom_blocklist_manager.sh', 'update']
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return jsonify({'ok': proc.returncode == 0, 'stdout': proc.stdout, 'stderr': proc.stderr})

@app.route('/api/logs')
def api_logs():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    # show last N lines from pihole log
    lines = int(request.args.get('lines', 200))
    cmd = ['tail', '-n', str(lines), '/var/log/pihole.log']
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return jsonify({'ok': proc.returncode == 0, 'output': proc.stdout})

@app.route('/api/ftl-errors')
def api_ftl_errors():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    cmd = ['journalctl', '-u', 'pihole-FTL.service', '--since', '6 hours ago', '--no-pager', '-p', 'warning']
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return jsonify({'ok': proc.returncode == 0, 'output': proc.stdout})

@app.route('/api/stats')
def api_stats():
    if not check_token(request):
        return jsonify({'error': 'unauthorized'}), 401
    if not _has_pihole():
        return jsonify({'error': 'pihole not installed'}), 400
    cmd = ['pihole', '-c', '-j']
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return jsonify({'ok': proc.returncode == 0, 'json': proc.stdout})

# Helpers

def _has_pihole():
    return os.path.exists('/etc/pihole')


def _pihole_status():
    if not _has_pihole():
        return {'installed': False}
    cmd = ['pihole', '-c', '-j']
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        return {'installed': True, 'pihole_status_json': proc.stdout}
    except Exception as e:
        return {'installed': True, 'error': str(e)}


def _systemctl(action, service):
    cmd = ['systemctl', action, service]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return {'rc': proc.returncode, 'stdout': proc.stdout, 'stderr': proc.stderr}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('GUI_PORT', 8080)), debug=True)