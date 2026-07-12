package com.sorapp.jowncms.jowncms.Controllers.Admin;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.google.common.hash.Hashing;
import com.sorapp.jowncms.jowncms.Function.Encript.EncriptService;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Concepts.IFileUpload;
import com.sorapp.jowncms.jowncms.Service.City.City_Service;
import com.sorapp.jowncms.jowncms.Service.File.IOTFile_Service;
import com.sorapp.jowncms.jowncms.Service.Notification.Notification_Service;
import com.sorapp.jowncms.jowncms.Service.Setting.Setting_Service;
import com.sorapp.jowncms.jowncms.Service.UserType.UserType_Service;
import com.sorapp.jowncms.jowncms.Service.Users.Users_Service;
import com.warrenstrange.googleauth.GoogleAuthenticator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.nio.charset.StandardCharsets;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/Admin")
public class AdminLoginController
{

    @Autowired
    EncriptService Encription;

    @Autowired
    Users_Service User_Services;

    @Autowired
    City_Service City_Services;

    @Autowired
    IFileUpload FileUploadRepo;

    @Autowired
    Setting_Service Setting_Services;

    @Autowired
    UserType_Service UserType_Services;

    @Autowired
    Notification_Service Notification_Services;

    @Autowired
    com.sorapp.jowncms.jowncms.Service.Hubs.Hub_Service Hub_Service;

    @Autowired
    IOTFile_Service IotFileService;

    @Value("${FileManagerRoot}")
    String FileManager;

    @Value("${IotFileRepo}")
    String Repository;

    public static users_tbl user_data;

    private final GoogleAuthenticator gAuth;



    /*************************Login Start**************************/
    @RequestMapping("/Login")
    public ModelAndView Login(HttpServletRequest request)
    {

        //Check login cookie start
        try
        {
            String rawCookie = request.getHeader("Cookie");
            String[] rawCookieParams = rawCookie.split(";");
            for (String rawCookieNameAndValue : rawCookieParams) {
                String[] rawCookieNameAndValuePair = rawCookieNameAndValue.split("=");
                //System.out.println("Cookie name is "+rawCookieNameAndValuePair[0]);
                if (rawCookieNameAndValuePair[0].equals("auth") && !rawCookieNameAndValuePair[1].equals("")) {
                    return new ModelAndView("redirect:/Admin/Panel/Dashboard");
                }
            }
        }
        catch (Exception e)
        {

        }
        //Check login cookie end


        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/login");
        return response;
    }

    @PostMapping("/Login")
    public String Login(String username, String password, HttpServletResponse response, HttpServletRequest request)
    {
        try
        {
            String pass = Hashing.sha256().hashString(password, StandardCharsets.UTF_8).toString();
            user_data = User_Services.Login(username, pass);
            if (user_data != null)
            {
                if(user_data.getGoogle_auth().equals("")) {
                    ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
                    String json = ow.writeValueAsString(user_data);

                    //Most Change This
                    //String Berar_Token = Base64.getEncoder().encodeToString(json.getBytes());

                    String Berar_Token = Encription.ENC(json);

                    response.addCookie(new Cookie("auth", Berar_Token));
                    return "redirect:/Admin/Panel/Dashboard";
                }
                else
                {
                    request.getSession().setAttribute("lgt",user_data.getLogin_token());
                    return "redirect:/Admin/Login2F";
                }
            }
            else
            {
                return "redirect:/Admin/Login";
            }
        }
        catch (Exception e)
        {
            return "redirect:/Admin/Login";
        }
    }

    @RequestMapping("/Login2F")
    public ModelAndView Login2F(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/login2f");
        return response;
    }

    @PostMapping("/Login2F")
    public String Login2FSubmit(HttpServletRequest request,HttpServletResponse response,String twofpass) throws Exception
    {
        try
        {
            String Token = request.getSession().getAttribute("lgt").toString();
            user_data = User_Services.LoginByToken(Token);
//            boolean auth_status = gAuth.authorizeUser(user_data.getUsername(), Integer.parseInt(twofpass));
            boolean auth_status = gAuth.authorize(user_data.getGoogle_auth(), Integer.parseInt(twofpass));
            if (auth_status) {
                ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
                String json = ow.writeValueAsString(user_data);
                String Berar_Token = Encription.ENC(json);
                response.addCookie(new Cookie("auth", Berar_Token));
                request.getSession().setAttribute("lgt", null);
                return "redirect:/Admin/Panel/Dashboard";
            } else {
                request.getSession().setAttribute("lgt", null);
                return "redirect:/";
            }
        }
        catch (Exception e)
        {
            System.err.println("EEE : "+e.getMessage());
        }

        return "redirect:/";
    }
    /************************Login End**************************/





    /****************Logout Start****************/
    @RequestMapping("/Panel/Logout")
    public String Logout(HttpServletResponse response)
    {
        Cookie auth_c = new Cookie("auth",null);
        auth_c.setPath("/Admin");
        response.addCookie(auth_c);
        return "redirect:/";
    }
    /****************Logout End****************/





}
