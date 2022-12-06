package org.example;

import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.LongDeserializer;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.io.IOException;
import java.util.Collections;
import java.util.Properties;

public class TwitterConsumer {
    public TwitterConsumer() {
        try {
            runConsumer();
        } catch (InterruptedException | IOException e) {
            throw new RuntimeException(e);
        }
    }

    private final static String TOPIC = KafkaConfig.TOPIC;
    private final static String BOOTSTRAP_SERVERS =
            KafkaConfig.BOOTSTRAPSERVERS + ",localhost:9093,localhost:9094";

    private static Consumer<Long, String> createConsumer() {
        final Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,
                BOOTSTRAP_SERVERS);
        props.put(ConsumerConfig.GROUP_ID_CONFIG,
                "KafkaExampleConsumer");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
                LongDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
                StringDeserializer.class.getName());

        // Create the consumer using props.
        final Consumer<Long, String> consumer =
                new KafkaConsumer<>(props);

        // Subscribe to the topic.
        consumer.subscribe(Collections.singletonList(TOPIC));
        return consumer;
    }

    static void runConsumer() throws InterruptedException, IOException, RuntimeException {
        final Consumer<Long, String> consumer = createConsumer();

        final Client client  = new Client("localhost",4567);

        final int giveUp = 5000;   int noRecordsCount = 0;
        while (true) {
            final ConsumerRecords<Long, String> consumerRecords =
                    consumer.poll(1000);

            if (consumerRecords.count()==0) {
                noRecordsCount++;
                if (noRecordsCount > giveUp) break;
                else continue;
            }

            consumerRecords.forEach(record -> {

                System.out.printf("Consumer Record:(%d, %s, %d, %d)\n",
                        record.key(), record.value(),
                        record.partition(), record.offset());
                try {
                    client.out.write(record.value().getBytes());
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });

            consumer.commitAsync();
        }
        consumer.close();
        System.out.println("DONE");
    }
}
