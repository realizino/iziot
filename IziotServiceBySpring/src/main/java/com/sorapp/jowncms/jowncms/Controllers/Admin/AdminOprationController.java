package com.sorapp.jowncms.jowncms.Controllers.Admin;

import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Service.Users.Users_Service;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/Admin")
public class AdminOprationController
{

    @Autowired
    Users_Service User_Services;

    /****************Opration done Start****************/
    @RequestMapping("/Panel/Done")
    public ModelAndView OprationDone(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/done");
        return response;
    }

    @RequestMapping("/Panel/DonePnl")
    public ModelAndView OprationPnlDone(HttpServletRequest request)
    {
        users_tbl user = User_Services.GetUser(AdminAuthCheckMiddleware.user_data.getId());

        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/donepnl");
        response.addObject("user_data",user);
        return response;
    }

    @RequestMapping("/Panel/NotDone")
    public ModelAndView OprationNotDone(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/notdone");
        return response;
    }

    @RequestMapping("/Panel/NotDonePnl")
    public ModelAndView OprationNotPnlDone(HttpServletRequest request)
    {
        users_tbl user = User_Services.GetUser(AdminAuthCheckMiddleware.user_data.getId());

        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/notdonepnl");
        response.addObject("user_data",user);
        return response;
    }
    /****************Opration done End****************/

}
