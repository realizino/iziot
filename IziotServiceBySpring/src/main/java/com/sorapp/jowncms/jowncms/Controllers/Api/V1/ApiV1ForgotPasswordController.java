package com.sorapp.jowncms.jowncms.Controllers.Api.V1;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.common.hash.Hashing;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Service.UserVerify.UserVerify_Service;
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
public class ApiV1ForgotPasswordController
{

    @Autowired
    Users_Service UserService;

    @Autowired
    UserVerify_Service UserVerifyService;


    @PostMapping("FrogetPassword")
    public ResponseEntity<Map<String, Object>> ForgetPassOne(@RequestParam String email) throws JsonProcessingException
    {
        Map<String, Object> response = new HashMap<>();

        //Get Check user exist
        users_tbl USER = UserService.GetUserByEmail(email);
        if(USER != null)
        {
            //Get Send Verify code
            UserVerifyService.NewUserVerifyCode(USER);

            response.put("status","200");
            response.put("message","user found.Mail sended");
            response.put("token",USER.getLogin_token());
        }
        else
        {
            response.put("status","403");
            response.put("message","user not found");
        }


        return ResponseEntity.ok(response);
    }


//    @PostMapping("SignupVerify")
//    public ResponseEntity<Map<String, Object>> ForgetPassTwo(@RequestParam String v_code,@RequestParam String ut) throws JsonProcessingException
//    {
//        Map<String, Object> response = new HashMap<>();
//
//        //Get Check user exist
//        users_tbl USER = UserService.GetUserByToken(ut);
//        if(USER != null)
//        {
//            //Get Send Verify code
//            boolean CheckVerify = UserVerifyService.CheckVerifyCode(v_code,USER.getId());
//
//            if(CheckVerify) {
//                response.put("status", "200");
//                response.put("message", "OK");
//            }else{
//                response.put("status","403");
//                response.put("message","user not found");
//            }
//        }
//        else
//        {
//            response.put("status","403");
//            response.put("message","user not found");
//        }
//
//
//        return ResponseEntity.ok(response);
//    }


    @PostMapping("ResetPassword")
    public ResponseEntity<Map<String, Object>> ForgetPassThree(@RequestParam String password,@RequestParam String repassword,@RequestParam String ut) throws JsonProcessingException
    {
        Map<String, Object> response = new HashMap<>();

        //Get Check user exist
        users_tbl USER = UserService.GetUserByToken(ut);
        if(USER != null)
        {
            //Get Reset password
            UserService.UpdateUserPassword(USER.getId(),password);

            response.put("status","200");
            response.put("message","user found.Mail sended");
            response.put("token",USER.getLogin_token());
        }
        else
        {
            response.put("status","403");
            response.put("message","user not found");
        }


        return ResponseEntity.ok(response);
    }


}
