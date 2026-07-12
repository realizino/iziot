package com.sorapp.jowncms.jowncms.Service.UserVerify;

import com.sorapp.jowncms.jowncms.Models.Database.user_verify_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Concepts.IUser_Verify;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Random;

@Service
public class UserVerify_Service implements IUser_Verify
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;


    @Override
    public boolean CheckVerifyCode(String hash, int user_id)
    {

        try(Session session=sessionFactory.openSession())
        {
            List<user_verify_tbl> Result = session.createQuery("FROM user_verify_tbl WHERE user_verify_tbl.user_id.id="+user_id).list();
            if(Result.size()>0)
            {
                session.beginTransaction();
                session.remove(Result.get(0));
                session.getTransaction().commit();
                return true;
            }

        }

        return false;
    }

    @Override
    public void NewUserVerifyCode(String hash_code, users_tbl user_id)
    {
        Random rnd=new Random();

        user_verify_tbl NUser=new user_verify_tbl();
        NUser.setUser_id(user_id);
        NUser.setHash_code(rnd.nextInt(1111,9999)+"");

        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.save(NUser);
            session.getTransaction().commit();
        }

    }

    @Override
    public void RemoveUserVerifyCode(users_tbl user_id)
    {
        try(Session session=sessionFactory.openSession())
        {
            user_verify_tbl u_v = (user_verify_tbl) session.createQuery("FROM user_verify_tbl WHERE user_verify_tbl.user_id.id="+user_id).list().get(0);
            session.beginTransaction();
            session.remove(u_v);
            session.getTransaction().commit();
        }
    }

}
