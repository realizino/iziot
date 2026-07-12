package com.sorapp.jowncms.jowncms.Config;

import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ResourceBundleMessageSource;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor;
import org.springframework.web.servlet.i18n.SessionLocaleResolver;

import java.util.Locale;

@Configuration
public class WebConfig implements WebMvcConfigurer
{

    //Admin Auth Check Start
    @Autowired
    public AdminAuthCheckMiddleware AdminAuthCheck;

    @Override
    public void addInterceptors(InterceptorRegistry registry)
    {
        registry.addInterceptor(AdminAuthCheck).addPathPatterns("/Admin/Panel/*");
    }
    //Admin Auth Check End


    //Malti Language Start

    @Bean
    public LocaleResolver localeResolver() {
        SessionLocaleResolver slr = new SessionLocaleResolver();
        slr.setDefaultLocale(Locale.US);
        return slr;
    }

    @Bean
    public LocaleChangeInterceptor localeChangeInterceptor()
    {
        LocaleChangeInterceptor localeChangeInterceptor = new LocaleChangeInterceptor();
        localeChangeInterceptor.setParamName("language");
        return localeChangeInterceptor;
    }

    @Bean("messageSource")
    public MessageSource messageSource()
    {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasenames("Languages/Languages");
        messageSource.setDefaultEncoding("UTF-8");
        return messageSource;
    }

    //Malti Language End


}
