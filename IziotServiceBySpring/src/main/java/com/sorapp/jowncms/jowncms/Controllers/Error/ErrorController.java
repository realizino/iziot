package com.sorapp.jowncms.jowncms.Controllers.Error;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@RequestMapping("/Error")
@Controller
public class ErrorController
{


    @GetMapping("403")
    public ModelAndView NoAccess()
    {
        ModelAndView result=new ModelAndView();
        result.setViewName("Error/403");
        return result;
    }


    @GetMapping("404")
    public ModelAndView NotFound()
    {
        ModelAndView result=new ModelAndView();
        result.setViewName("Error/404");
        return result;
    }


    @GetMapping("405")
    public ModelAndView MethodNotAllowed()
    {
        ModelAndView result=new ModelAndView();
        result.setViewName("Error/405");
        return result;
    }


    @GetMapping("413")
    public ModelAndView FileLarge()
    {
        ModelAndView result=new ModelAndView();
        result.setViewName("Error/413");
        return result;
    }

    @GetMapping("500")
    public ModelAndView InternalServer()
    {
        ModelAndView result=new ModelAndView();
        result.setViewName("Error/500");
        return result;
    }


    @GetMapping("504")
    public ModelAndView TimeOutError()
    {
        ModelAndView result=new ModelAndView();
        result.setViewName("Error/504");
        return result;
    }


}
