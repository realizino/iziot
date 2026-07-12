package com.sorapp.jowncms.jowncms.Service.Setting;

import com.sorapp.jowncms.jowncms.Models.Database.settings_tbl;
import com.sorapp.jowncms.jowncms.Concepts.ISetting;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class Setting_Service implements ISetting
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;


    @Override
    public settings_tbl GetSetting()
    {

        try(Session session=sessionFactory.openSession())
        {
            return (settings_tbl) session.createQuery("FROM settings_tbl setting ORDER BY setting.id desc").list().get(0);
        }
    }

    @Override
    public settings_tbl NewSetting(String Version,String ESP32CAM_Code)
    {
        settings_tbl settings_tbl=new settings_tbl();

        settings_tbl.setVersion(Version);
        settings_tbl.setESP32CAM_Code(ESP32CAM_Code);

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.save(settings_tbl);
            session.getTransaction().commit();
        }

        return settings_tbl;
    }

}
