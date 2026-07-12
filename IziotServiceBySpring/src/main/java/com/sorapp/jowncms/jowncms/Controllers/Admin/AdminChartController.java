package com.sorapp.jowncms.jowncms.Controllers.Admin;

import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/Admin")
public class AdminChartController
{



    /****************Chart Start****************/
    @RequestMapping("/Panel/Charts")
    public ModelAndView Chart(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/chart");
        response.addObject("user_data", AdminAuthCheckMiddleware.user_data);
        return response;
    }
    /****************Chart End****************/





}
