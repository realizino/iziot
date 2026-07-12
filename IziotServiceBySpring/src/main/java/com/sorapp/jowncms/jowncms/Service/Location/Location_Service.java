package com.sorapp.jowncms.jowncms.Service.Location;

import com.sorapp.jowncms.jowncms.Models.Database.location_arch_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.location_tbl;
import com.sorapp.jowncms.jowncms.Concepts.ILocation;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class Location_Service implements ILocation
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;


    @Override
    public void AddLocation(location_tbl location)
    {
        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.save(location);
            session.getTransaction().commit();
        }
    }

    @Override
    public location_tbl GetLocationById(int id)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (location_tbl) session.createQuery("FROM location_tbl location WHERE location_tbl.hub_id.id="+id).list().get(0);
        }
    }

    @Override
    public location_tbl GetLocationBySerial(String serial)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (location_tbl) session.createQuery("FROM location_tbl location where location.hub_id.serial_number="+serial+" ORDER BY location.id desc").list().get(0);
        }
    }

    @Override
    public List<location_tbl> Get24Locations(String serial)
    {
        LocalDateTime CurrentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String formattedDate = CurrentDateTime.format(formatter);
        //System.out.println(formattedDate);

        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM location_tbl locations WHERE locations.date_time LIKE '%"+formattedDate+"%' ORDER BY rand()").setMaxResults(7).list();
        }
    }

    @Override
    public List<location_tbl> GetLast24HoursLocations(String serial)
    {
        ZonedDateTime dayAgo = ZonedDateTime.now().minusHours(24);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS");
        String fromDateTime = dayAgo.format(formatter);

        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM location_tbl loc WHERE loc.hub_id.serial_number = :serial AND loc.date_time >= :fromDateTime ORDER BY loc.id ASC")
                    .setParameter("serial", serial)
                    .setParameter("fromDateTime", fromDateTime)
                    .list();
        }
    }

    @Override
    public void Archiving()
    {
        try(Session session=sessionFactory.openSession())
        {
            List<location_tbl> locs = session.createQuery("FROM location_tbl loc ORDER BY loc.id desc").list();
            System.out.println("Len is "+locs.size());
            for(int i=0;i<locs.size() - 1200;i++)
            {
                location_arch_tbl arch=new location_arch_tbl();

                arch.setHub_id(locs.get(i).getHub_id().getId());
                arch.setDate_time(locs.get(i).getDate_time());
                arch.setAttribute(locs.get(i).getAttribute());
                arch.setLat(locs.get(i).getLat());
                arch.setLng(locs.get(i).getLng());

                session.beginTransaction();
                session.save(arch);
                session.getTransaction().commit();
            }
        }
        try (Session session = sessionFactory.openSession())
        {
            session.beginTransaction();
            session.createQuery("DELETE FROM location_tbl ").executeUpdate();
            session.getTransaction().commit();
        }
    }


}