package com.twitterproducer;

import com.twitter.clientlib.ApiException;
import com.twitter.clientlib.TwitterCredentialsBearer;
import com.twitter.clientlib.api.TwitterApi;
public class Main {
    public static void main(String[] args) throws Exception {
        String bearerToken = "AAAAAAAAAAAAAAAAAAAAADoxjwEAAAAACsBMB3OWbo0YMozGX4IZeW%2F8Wdk%3DvfveIOzXjcgruH5T4ohZTJImL7zbApQ4FKY38XeQOZWOT9u55o";//"AAAAAAAAAAAAAAAAAAAAADoxjwEAAAAA%2BcRDAMJsEFju9JK%2BYq2VlpvrPwA%3DYUiLarNgVFeqU4vmBTneyqukgGh714RD4ZdtCFU3eFafXdEOmr";
        TwitterApi apiInstance = new TwitterApi(new TwitterCredentialsBearer(bearerToken));
      //  new TwitterConsumer();

        try {

            TweetsStreamListenersExecutor tsle = new TweetsStreamListenersExecutor();
            tsle.stream()
                    .streamingHandler(new StreamingTweetHandlerImpl(apiInstance))
                    .executeListeners();
            while(tsle.getError() == null) {
                try {
                    System.out.println("==> sleeping 2");
                    Thread.sleep(2000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

            if(tsle.getError() != null) {
                System.err.println("==> Ended with error: " + tsle.getError());
            }

        } catch (ApiException e) {
            System.err.println("Status code: " + e.getCode());
            System.err.println("Reason: " + e.getResponseBody());
            System.err.println("Response headers: " + e.getResponseHeaders());
            e.printStackTrace();
        }
    }
}

