package com.sorapp.jowncms.jowncms.Controllers.Api.V1;


import com.sorapp.jowncms.jowncms.Service.Setting.Setting_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/V1")
public class ApiV1ConfigController
{

    @Autowired
    Setting_Service SeetingService;


    @RequestMapping("Config")
    public ResponseEntity<String> Config()
    {
        return ResponseEntity.ok(
                SeetingService.GetSetting().getConfig().toString()
        );
    }

}
