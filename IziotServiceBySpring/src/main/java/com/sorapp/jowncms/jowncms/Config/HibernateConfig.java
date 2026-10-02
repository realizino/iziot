package com.sorapp.jowncms.jowncms.Config;

import org.hibernate.SessionFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class HibernateConfig
{

    @Bean
    public SessionFactory sessionFactory()
    {
        org.hibernate.cfg.Configuration cfg = new org.hibernate.cfg.Configuration().configure("HibernateConfigs/hibernate.cfg.xml");

        // Docker/deploy override: DB_URL, DB_USER and DB_PASSWORD win over HibernateConfigs/hibernate.cfg.xml
        String url = envOrProperty("DB_URL");
        String user = envOrProperty("DB_USER");
        String password = envOrProperty("DB_PASSWORD");
        if(url != null) cfg.setProperty("hibernate.connection.url", url);
        if(user != null) cfg.setProperty("hibernate.connection.username", user);
        if(password != null) cfg.setProperty("hibernate.connection.password", password);

        return cfg.buildSessionFactory();
    }

    private static String envOrProperty(String key)
    {
        String value = System.getenv(key);
        if(value == null || value.isEmpty()) value = System.getProperty(key);
        return (value == null || value.isEmpty()) ? null : value;
    }
}
