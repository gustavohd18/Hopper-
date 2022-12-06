/*
Copyright 2020 Twitter, Inc.
SPDX-License-Identifier: Apache-2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
https://openapi-generator.tech
Do not edit the class manually.
*/


package com.twitterproducer;

import java.io.InputStream;
import java.util.HashSet;
import java.util.Set;

import com.twitter.clientlib.ApiException;
import com.twitter.clientlib.api.TwitterApi;
import com.twitter.clientlib.model.*;
import com.twitterproducer.configuration.KafkaConfig;
import com.twitterproducer.producer.TwitterProducer;
import org.apache.kafka.clients.producer.Callback;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;

public class StreamingTweetHandlerImpl extends StreamingTweetHandler {

  public TwitterProducer producer = new TwitterProducer();
  public StreamingTweetHandlerImpl(TwitterApi apiInstance) {
    super(apiInstance);
  }

  @Override
  public InputStream connectStream() throws ApiException {




//    AddOrDeleteRulesResponse result = apiInstance.tweets().addOrDeleteRules(addOrDeleteRulesRequest)
//            .dryRun(true)
//            .execute();
//    System.out.println(result);
    return this.apiInstance.tweets().searchStream()
        .backfillMinutes(0)
        .execute();
  }

  @Override
  public void actionOnStreamingObject(StreamingTweetResponse streamingTweet) throws ApiException {
    if(streamingTweet == null) {
      System.err.println("Error: actionOnTweetsStream - streamingTweet is null ");
      return;
    }

    if(streamingTweet.getErrors() != null) {
      streamingTweet.getErrors().forEach(System.out::println);
    } else if (streamingTweet.getData() != null) {
      String msgNew =  streamingTweet.getData().getText() + "/xx";
      producer.producer.send(new ProducerRecord<String, String>(KafkaConfig.TOPIC, null, msgNew), new Callback() {
        @Override
        public void onCompletion(RecordMetadata recordMetadata, Exception e) {
          if (e != null) {
            System.out.println("Some error happened" + e);
          }
        }
      });
      System.out.println("New streaming tweet: " + streamingTweet.getData().getText());
    }
  }
}
