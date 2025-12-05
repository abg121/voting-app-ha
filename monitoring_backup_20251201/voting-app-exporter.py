#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import requests
import time

class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/metrics':
            metrics = self.get_metrics()
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(metrics.encode())
        else:
            self.send_response(404)
            self.end_headers()

    def get_metrics(self):
        metrics = []

        # Check vote app health
        try:
            response = requests.get('http://vote:80/', timeout=5)
            vote_up = 1 if response.status_code == 200 else 0
        except:
            vote_up = 0

        # Check result app health
        try:
            response = requests.get('http://result:80/', timeout=5)
            result_up = 1 if response.status_code == 200 else 0
        except:
            result_up = 0

        metrics.append(f'voting_app_up{{service="vote"}} {vote_up}')
        metrics.append(f'voting_app_up{{service="result"}} {result_up}')
        metrics.append(f'voting_app_requests_total{{service="exporter"}} 1')

        return '\n'.join(metrics) + '\n'

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), MetricsHandler)
    print('Starting voting app exporter on port 8080...')
    server.serve_forever()
