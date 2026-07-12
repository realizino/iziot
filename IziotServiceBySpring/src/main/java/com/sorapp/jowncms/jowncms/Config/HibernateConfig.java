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
        return new org.hibernate.cfg.Configuration().configure("HibernateConfigs/hibernate.cfg.xml").buildSessionFactory();
    }
}
