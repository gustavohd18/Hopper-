package com.twitterproducer.server;

import com.corundumstudio.socketio.SocketIOClient;
import io.socket.client.IO;
import io.socket.client.Manager;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;

import java.net.SocketOption;
import java.net.URISyntaxException;
import java.util.LinkedHashMap;
import java.util.Map;

public class ClientIO {
    public Socket socket;

    public ClientIO() throws URISyntaxException {
         socket = IO.socket("ws://localhost:99");
        socket.connect();
        socket.on(Socket.EVENT_CONNECT, new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                System.out.println(socket.id()); // x8WIv7-mJelg7on_ALbx
            }
        });
         System.out.println(socket.isActive());
         socket.emit("hello", "hellllo");
        socket.on("hello", new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                System.out.println(args[0]); // world
            }
        });

    }
}
