package com.sorapp.jowncms.jowncms.Service.Users;

import com.google.common.hash.Hashing;
import com.sorapp.jowncms.jowncms.Function.Hash.HashService;
import com.sorapp.jowncms.jowncms.Models.Database.*;
import com.sorapp.jowncms.jowncms.Concepts.IUser;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import java.nio.charset.StandardCharsets;
import java.util.List;

@Service
public class Users_Service implements IUser
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;

    public static Logger LOGGER= LoggerFactory.getLogger(Users_Service.class);


    @Override
    public List<users_tbl> GetAllUsers()
    {
        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM users_tbl").list();
        }
    }


    @Override
    public List<users_tbl> GetAllAdminUsers()
    {
        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM users_tbl").list();
        }
    }


    @Override
    public users_tbl GetUser(int id)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (users_tbl) session.createQuery("FROM users_tbl user WHERE user.id="+id).list().get(0);
        }
    }


    @Override
    public users_tbl GetUserByToken(String token)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (users_tbl) session.createQuery("FROM users_tbl user WHERE user.login_token='"+token+"'").list().get(0);
        }
    }


    @Override
    public users_tbl Login(String username, String password)
    {
        try
        {
            try(Session session=sessionFactory.openSession())
            {
                return (users_tbl) session.createQuery("FROM users_tbl user WHERE user.username LIKE '"+username+"' AND user.password LIKE '"+password+"'").list().get(0);
            }
        }
        catch (Exception e)
        {
            return null;
        }
    }

    @Override
    public users_tbl LoginByToken(String token)
    {
        try
        {
            try(Session session=sessionFactory.openSession())
            {
                return (users_tbl) session.createQuery("FROM users_tbl user WHERE user.login_token LIKE '"+token+"'").list().get(0);
//            return session.get(hub_tbl.class, id);
            }
        }
        catch (Exception e)
        {
            return null;
        }
    }


    @Override
    public users_tbl NewUser(String name, String family, String username, String password, String LoginToken, String phone, String email, String bio, String date_time, String user_type, String status, String website, String address, String google_auth, file_tbl profile_image_file_id, city_tbl city_id)
    {
        password= Hashing.sha256().hashString(password, StandardCharsets.UTF_8).toString();
        LoginToken = com.sorapp.jowncms.jowncms.Service.Hash.HashService.HashText(name+date_time+family+username+password);

        users_tbl NUser=new users_tbl(
            username,
            password,
            name,
            family,
            phone,
            email,
            bio,
            LoginToken,
            date_time,
            user_type,
            status,
            website,
            address,
            "",
            profile_image_file_id,
            city_id
        );

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.save(NUser);
            session.getTransaction().commit();
        }

        return NUser;
    }

    @Override
    public users_tbl UpdateUser(int id, String name, String family, String username, String password, String phone, String email, String bio, String date_time, String user_type, String status, String website, String address, file_tbl profile_image_file_id, city_tbl city_id)
    {
        users_tbl NUser=GetUser(id);

        NUser.setUsername(username);

        if(!password.equals("")) {
            password= Hashing.sha256().hashString(password, StandardCharsets.UTF_8).toString();
            NUser.setPassword(password);
        }

        NUser.setName(name);
        NUser.setFamily(family);
        NUser.setEmail(email);
        NUser.setBio(bio);
        NUser.setPhone(phone);
        NUser.setUser_type(user_type);
        NUser.setStatus(status);
        NUser.setWebsite(website);
        NUser.setAddress(address);
        NUser.setProfile_image_id(profile_image_file_id);
        NUser.setCity_id(city_id);

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.update(NUser);
            session.getTransaction().commit();
        }

        return NUser;
    }

    @Override
    public users_tbl UpdateUserStatus(int id, String status)
    {
        users_tbl NUser=GetUser(id);

        NUser.setStatus(status);

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.update(NUser);
            session.getTransaction().commit();
        }

        return NUser;
    }

    @Override
    public users_tbl UpdateUserForm(int id, String name, String family, String phone, String bio)
    {
        users_tbl NUser=GetUser(id);

        NUser.setName(name);
        NUser.setFamily(family);
        NUser.setBio(bio);
        NUser.setPhone(phone);

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.update(NUser);
            session.getTransaction().commit();
        }

        return NUser;
    }


    @Override
    public users_tbl UpdateUserByAdmin(int id, String name, String family, String username, String password, String phone, String email, String bio, String date_time, String user_type, String status, String website, String address, file_tbl profile_image_file_id, city_tbl city_id)
    {
        users_tbl NUser=GetUser(id);

        NUser.setUsername(username);

        if(!password.equals("")) {
            password= HashService.HashText(password);
            NUser.setPassword(password);
        }

        NUser.setName(name);
        NUser.setFamily(family);
        NUser.setEmail(email);
        NUser.setBio(bio);
        NUser.setPhone(phone);
        NUser.setUser_type(user_type);
        NUser.setStatus(status);
        NUser.setWebsite(website);
        NUser.setAddress(address);
        NUser.setProfile_image_id(profile_image_file_id);
        NUser.setCity_id(city_id);

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.update(NUser);
            session.getTransaction().commit();
        }

        return NUser;
    }


    @Override
    public void Google2F(users_tbl user_id, String State, String Key)
    {
        users_tbl NUser=GetUser(user_id.getId());

        if(State.equals("Active"))
        {
            NUser.setGoogle_auth(Key);
        }
        else
        {
            NUser.setGoogle_auth("");
        }

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.update(NUser);
            session.getTransaction().commit();
        }

    }



    @Override
    public List<users_tbl> GetSeachUser(String seach)
    {
        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM users_tbl users WHERE users.username LIKE '%"+seach+"%' OR users.name LIKE '%"+seach+"%' OR users.family LIKE '%"+seach+"%'").list();
        }
    }

    @Override
    public List<users_tbl> GetCheckUserExist(String username)
    {
        try(Session session=sessionFactory.openSession())
        {
            return session.createQuery("FROM users_tbl users WHERE users.username LIKE '"+username+"'").list();
        }
    }


}
