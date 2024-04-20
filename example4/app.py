from flask import Flask, request, jsonify, send_from_directory, g
import subprocess
import json
import tempfile

app = Flask(__name__)

def nix_eval(query, request_type, path, request_switch="process"):
    print(query, request_type, path, request_switch)
    if len(path)>0 and path[0] == "/": path = path[1:]
    with tempfile.TemporaryDirectory() as tmpdirname:
        try:
            output = subprocess.check_output(['nix', 'eval', '--raw',
            '--extra-experimental-features', 'nix-command',
            '--eval-store', tmpdirname, '--no-require-sigs',
            '--argstr', 'queryJson', json.dumps(query), 
            '--argstr', 'request_type', request_type, 
            '--argstr', 'path', path, '-f', 'default.nix', 
            request_switch], text=True, stderr=subprocess.PIPE)
        except subprocess.CalledProcessError as e:
            print(e.output)
            print(e.stderr)
        print(subprocess.check_output(['ls', '-l', tmpdirname], text=True))
    return output


@app.route('/', defaults={'path': ''},  methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
@app.route('/<path:path>',  methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
def catch_all(path):
    return nix_eval(request.args.to_dict(), request.method, path, 'process')


@app.route('/favicon.ico')
@app.route('/codicon.ttf')
def ignore():
    pass
