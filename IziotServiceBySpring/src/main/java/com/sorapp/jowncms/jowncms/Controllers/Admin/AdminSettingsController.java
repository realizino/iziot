package com.sorapp.jowncms.jowncms.Controllers.Admin;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sorapp.jowncms.jowncms.Function.Requets.Requests;
import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.settings_tbl;
import com.sorapp.jowncms.jowncms.Service.Setting.Setting_Service;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/Admin")
public class AdminSettingsController
{

    @Autowired
    Setting_Service Setting_Services;

    @Autowired
    com.sorapp.jowncms.jowncms.Service.Hubs.Hub_Service Hub_Service;


    /****************Setting Start****************/

    @RequestMapping("/Panel/Settings")
    public ModelAndView Settins()
    {
        settings_tbl settings_tbl=Setting_Services.GetSetting();

        ModelAndView response=new ModelAndView();
        response.addObject("version",settings_tbl.getVersion());
        response.addObject("code",settings_tbl.getESP32CAM_Code());

        //Decode config json, same idea as PHP's json_decode($Setting->parametrs)
        Map<String,String> parametrs=new HashMap<>();
        try
        {
            if(settings_tbl.getConfig()!=null && !settings_tbl.getConfig().isEmpty())
            {
                ObjectMapper mapper=new ObjectMapper();
                parametrs=mapper.readValue(settings_tbl.getConfig(), new TypeReference<Map<String,String>>(){});
            }
        }
        catch (Exception e)
        {
            parametrs=new HashMap<>();
        }

        response.addObject("parametrs",parametrs);
        response.addObject("user_data", AdminAuthCheckMiddleware.user_data);
        response.setViewName("Admin/settings");
        return response;
    }

    @RequestMapping(value = "/Panel/Settings/Done",method = RequestMethod.POST)
    public String Settings(String esp32cam_code,String version,String icon,String sale_background,String slider,
                           String mostupdate,String update_link,String background,String ads_image,String ads_link,
                           String law,String payment_in_web,String payment_in_android,String payment_in_ios,
                           String onemon,String thremon,String twomon)
    {
        //Build the config map, same structure as PHP's $result array
        Map<String,String> result=new LinkedHashMap<>();
        result.put("logo",icon);
        result.put("law",law);
        result.put("background",background);
        result.put("version",version);
        result.put("mostupdate",mostupdate);
        result.put("update_link",update_link);
        result.put("sale_background",sale_background);
        result.put("ads_image",ads_image);
        result.put("ads_link",ads_link);
        result.put("slider",slider);
        result.put("onemon",onemon);
        result.put("thremon",thremon);
        result.put("twomon",twomon);
        result.put("payment_in_web",payment_in_web);
        result.put("payment_in_android",payment_in_android);
        result.put("payment_in_ios",payment_in_ios);

        String configJson;
        try
        {
            ObjectMapper mapper=new ObjectMapper();
            configJson=mapper.writeValueAsString(result);
        }
        catch (Exception e)
        {
            configJson="{}";
        }

        Setting_Services.NewSetting(version,esp32cam_code,configJson);

        //Get last codes
        settings_tbl settings_tbl=Setting_Services.GetSetting();

        //Get update hub by iot model start
        List<hub_tbl> hubs = Hub_Service.GetAllHubs();
        for(int i=0;i<hubs.size();i++)
        {
            if(hubs.get(i).getStatus().equals("Enable"))
            {
                String HubAddress = hubs.get(i).getIp_address();
                Requests.StringRequest(HubAddress+"/update");
            }
        }
        //Get update hub by iot model end

        return "redirect:/Admin/Panel/Settings";
    }

    /****************Setting End****************/

}
