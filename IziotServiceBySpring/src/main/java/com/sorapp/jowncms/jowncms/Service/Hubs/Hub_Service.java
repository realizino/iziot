package com.sorapp.jowncms.jowncms.Service.Hubs;

import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Concepts.IHub;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class Hub_Service implements IHub
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;


    @Override
    public void AddNewHub(hub_tbl hub)
    {
        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.save(hub);
            session.getTransaction().commit();
        }
    }

    @Override
    public List<hub_tbl> GetAllHubs()
    {
        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM hub_tbl").list();
        }
    }

    @Override
    public List<hub_tbl> GetHubsByUser(int user_id)
    {
        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM hub_tbl hub WHERE hub.user_id.id = :userId")
                    .setParameter("userId", user_id)
                    .list();
        }
    }

    @Override
    public hub_tbl GetHub(int id)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (hub_tbl) session.createQuery("FROM hub_tbl hub WHERE hub.id = :id")
                    .setParameter("id", id)
                    .list()
                    .get(0);
        }
    }

    @Override
    public hub_tbl GetHubBySerial(String serial)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (hub_tbl) session.createQuery("FROM hub_tbl hub WHERE hub.serial_number = :serial")
                    .setParameter("serial", serial)
                    .list()
                    .get(0);
        }
    }

    @Override
    public void GetDisableHubBySerial(String serial)
    {
        hub_tbl hub=GetHubBySerial(serial);
        hub.setStatus("Diasable");
        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.update(hub);
            session.getTransaction().commit();
        }
    }

    @Override
    public void GetPoorConnectionHubBySerial(String serial) {
        hub_tbl hub=GetHubBySerial(serial);
        hub.setStatus("Poor");
        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.update(hub);
            session.getTransaction().commit();
        }
    }

    @Override
    public void UpdateHub(hub_tbl hub)
    {
        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.update(hub);
            session.getTransaction().commit();
        }
    }

    @Override
    public void DeleteHub(int id)
    {
        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            hub_tbl hub = session.get(hub_tbl.class, id);
            if (hub != null) {
                session.delete(hub);
            }
            session.getTransaction().commit();
        }
    }

}