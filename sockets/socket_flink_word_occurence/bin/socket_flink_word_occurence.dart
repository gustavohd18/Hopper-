import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';
// ignore: unused_import
import 'package:web_socket_channel/web_socket_channel.dart';

Map<String, int> values = Map();
late Socket visualization;

//Lista de clientes
List<Socket> clientsSocket = List.empty(growable: true);
void main() async {
  // bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4561);

  // listen for clent connections to the server
  server.listen((client) {
    handleConnection(client, clientsSocket);
  });
}

void handleConnection(Socket client, List<Socket> clients) {
  print('Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}');
  // websocket.clients.add(client);
  // listen for events from the client
  client.listen(
    // handle data from the client
    (Uint8List data) async {
      await Future.delayed(Duration(seconds: 1));
      // client.write('Who is there?xx');
      try {
        final message = String.fromCharCodes(data);
        if (message == "visualization") {
          visualization = client;
        }
        print(message);
        if (message.contains("*")) {
          final newMessage = message.split("*");
          for (int i = 0; i < newMessage.length; i++) {
            final parserMessage = newMessage[0].split(":");
            if (values.containsKey(parserMessage[0])) {
              final number = values[parserMessage[0]] ?? 0;
              values[parserMessage[0]] = number + int.parse(parserMessage[1]);
            } else {
              final newEntries = <String, int>{
                parserMessage[0]: int.parse(parserMessage[1])
              };
              values.addAll(newEntries);
            }
          }
          values.forEach((key, value) {
            print(key + ":" + value.toString());
          });

          if (visualization != null) {
            var jsonString = json.encode(values);

            visualization.write(jsonString);
          }
        }
      } catch (e) {
        print("Error");
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
