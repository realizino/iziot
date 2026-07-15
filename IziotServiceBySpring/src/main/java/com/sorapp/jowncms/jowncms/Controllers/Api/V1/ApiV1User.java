package com.sorapp.jowncms.jowncms.Controllers.Api.V1;

import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
import com.sorapp.jowncms.jowncms.Middleware.ApiAuthCheckMiddleware;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Service.Users.Users_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/V1")
public class ApiV1User
{

    @Autowired
    Users_Service UserService;




    @RequestMapping("/User")
    public ResponseEntity<?> User(@RequestAttribute("authenticatedUser") users_tbl user_req)
    {
        try {
            users_tbl user = UserService.GetUser(user_req.getId());
            Map<String, Object> response = new HashMap<>();

            response.put("status", "200");
            response.put("message", "OK");
            response.put("user", user);

            return ResponseEntity.ok(response);
        }
        catch (Exception e) {
            return ResponseEntity.ok("Error : "+e.getMessage());
        }
    }



}
