package com.sorapp.jowncms.jowncms.Service.AirQuality;

import com.sorapp.jowncms.jowncms.Models.Database.airquality_arch_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.airquality_tbl;
import com.sorapp.jowncms.jowncms.Concepts.IAirQuality;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class AirQuality_Service implements IAirQuality
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;


    @Override
    public void AddValue(airquality_tbl airquality) {
        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.save(airquality);
            session.getTransaction().commit();
        }
    }

    @Override
    public airquality_tbl GetValueById(int id) {
        try(Session session=sessionFactory.openSession())
        {
            return (airquality_tbl) session.createQuery("FROM airquality_tbl airquality WHERE airquality_tbl.hub_id.id="+id).list().get(0);
        }
    }

    @Override
    public airquality_tbl GetValueBySerial(String serial) {
        try(Session session=sessionFactory.openSession())
        {
            return (airquality_tbl) session.createQuery("FROM airquality_tbl airquality where airquality.hub_id.serial_number="+serial+" ORDER BY airquality.id desc").list().get(0);
        }
    }

    @Override
    public List<airquality_tbl> Get24Values(String serial) {
        LocalDateTime CurrentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String formattedDate = CurrentDateTime.format(formatter);
        //System.out.println(formattedDate);

        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM airquality_tbl airquality WHERE airquality.date_time LIKE '%"+formattedDate+"%' ORDER BY rand()").setMaxResults(7).list();
        }
    }

    @Override
    public void Archiving() {
        try(Session session=sessionFactory.openSession())
        {
            List<airquality_tbl> air = session.createQuery("FROM airquality_tbl air order by air.id desc").list();
            System.out.println("Len is "+air.size());
            for(int i=0;i<air.size() - 1200;i++)
            {
                airquality_arch_tbl arch=new airquality_arch_tbl();

                arch.setHub_id(air.get(i).getHub_id().getId());
                arch.setDate_time(air.get(i).getDate_time());
                arch.setAttribute(air.get(i).getAttribute());
                arch.setValue(air.get(i).getValue());

                session.beginTransaction();
                session.save(arch);
                session.getTransaction().commit();
            }
        }
        try (Session session = sessionFactory.openSession())
        {
            session.beginTransaction();
            session.createQuery("DELETE FROM airquality_tbl").executeUpdate();
            session.getTransaction().commit();
        }
    }
}
