package com.sorapp.jowncms.jowncms;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class JowncmsApplication {

	public static void main(String[] args)
	{
		SpringApplication.run(JowncmsApplication.class, args);
	}

}
