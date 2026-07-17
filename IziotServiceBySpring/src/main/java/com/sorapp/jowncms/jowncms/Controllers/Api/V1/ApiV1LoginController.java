package com.sorapp.jowncms.jowncms.Controllers.Api.V1;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.google.common.hash.Hashing;
import com.sorapp.jowncms.jowncms.Function.Encript.EncriptService;
import com.sorapp.jowncms.jowncms.Service.Users.Users_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/V1")
public class ApiV1LoginController
{

    @Autowired
    Users_Service UserService;

    @Autowired
    EncriptService Encription;



    @PostMapping("Login")
    public ResponseEntity<Map<String, Object>> Login(@RequestParam String username,@RequestParam String password) throws JsonProcessingException
    {
        String pass = Hashing.sha256().hashString(password, StandardCharsets.UTF_8).toString();

        var result = UserService.Login(username,pass);

        Map<String, Object> response = new HashMap<>();

        if(result!=null){

            ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
            String json = ow.writeValueAsString(result);
            String Token = Encription.ENC(json);

            response.put("status", "200");
            response.put("message", "user found");
            response.put("token", Token);
        }else {
            response.put("status", "403");
            response.put("message", "user not found");
        }

        return ResponseEntity.ok(response);
    }

}
