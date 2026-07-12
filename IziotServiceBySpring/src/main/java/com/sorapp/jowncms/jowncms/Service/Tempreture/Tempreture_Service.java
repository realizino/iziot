package com.sorapp.jowncms.jowncms.Service.Tempreture;

import com.sorapp.jowncms.jowncms.Models.Database.temperatures_arch_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.temperatures_tbl;
import com.sorapp.jowncms.jowncms.Concepts.ITemreture;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class Tempreture_Service implements ITemreture
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;


    @Override
    public void AddTemreture(temperatures_tbl tempreture)
    {
        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.save(tempreture);
            session.getTransaction().commit();
        }
    }

    @Override
    public temperatures_tbl GetTempretureById(int id)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (temperatures_tbl) session.createQuery("FROM temperatures_tbl tempreture WHERE temperatures_tbl.hub_id.id="+id).list().get(0);
        }
    }

    @Override
    public temperatures_tbl GetTempretureBySerial(String serial)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (temperatures_tbl) session.createQuery("FROM temperatures_tbl tempreture where tempreture.hub_id.serial_number="+serial+" ORDER BY tempreture.id desc").list().get(0);
        }
    }

    @Override
    public List<temperatures_tbl> Get24Tempretures(String serial)
    {
        LocalDateTime CurrentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String formattedDate = CurrentDateTime.format(formatter);
        //System.out.println(formattedDate);

        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM temperatures_tbl tempretures WHERE tempretures.date_time LIKE '%"+formattedDate+"%' ORDER BY rand()").setMaxResults(7).list();
        }
    }

    @Override
    public void Archiving()
    {
        try(Session session=sessionFactory.openSession())
        {
            List<temperatures_tbl> tmps = session.createQuery("FROM temperatures_tbl temp ORDER BY temp.id desc").list();
            System.out.println("Len is "+tmps.size());
            for(int i=0;i<tmps.size() - 1200;i++)
            {
                temperatures_arch_tbl arch=new temperatures_arch_tbl();

                arch.setHub_id(tmps.get(i).getHub_id().getId());
                arch.setDate_time(tmps.get(i).getDate_time());
                arch.setAttribute(tmps.get(i).getAttribute());
                arch.setTemperature(tmps.get(i).getTemperature());

                session.beginTransaction();
                session.save(arch);
                session.getTransaction().commit();
            }
        }
        try (Session session = sessionFactory.openSession())
        {
            session.beginTransaction();
            session.createQuery("DELETE FROM temperatures_tbl ").executeUpdate();
            session.getTransaction().commit();
        }
    }


}
