package com.twitterproducer.server;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.concurrent.LinkedBlockingQueue;

import com.twitterproducer.producer.TwitterProducer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
public class Server {
    final Logger logger = LoggerFactory.getLogger(Server.class);

    private ArrayList<ConnectionToClient> clientList;
    private LinkedBlockingQueue<Object> messages;
    private ServerSocket serverSocket;

    public Server(int port) throws IOException {
        logger.info("Chamei o inicio do servidor");
        clientList = new ArrayList<ConnectionToClient>();
        messages = new LinkedBlockingQueue<Object>();
        serverSocket = new ServerSocket(port);

        Thread accept = new Thread() {
            public void run(){
                while(true){
                    try{
                        logger.info("Socket connected");
                        logger.info("Socket running in "+ serverSocket.getInetAddress() + ": port" + serverSocket.getLocalPort());
                        Socket s = serverSocket.accept();
                        clientList.add(new ConnectionToClient(s));
                        logger.info("Client id" + s.getLocalPort());
                    }
                    catch(IOException e){ e.printStackTrace(); logger.info("Socket Error");}
                }
            }
        };

        accept.setDaemon(true);
        accept.start();

        Thread messageHandling = new Thread() {
            public void run(){
                while(true){
                    try{
                        Object message = messages.take();
                        // Do some handling here...
                        System.out.println("Message Received: " + message);
                    }
                    catch(InterruptedException e){ }
                }
            }
        };

        messageHandling.setDaemon(true);
        messageHandling.start();
    }

    private class ConnectionToClient {
        ObjectInputStream in;
        ObjectOutputStream out;
        Socket socket;

        ConnectionToClient(Socket socket) throws IOException {
            this.socket = socket;
            in = new ObjectInputStream(socket.getInputStream());
            out = new ObjectOutputStream(socket.getOutputStream());

            Thread read = new Thread(){
                public void run(){
                    while(true){
                        try{
                            Object obj = in.readObject();
                            messages.put(obj);
                        }
                        catch(IOException e){ e.printStackTrace(); } catch (ClassNotFoundException e) {
                            throw new RuntimeException(e);
                        } catch (InterruptedException e) {
                            throw new RuntimeException(e);
                        }
                    }
                }
            };

            read.setDaemon(true); // terminate when main ends
            read.start();
        }

        public void write(Object obj) {
            try{
                out.writeObject(obj);
            }
            catch(IOException e){ e.printStackTrace(); }
        }
    }

    public void sendToOne(int index, Object message)throws IndexOutOfBoundsException {
        clientList.get(index).write(message);
    }

    public void sendToAll(String message){
        for(ConnectionToClient client : clientList)
            client.write(message);
    }

}