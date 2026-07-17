package com.sorapp.jowncms.jowncms.Service.UserVerify;

import com.sorapp.jowncms.jowncms.Models.Database.user_verify_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Concepts.IUser_Verify;
import com.sorapp.jowncms.jowncms.Service.Hash.HashService;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.File;
import java.util.List;
import java.util.Random;

@Service
public class UserVerify_Service implements IUser_Verify
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;


    @Override
    public boolean CheckVerifyCode(String code, int user_id)
    {
        code = HashService.HashText(code);

        try(Session session=sessionFactory.openSession())
        {
            String hql = "FROM user_verify_tbl WHERE user_id.id = :uid AND hash_code = :hcode";
            List<user_verify_tbl> Result = session.createQuery(hql, user_verify_tbl.class)
                    .setParameter("uid", user_id)
                    .setParameter("hcode", code)
                    .list();

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
    public void NewUserVerifyCode(users_tbl user_id)
    {
        Random rnd=new Random();

        user_verify_tbl NUser=new user_verify_tbl();
        NUser.setUser_id(user_id);
        String VCode = rnd.nextInt(11111,99999)+"";
        System.out.println("VCode : "+VCode);

        NUser.setHash_code(HashService.HashText(VCode));

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
            List<user_verify_tbl> codes =
                    session.createQuery(
                                    "FROM user_verify_tbl WHERE user_id.id = :uid",
                                    user_verify_tbl.class)
                            .setParameter("uid", user_id.getId())
                            .list();

            session.beginTransaction();

            for(user_verify_tbl code : codes)
            {
                session.remove(code);
            }

            session.getTransaction().commit();
        }
    }

}
