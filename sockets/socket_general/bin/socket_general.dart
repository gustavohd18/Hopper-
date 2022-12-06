import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Map<String, int> values = Map();

//Lista de clientes
List<Socket> clientsSocket = List.empty(growable: true);
late Socket visualization;
List<String> text = List.empty(growable: true);

void main() async {
  // bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4563);
  Timer.periodic(Duration(seconds: 10), (Timer t) => checkForNewSharedLists());

  // listen for clent connections to the server
  server.listen((client) {
    handleConnection(client, clientsSocket);
  });
}

void checkForNewSharedLists() {
  if (text.isNotEmpty) {
    values[DateTime.now().toString()] = text.length;
    text = List.empty(growable: true);
    print("Cheguei aqui pra enviar a mensagem");
    if (visualization != null) {
      var jsonString = json.encode(values);

      visualization.write(jsonString);
    }
  }
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
          text.add(newMessage[0]);
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
