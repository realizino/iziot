package com.sorapp.jowncms.jowncms.Config;

import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
import com.sorapp.jowncms.jowncms.Middleware.ApiAuthCheckMiddleware; // ایمپورت کلاس جدید
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ResourceBundleMessageSource;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor;
import org.springframework.web.servlet.i18n.SessionLocaleResolver;

import java.util.Locale;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    // تزریق دو اینترسپتور مجزا
    @Autowired
    private AdminAuthCheckMiddleware adminAuthCheck;

    @Autowired
    private ApiAuthCheckMiddleware apiAuthCheck;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // اینترسپتور ادمین فقط برای /Admin/Panel/**
        registry.addInterceptor(adminAuthCheck)
                .addPathPatterns("/Admin/Panel/**");

        // اینترسپتور API فقط برای /api/**
        registry.addInterceptor(apiAuthCheck)
                .addPathPatterns("/api/**")
                .excludePathPatterns("/api/V1/Config", "/api/V1/Login"); // استثناها

        // اینترسپتور زبان
        registry.addInterceptor(localeChangeInterceptor());
    }

    // ========== تنظیمات CORS ==========
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**") // فقط برای API
                .allowedOrigins("http://localhost:59869") // یا "*" برای توسعه
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(false)
                .maxAge(3600);
    }

    // ========== بقیه Beanهای زبان ==========
    @Bean
    public LocaleResolver localeResolver() {
        SessionLocaleResolver slr = new SessionLocaleResolver();
        slr.setDefaultLocale(Locale.US);
        return slr;
    }

    @Bean
    public LocaleChangeInterceptor localeChangeInterceptor() {
        LocaleChangeInterceptor lci = new LocaleChangeInterceptor();
        lci.setParamName("language");
        return lci;
    }

    @Bean("messageSource")
    public MessageSource messageSource() {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasenames("Languages/Languages");
        messageSource.setDefaultEncoding("UTF-8");
        return messageSource;
    }
}