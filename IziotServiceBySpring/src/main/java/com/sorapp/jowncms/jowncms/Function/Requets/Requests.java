package com.sorapp.jowncms.jowncms.Function.Requets;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

public class Requests
{

    //Get request to address
    public static String StringRequest(String url)
    {
        try
        {
            //HttpClient httpClient=HttpClient.newHttpClient();
            HttpClient httpClient = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(5)) // Set the connection timeout to 10 seconds
                    .build();


            HttpRequest request=HttpRequest.newBuilder().uri(
                    URI.create(url)
            ).build();

            HttpResponse<String> response = httpClient.send(request,HttpResponse.BodyHandlers.ofString());

            return response.body();

        }
        catch (Exception e)
        {
            System.out.println("Request error : "+e.getMessage());
            return "ERROR";
        }
    }

}
