package com.sorapp.jowncms.jowncms.Config;

import com.sorapp.jowncms.jowncms.Concepts.ICredential;
import com.warrenstrange.googleauth.GoogleAuthenticator;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class Google2FConfig
{

    private final ICredential credentialRepository;

    @Bean
    public GoogleAuthenticator gAuth()
    {
        GoogleAuthenticator googleAuthenticator = new GoogleAuthenticator();
        googleAuthenticator.setCredentialRepository(credentialRepository);
        return googleAuthenticator;
    }

}
