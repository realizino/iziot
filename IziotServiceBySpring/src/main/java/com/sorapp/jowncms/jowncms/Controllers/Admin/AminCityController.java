package com.sorapp.jowncms.jowncms.Controllers.Admin;

import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
import com.sorapp.jowncms.jowncms.Service.City.City_Service;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/Admin")
public class AminCityController
{

    @Autowired
    City_Service City_Services;


    /****************Cites Start****************/

    @RequestMapping(value = "/Panel/Cities")
    public ModelAndView Cites(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/cites");
        response.addObject("user_data", AdminAuthCheckMiddleware.user_data);
        response.addObject("Cites",City_Services.GetCites());
        return response;
    }

    @RequestMapping(value = "/Panel/Cities/New",method = RequestMethod.POST)
    public String City_New(HttpServletRequest request,String name,String area,String status,String timezone)
    {
        LocalDateTime datetime = LocalDateTime.now();
        String time=datetime.getYear()+"/"+datetime.getMonthValue()+"/"+datetime.getDayOfMonth()+" "+datetime.getHour()+":"+datetime.getMinute()+":"+datetime.getSecond();

        City_Services.NewCity(name,Integer.parseInt(area),status,time,timezone);
        return "redirect:" + request.getHeader("referer");
    }

    @RequestMapping(value = "/Panel/Cities/Edit/{id}")
    public ModelAndView EditCity(HttpServletRequest request,@PathVariable String id)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/cites");
        response.addObject("user_data",AdminAuthCheckMiddleware.user_data);
        response.addObject("Cites",City_Services.GetCites());
        response.addObject("edit_city",City_Services.GetCity(Integer.parseInt(id)));
        return response;
    }

    @RequestMapping(value = "/Panel/Cities/Edit",method = RequestMethod.POST)
    public String City_Edit(HttpServletRequest request,String id,String name,String area,String status,String timezone)
    {
        LocalDateTime datetime = LocalDateTime.now();
        String time=datetime.getYear()+"/"+datetime.getMonthValue()+"/"+datetime.getDayOfMonth()+" "+datetime.getHour()+":"+datetime.getMinute()+":"+datetime.getSecond();

        City_Services.UpdateCity(Integer.parseInt(id),name,Integer.parseInt(area),status,time,timezone);
        return "redirect:" + "/Admin/Panel/Cities";
    }

    /****************Cites End****************/





}
