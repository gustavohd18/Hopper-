import 'package:socket_flink_word_cloud/socket_flink_word_cloud.dart';
import 'package:test/test.dart';

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
  client.write('Who is there?xx');
  // listen for events from the client
  client.listen(
    // handle data from the client
    (Uint8List data) async {
      await Future.delayed(Duration(seconds: 1));
      // client.write('Who is there?xx');
      final message = String.fromCharCodes(data);
      print("mensagem que venho $message");
      if (message.contains("xx")) {
        // envia para todos os clientes conectados com este socket
        clients.forEach((client) {
          client.write(message);
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
