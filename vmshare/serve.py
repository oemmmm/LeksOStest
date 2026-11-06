# отдаёт файлы из этой папки и принимает загрузку вывода из виртуалки (PUT)
import http.server, socketserver, os
class H(http.server.SimpleHTTPRequestHandler):
    def do_PUT(self):
        n = int(self.headers.get('Content-Length', 0))
        name = os.path.basename(self.path) or 'upload.txt'
        open(name, 'wb').write(self.rfile.read(n))
        self.send_response(201); self.end_headers()
socketserver.TCPServer(('127.0.0.1', 8000), H).serve_forever()
