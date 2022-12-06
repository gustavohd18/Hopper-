package com.twitterproducer.flink_tweets;

import org.apache.flink.annotation.PublicEvolving;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.serialization.SerializationSchema;
import org.apache.flink.api.common.typeinfo.Types;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.windowing.assigners.TumblingProcessingTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.util.SerializableObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.concurrent.LinkedBlockingQueue;

import static org.apache.flink.util.NetUtils.isValidClientPort;
import static org.apache.flink.util.Preconditions.checkArgument;
import static org.apache.flink.util.Preconditions.checkNotNull;
public class FlinkTwitter {
//    private ConnectionToServer server;
//    private LinkedBlockingQueue<Object> messages;
//    private Socket socket;
//    private class ConnectionToServer {
//        ObjectInputStream in;
//        ObjectOutputStream out;
//        Socket socket;
//
////        ConnectionToServer(Socket socket) throws IOException {
////            this.socket = socket;
////            in = new ObjectInputStream(socket.getInputStream());
////            out = new ObjectOutputStream(socket.getOutputStream());
////
////            Thread read = new Thread(){
////                public void run(){
////                    while(true){
////                        try{
////                            Object obj = in.readObject();
////                            messages.put(obj);
////                        }
////                        catch(IOException e){ e.printStackTrace(); } catch (ClassNotFoundException e) {
////                            throw new RuntimeException(e);
////                        } catch (InterruptedException e) {
////                            throw new RuntimeException(e);
////                        }
////                    }
////                }
////            };
////
////            read.setDaemon(true);
////            read.start();
////        }
//
//        private void write(Object obj) {
//            try{
//                out.writeObject(obj);
//            }
//            catch(IOException e){ e.printStackTrace(); }
//        }
//
//
//    }
    public FlinkTwitter () throws Exception {
//        InetAddress host = null;
//        try {
//            host = InetAddress.getLocalHost();
//        } catch (UnknownHostException e) {
//            throw new RuntimeException(e);
//        }

        // get the execution environment
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        System.out.println("Cheguei aqui com o resultado");

        // get input data by connecting to the socket
        DataStream<String> text = env.socketTextStream("127.0.0.1", 4567, "\n");

        System.out.println("Cheguei aqui com o resultado" + text.toString());
        // parse the data, group it, window it, and aggregate the counts
        DataStream<WordWithCount> windowCounts =
                text.flatMap(
                                (FlatMapFunction<String, WordWithCount>)
                                        (value, out) -> {
                                            for (String word : value.split("\\s")) {
                                                out.collect(new WordWithCount(word, 1L));
                                            }
                                        },
                                Types.POJO(WordWithCount.class))
                        .keyBy(value -> value.word)
                        .window(TumblingProcessingTimeWindows.of(Time.seconds(5)))
                        .reduce((a, b) -> new WordWithCount(a.word, a.count + b.count))
                        .returns(WordWithCount.class);

        // print the results with a single thread, rather than in parallel
        // windowCounts

        windowCounts.print();
        env.execute("Socket Window WordCount");
    }
    public static class WordWithCount {

        public String word;
        public long count;

        @SuppressWarnings("unused")
        public WordWithCount() {}

        public WordWithCount(String word, long count) {
            this.word = word;
            this.count = count;
        }

        @Override
        public String toString() {
            return word + " : " + count;
        }
    }
}
