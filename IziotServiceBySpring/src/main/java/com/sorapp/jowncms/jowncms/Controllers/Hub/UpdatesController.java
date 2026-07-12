package com.sorapp.jowncms.jowncms.Controllers.Hub;

import com.sorapp.jowncms.jowncms.Service.Setting.Setting_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/Update")
public class UpdatesController
{

    //Global variables
    @Autowired
    Setting_Service SettingsService;


    /**********************Get Update Start*****************************/

    @GetMapping(value = "/ESP32CAM",produces = MediaType.TEXT_PLAIN_VALUE)
    public String GetUpdate(HttpServletRequest request)
    {
        return SettingsService.GetSetting().getESP32CAM_Code();
    }

    /**********************Get Update End*****************************/


}
