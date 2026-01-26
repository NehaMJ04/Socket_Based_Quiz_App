import socket
import json
from db_manager import init_db, save_score

HOST = "0.0.0.0"
PORT = 5050

init_db()

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((HOST, PORT))
server.listen(5)

print(f"Server listening on port {PORT}")

while True:
    client_socket, addr = server.accept()
    print("Connected from:", addr)

    data = client_socket.recv(1024).decode()
    quiz_data = json.loads(data)

    name = quiz_data["name"]
    score = quiz_data["score"]
    timestamp = quiz_data["timestamp"]

    save_score(name, score, timestamp)

    client_socket.send("SUCCESS".encode())
    client_socket.close()
