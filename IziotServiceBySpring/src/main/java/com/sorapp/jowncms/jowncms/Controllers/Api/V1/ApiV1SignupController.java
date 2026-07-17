package com.sorapp.jowncms.jowncms.Controllers.Api.V1;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.sorapp.jowncms.jowncms.Function.Encript.EncriptService;
import com.sorapp.jowncms.jowncms.Models.Database.city_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.file_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Service.City.City_Service;
import com.sorapp.jowncms.jowncms.Service.File.File_Service;
import com.sorapp.jowncms.jowncms.Service.Hash.HashService;
import com.sorapp.jowncms.jowncms.Service.UserVerify.UserVerify_Service;
import com.sorapp.jowncms.jowncms.Service.Users.Users_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.swing.text.html.parser.Entity;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/V1")
public class ApiV1SignupController
{

    @Autowired
    Users_Service UserService;

    @Autowired
    City_Service City_Services;

    @Autowired
    File_Service FileService;

    @Autowired
    UserVerify_Service UserVerify;

    @Autowired
    EncriptService Encription;


    @PostMapping("Signup")
    public ResponseEntity<?> SignupOne(@RequestParam String username,@RequestParam String password,@RequestParam String email)
    {
        Map<String,String> result = new HashMap<>();

        LocalDateTime datetime = LocalDateTime.now();
        String time=datetime.getYear()+"/"+datetime.getMonthValue()+"/"+datetime.getDayOfMonth()+" "+datetime.getHour()+":"+datetime.getMinute()+":"+datetime.getSecond();

        city_tbl cityi = City_Services.GetCity(Integer.parseInt("1"));

        if(UserService.GetCheckUserExist(username).size()>0)
        {
            result.put("status","403");
            result.put("message","user is not valid");
            return ResponseEntity.ok(result);
        }
        else
        {
            file_tbl file = FileService.GetDefaultImage();;

            //Create new user
            users_tbl NUSER = UserService.NewUser(
                    "",
                    "",
                    username,
                    password,
                    "",
                    "",
                    email,
                    "",
                    time,
                    "USER",
                    "-1",
                    "",
                    "",
                    "",
                    file,
                    cityi
            );


            //Get create Verify code
            UserVerify.NewUserVerifyCode(NUSER);


            result.put("status","200");
            result.put("message","OK");
            result.put("device","0");
            result.put("token",NUSER.getLogin_token());
            return ResponseEntity.ok(result);
        }

    }




    @PostMapping("SignupVerify")
    public ResponseEntity<?> SignupTwo(@RequestParam String v_code,@RequestParam String ut)
    {
        Map<String,String> result = new HashMap<>();
        //Get user data
        users_tbl USER = UserService.GetUserByToken(ut);
        //get check verify code
        boolean CheckVerify = UserVerify.CheckVerifyCode(v_code,USER.getId());
        //Get Remove verify code
        UserVerify.RemoveUserVerifyCode(USER);
        if(CheckVerify)
        {
            //Get Active user
            UserService.UpdateUserStatus(USER.getId(),"1");

            result.put("status","200");
            result.put("message","OK");
        }
        else
        {
            result.put("status","403");
            result.put("message","verify code is not valid");
        }


        return ResponseEntity.ok(result);
    }




    @PostMapping("SignupSubmit")
    public ResponseEntity<?> SignupThree(@RequestParam String name,@RequestParam String family,@RequestParam String ut,@RequestParam String bio,String phone) throws JsonProcessingException
    {
        Map<String, String> result = new HashMap<>();

        if(!name.isEmpty() && !family.isEmpty() && !phone.isEmpty()) {

            //Get user data
            users_tbl USER = UserService.GetUserByToken(ut);

            //Get Update user
            UserService.UpdateUserForm(USER.getId(),
                    name,
                    family,
                    phone,
                    bio
            );

            ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
            String json = ow.writeValueAsString(USER);
            String Token = Encription.ENC(json);

            result.put("status","200");
            result.put("message","OK");
            result.put("token",Token);
        }
        else {
            result.put("status","403");
            result.put("message","fill all feilds");
        }


        return ResponseEntity.ok(result);
    }


}
