import 'dart:convert';

import 'package:socket_server/socket_server.dart' as socket_server;

import 'dart:io';
import 'dart:typed_data';

//Lista de clientes
List<Socket> clientsSocket = List.empty(growable: true);
void main() async {
  // bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4567);

  // listen for clent connections to the server
  server.listen((client) {
    handleConnection(client, clientsSocket);
  });
}

void handleConnection(Socket client, List<Socket> clients) {
  print('Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}');
  clients.add(client);
  // listen for events from the client
  client.listen(
    // handle data from the client
    (Uint8List data) async {
      await Future.delayed(Duration(seconds: 1));
      // client.write('Who is there?xx');
      final message = utf8.decode(data);
      print("mensagem que venho $message");
      if (message.contains("xx")) {
        // var encoded = utf8.encode(message);
        // var decoded = utf8.decode(encoded);
        //  print("MENSAGEM NOVA ${decoded}");
        // envia para todos os clientes conectados com este socket
        clients.forEach((client) {
          try {
            client.write(message);
          } catch (e) {
            print("error");
          }
        });
      }
    },

    // handle errors
    onError: (error) {
      print(error);
      client.close();
    },

    // handle the client closing the connection
    onDone: () {
      print('Client left');
      client.close();
    },
  );
}
