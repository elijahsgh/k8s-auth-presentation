#!/usr/bin/env python3

from http.server import HTTPServer, BaseHTTPRequestHandler
import requests
import json
from base64 import b64decode
import os
import string
import random

vaultserver = os.environ.get('VAULT_SERVER', '')

class VaultDemoHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # curl -XPOST -d "{\"jwt\": \"$VAULT_JWT\", \"role\": \"my-demo\"}" http://vault:8200/v1/auth/kube/login
        if os.environ.get('SA_TOKEN') == None:
            with open('/var/run/secrets/kubernetes.io/serviceaccount/token') as f:
                token = f.read()
        else:
            token = os.environ['SA_TOKEN']

        payload = {'jwt': token, 'role': 'my-demo'}
        jsonresponse = requests.post(f'{vaultserver}/v1/auth/kubernetes/login', data=json.dumps(payload)).json()

        vaulttoken = jsonresponse['auth']['client_token']

        response = requests.get(f'{vautlserver}/v1/secret/demo', headers={'X-Vault-Token': vaulttoken})

        self.send_response(200)
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))

server = HTTPServer(('0.0.0.0', 8000), VaultDemoHandler)

server.serve_forever()
