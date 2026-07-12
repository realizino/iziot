package com.sorapp.jowncms.jowncms.Service.City;

import com.sorapp.jowncms.jowncms.Models.Database.city_tbl;
import com.sorapp.jowncms.jowncms.Concepts.ICity;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class City_Service implements ICity
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;


    @Override
    public city_tbl GetCity(int id)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (city_tbl) session.createQuery("FROM city_tbl city WHERE city.id="+id).list().get(0);
//            return session.get(hub_tbl.class, id);
        }
    }

    @Override
    public List<city_tbl> GetCites()
    {
        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM city_tbl").list();
        }
    }

    @Override
    public city_tbl NewCity(String name, int area, String status, String datetime,String timezone)
    {
        city_tbl City=new city_tbl();
        City.setName(name);
        City.setArea(area);
        City.setStatus(status);
        City.setDatetime(datetime);
        City.setTimezone(datetime);

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.save(City);
            session.getTransaction().commit();
        }

        return City;
    }

    @Override
    public city_tbl UpdateCity(int id, String name, int area, String status, String datetime,String timezone)
    {
        city_tbl City=GetCity(id);
        City.setName(name);
        City.setArea(area);
        City.setStatus(status);
        City.setDatetime(datetime);
        City.setTimezone(timezone);

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.update(City);
            session.getTransaction().commit();
        }

        return City;
    }

}
