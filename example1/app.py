from flask import Flask, request, jsonify, send_file, g
import subprocess
import json

app = Flask(__name__)

def nix_eval(query, request_type, path, request_switch="process"):
    print(query, request_type, path, request_switch)
    if len(path)>0 and path[0] == "/": path = path[1:]
    try:
        output = subprocess.check_output(['nix', 'eval', '--raw',
        '--argstr', 'queryJson', json.dumps(query), 
        '--argstr', 'request_type', request_type, 
        '--argstr', 'path', path, '-f', 'default.nix', 
        request_switch], text=True, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        print(e.output)
        print(e.stderr)
    return output

@app.route('/', defaults={'path': ''},  methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
@app.route('/<path:path>',  methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
def catch_all(path):
    return nix_eval(request.args.to_dict(), request.method, path, 'process')