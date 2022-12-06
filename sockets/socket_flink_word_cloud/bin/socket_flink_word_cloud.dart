import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Map<String, int> values = Map();

//Lista de clientes
List<Socket> clientsSocket = List.empty(growable: true);
late Socket visualization;

void main() async {
  // bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4560);

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
      try {
        final message = utf8.decode(data);

        if (message == "visualization") {
          visualization = client;
        }
        if (message.contains("*")) {
          final newMessage = message.split("*");
          for (int i = 0; i < newMessage.length; i++) {
            final parserMessage = newMessage[0].split(":");
            if (values.containsKey(parserMessage[0])) {
              try {
                final number = values[parserMessage[0]] ?? 0;
                values[parserMessage[0]] = number +
                    int.parse(parserMessage[1]
                        .replaceAll("*", "")
                        .replaceAll(":", "")
                        .trim());
              } catch (e) {
                print("Deu ruim");
              }
            } else {
              try {
                final newEntries = <String, int>{
                  parserMessage[0]
                          .replaceAll("*", "")
                          .replaceAll(":", "")
                          .trim():
                      int.parse(parserMessage[1]
                          .replaceAll("*", "")
                          .replaceAll(":", "")
                          .trim())
                };
                values.addAll(newEntries);
              } catch (e) {
                print("Aqui deu ruim");
              }
            }
          }
          values.forEach((key, value) {
            print(key + " : " + value.toString());
          });
          //  clients[0].writeAll(values.keys);
          if (visualization != null) {
            var jsonString = json.encode(values);

            visualization.write(jsonString);
          }
        }
      } catch (e) {
        print("Error word cloud");
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
