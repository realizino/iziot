package com.sorapp.jowncms.jowncms.Middleware;

import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Function.Encript.EncriptService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class AdminAuthCheckMiddleware implements HandlerInterceptor
{

    //Check Log Variable
    private static final Logger LOGGER=LoggerFactory.getLogger(AdminAuthCheckMiddleware.class);

    @Autowired
    EncriptService Encription;

    public static users_tbl user_data;


    //Get Check Auth On Evry Request in /Admin/ Start
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws IOException
    {
        Cookie []cookies=request.getCookies();
        String auth="";

        for(int i=0;i<cookies.length;i++)
        {
            if(cookies[i].getName().equals("auth"))
            {
                auth=cookies[i].getValue();
            }
        }

        if(!auth.toString().trim().equals(""))
        {
            try
            {
                String json = Encription.DEC(auth);
                users_tbl user = new users_tbl().FromJson(json);
                user_data=user;
                return true;
            }
            catch (Exception e)
            {

            }
        }

        response.sendRedirect("/Admin/Login");
        return false;
    }
    //Get Check Auth On Evry Request in /Admin/ End



}
