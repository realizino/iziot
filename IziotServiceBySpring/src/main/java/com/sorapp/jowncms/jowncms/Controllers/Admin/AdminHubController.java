package com.sorapp.jowncms.jowncms.Controllers.Admin;

import com.sorapp.jowncms.jowncms.Function.Encript.EncriptService;
import com.sorapp.jowncms.jowncms.Function.Render.Render;
import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
import com.sorapp.jowncms.jowncms.Models.Database.city_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Concepts.IFileUpload;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Service.City.City_Service;
import com.sorapp.jowncms.jowncms.Service.File.IOTFile_Service;
import com.sorapp.jowncms.jowncms.Service.IOTToken.IOTToken;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/Admin")
public class AdminHubController
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

    @Value("${ServerPassword}")
    String ServerPassword;

    private final GoogleAuthenticator gAuth;




    /*************************Add hub Start**************************/
    @RequestMapping("/Panel/AddHub")
    public ModelAndView AddHub(HttpServletRequest request)
    {
        List<city_tbl> Cites=City_Services.GetCites();

        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/addhub");
        response.addObject("user_data", AdminAuthCheckMiddleware.user_data);
        response.addObject("cites",Cites);
        return response;
    }


    @RequestMapping(value = "/Panel/AddHubDone", method = RequestMethod.POST)
    public ModelAndView AddHubDone(HttpServletRequest request, String serial_number, String title, String iot_type, String iot_model, String status, String resolution, String admin_number, String ip_address, String username, String password, String lat, String lng, String timezone, String attribute_inpt)
    {
        users_tbl USER = AdminAuthCheckMiddleware.user_data;

        ModelAndView response = new ModelAndView();
        response.setViewName("Admin/addhub");
        response.addObject("user_data", AdminAuthCheckMiddleware.user_data);

        //new hub model start
        hub_tbl n_hun = new hub_tbl();
        n_hun.setSerial_number(serial_number);
        n_hun.setTitle(title);
        n_hun.setIot_model(iot_model);
        n_hun.setIot_type(iot_type);
        n_hun.setStatus(status);
        n_hun.setLat(lat);
        n_hun.setLng(lng);
        n_hun.setAdmin_mobile(admin_number);
        n_hun.setIp_address(ip_address);

        if (iot_model != null && iot_model.toUpperCase().contains("CAM")) {
            n_hun.setDefault_resolution(resolution);
        } else {
            n_hun.setDefault_resolution("-");
        }

        n_hun.setTimezone(timezone);
        n_hun.setAttribute(attribute_inpt);
        n_hun.setUsername(username);
        n_hun.setPassword(password);
        n_hun.setPermission("");
        n_hun.setCreated_at(LocalDate.now().getYear() + "-" + LocalDate.now().getMonth() + "-" + LocalDate.now().getDayOfMonth() + " " + LocalTime.now().getHour() + ":" + LocalTime.now().getMinute());
        n_hun.setUpdated_at(LocalDate.now().getYear() + "-" + LocalDate.now().getMonth() + "-" + LocalDate.now().getDayOfMonth() + " " + LocalTime.now().getHour() + ":" + LocalTime.now().getMinute());

        if (iot_model.contains("NEWPROTOCOL"))
            n_hun.setUrl("");
        else
            n_hun.setUrl(ip_address + "/snapshop.jpg");
        //new hub model end

        n_hun.setUser_id(USER);

        Hub_Service.AddNewHub(n_hun);
        IotFileService.CreateHubDirectory(Repository, n_hun.getId() + "");

        return response;
    }

    @RequestMapping("/Panel/Hubs")
    public ModelAndView Hubs(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/hubs");
        response.addObject("user_data",AdminAuthCheckMiddleware.user_data);
        response.addObject("hubs", Hub_Service.GetAllHubs());
        response.addObject("IOTToken", new IOTToken());
        return response;
    }

    @RequestMapping("/Panel/Hub/{hub_id}")
    public ModelAndView Hub(HttpServletRequest request,@PathVariable String hub_id)
    {
        List<city_tbl> Cites=City_Services.GetCites();

        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/hub");
        response.addObject("user_data",AdminAuthCheckMiddleware.user_data);
        response.addObject("cites",Cites);
        response.addObject("hub", Hub_Service.GetHub(Integer.parseInt(hub_id)));
        return response;
    }


    @RequestMapping("/Panel/GetTimeLaps/{hub_id}")
    public String GetTimeLaps(HttpServletRequest request, @PathVariable String hub_id) throws Exception
    {
        try
        {
            //LocalDateTime CurrentDateTime = LocalDateTime.now();

            hub_tbl hub = Hub_Service.GetHub(Integer.parseInt(hub_id));

            ZonedDateTime CurrentDateTime = ZonedDateTime.now(ZoneId.of(hub.getTimezone()));
            String year = String.format("%04d", CurrentDateTime.getYear());
            String month = CurrentDateTime.getMonth().toString();
            String day = String.format("%02d", CurrentDateTime.getDayOfMonth());
            String hour = String.format("%02d", CurrentDateTime.getHour()); // 24-hour format (00-23)
            String minute = String.format("%02d", CurrentDateTime.getMinute());
            String second = String.format("%02d", CurrentDateTime.getSecond());

            String resolution[] = hub.getDefault_resolution().split("×");

            String PresentDirAddress=FileManager+"/Present/Snapshots/Snapshots"+year+""+month+""+day+"/"+resolution[0]+"/"+hub.getSerial_number();

            new Thread(new Runnable() {
                @Override
                public void run() {
                    new Render().GetRenderTimeLaps(PresentDirAddress,hub.getSerial_number()+".mp4","420",ServerPassword);
                }
            }).start();

            //Thread.sleep(100000);
//            String currentDir = System.getProperty("user.dir");
//            PresentDirAddress=currentDir+"\\"+PresentDirAddress;

//            File file = new File(PresentDirAddress+"/"+"out.mp4");
//            System.out.println(PresentDirAddress);

//            InputStreamResource resource = new InputStreamResource(new FileInputStream(file.getAbsoluteFile()));

//            return ResponseEntity.ok()
//                    .contentLength(file.length())
//                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
//                    .body(resource);

            return "redirect:/Admin/Panel/DonePnl";
        }
        catch (Exception e)
        {
            return "redirect:/Admin/Panel/notdonepnl";
        }
    }


    @RequestMapping("/Panel/GetTimeLaps/{hub_id}/{ex_day}")
    public String GetTimeLaps(HttpServletRequest request, @PathVariable String hub_id,@PathVariable String ex_day) throws Exception
    {
        try
        {
            //LocalDateTime CurrentDateTime = LocalDateTime.now();
            hub_tbl hub = Hub_Service.GetHub(Integer.parseInt(hub_id));

            ZonedDateTime currentDateTime = ZonedDateTime.now(ZoneId.of(hub.getTimezone()));
            try
            {
                int daysToSubtract = Integer.parseInt(ex_day);
                currentDateTime = currentDateTime.minusDays(daysToSubtract);
            } catch (NumberFormatException e)
            {
                System.err.println("ex_day is not a valid number: " + ex_day);
            }
            String year = String.format("%04d", currentDateTime.getYear());
            String month = currentDateTime.getMonth().toString();
            String day = String.format("%02d", currentDateTime.getDayOfMonth());
            String hour = String.format("%02d", currentDateTime.getHour()); // 24-hour format (00-23)
            String minute = String.format("%02d", currentDateTime.getMinute());
            String second = String.format("%02d", currentDateTime.getSecond());


            String resolution[] = hub.getDefault_resolution().split("×");

            String PresentDirAddress=FileManager+"/Present/Snapshots/Snapshots"+year+""+month+""+day+"/"+resolution[0]+"/"+hub.getSerial_number();

            new Thread(new Runnable() {
                @Override
                public void run() {
                    new Render().GetRenderTimeLaps(PresentDirAddress,hub.getSerial_number()+".mp4","420",ServerPassword);
                }
            }).start();

            return "redirect:/Admin/Panel/DonePnl";
        }
        catch (Exception e)
        {
            return "redirect:/Admin/Panel/notdonepnl";
        }
    }


    @RequestMapping("/Panel/GetVideo/{hub_id}")
    public String GetVideo(HttpServletRequest request, @PathVariable String hub_id) throws Exception
    {
        try
        {
            //LocalDateTime CurrentDateTime = LocalDateTime.now();

            hub_tbl hub = Hub_Service.GetHub(Integer.parseInt(hub_id));

            ZonedDateTime CurrentDateTime = ZonedDateTime.now(ZoneId.of(hub.getTimezone()));
            String year = String.format("%04d", CurrentDateTime.getYear());
            String month = CurrentDateTime.getMonth().toString();
            String day = String.format("%02d", CurrentDateTime.getDayOfMonth());
            String hour = String.format("%02d", CurrentDateTime.getHour()); // 24-hour format (00-23)
            String minute = String.format("%02d", CurrentDateTime.getMinute());
            String second = String.format("%02d", CurrentDateTime.getSecond());

            String resolution[] = hub.getDefault_resolution().split("×");

            String PresentDirAddress=FileManager+"/Present/Snapshots/Snapshots"+year+""+month+""+day+"/"+resolution[0]+"/"+hub.getSerial_number();

            new Thread(new Runnable() {
                @Override
                public void run() {
                    new Render().GetRenderVideo(PresentDirAddress,hub.getSerial_number()+"_video.mp4","420",ServerPassword);
                }
            }).start();

            //Thread.sleep(100000);
//            String currentDir = System.getProperty("user.dir");
//            PresentDirAddress=currentDir+"\\"+PresentDirAddress;

//            File file = new File(PresentDirAddress+"/"+"out.mp4");
//            System.out.println(PresentDirAddress);

//            InputStreamResource resource = new InputStreamResource(new FileInputStream(file.getAbsoluteFile()));

//            return ResponseEntity.ok()
//                    .contentLength(file.length())
//                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
//                    .body(resource);

            return "redirect:/Admin/Panel/DonePnl";
        }
        catch (Exception e)
        {
            return "redirect:/Admin/Panel/notdonepnl";
        }
    }


    @RequestMapping("/Panel/GetVideo/{hub_id}/{ex_day}")
    public String GetVideo(HttpServletRequest request, @PathVariable String hub_id,@PathVariable String ex_day) throws Exception
    {
        try
        {
            //LocalDateTime CurrentDateTime = LocalDateTime.now();

            hub_tbl hub = Hub_Service.GetHub(Integer.parseInt(hub_id));
            ZonedDateTime currentDateTime = ZonedDateTime.now(ZoneId.of(hub.getTimezone()));
            try
            {
                int daysToSubtract = Integer.parseInt(ex_day);
                currentDateTime = currentDateTime.minusDays(daysToSubtract);
            } catch (NumberFormatException e)
            {
                System.err.println("ex_day is not a valid number: " + ex_day);
            }
            String year = String.format("%04d", currentDateTime.getYear());
            String month = currentDateTime.getMonth().toString();
            String day = String.format("%02d", currentDateTime.getDayOfMonth());
            String hour = String.format("%02d", currentDateTime.getHour()); // 24-hour format (00-23)
            String minute = String.format("%02d", currentDateTime.getMinute());
            String second = String.format("%02d", currentDateTime.getSecond());

            String resolution[] = hub.getDefault_resolution().split("×");

            String PresentDirAddress=FileManager+"/Present/Snapshots/Snapshots"+year+""+month+""+day+"/"+resolution[0]+"/"+hub.getSerial_number();

            new Thread(new Runnable() {
                @Override
                public void run() {
                    new Render().GetRenderVideo(PresentDirAddress,hub.getSerial_number()+"_video.mp4","420",ServerPassword);
                }
            }).start();

            //Thread.sleep(100000);
//            String currentDir = System.getProperty("user.dir");
//            PresentDirAddress=currentDir+"\\"+PresentDirAddress;

//            File file = new File(PresentDirAddress+"/"+"out.mp4");
//            System.out.println(PresentDirAddress);

//            InputStreamResource resource = new InputStreamResource(new FileInputStream(file.getAbsoluteFile()));

//            return ResponseEntity.ok()
//                    .contentLength(file.length())
//                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
//                    .body(resource);

            return "redirect:/Admin/Panel/DonePnl";
        }
        catch (Exception e)
        {
            return "redirect:/Admin/Panel/notdonepnl";
        }
    }


    @RequestMapping(value = "/Panel/Hub/Update", method = RequestMethod.POST)
    public ModelAndView HubUpdate(HttpServletRequest request, String hub_id, String serial_number, String title, String iot_type, String iot_model, String status, String resolution, String admin_number, String ip_address, String username, String password, String lat, String lng, String timezone, String attribute_inpt) {

        System.out.println("hub id is : " + hub_id);

        ModelAndView response = new ModelAndView();
        response.setViewName("Admin/hub");

        //new hub model start
        hub_tbl n_hun = new hub_tbl();
        n_hun.setId(Integer.parseInt(hub_id));
        n_hun.setSerial_number(serial_number);
        n_hun.setTitle(title);
        n_hun.setIot_model(iot_model);
        n_hun.setIot_type(iot_type);
        n_hun.setStatus(status);
        n_hun.setLat(lat);
        n_hun.setLng(lng);
        n_hun.setAdmin_mobile(admin_number);
        n_hun.setIp_address(ip_address);

        if (iot_model != null && iot_model.toUpperCase().contains("CAM")) {
            n_hun.setDefault_resolution(resolution);
        } else {
            n_hun.setDefault_resolution("-");
        }

        n_hun.setTimezone(timezone);
        n_hun.setUsername(username);
        n_hun.setPassword(password);
        n_hun.setAttribute(attribute_inpt);
        n_hun.setPermission("");
        n_hun.setUpdated_at(LocalDate.now().getYear() + "-" + LocalDate.now().getMonth() + "-" + LocalDate.now().getDayOfMonth() + " " + LocalTime.now().getHour() + ":" + LocalTime.now().getMinute());
        n_hun.setUrl(ip_address + "/snapshop.jpg");

        Hub_Service.UpdateHub(n_hun);
        //new hub model end

        List<city_tbl> Cites = City_Services.GetCites();

        response.addObject("user_data", AdminAuthCheckMiddleware.user_data);
        response.addObject("cites", Cites);
        response.addObject("hub", Hub_Service.GetHub(Integer.parseInt(hub_id)));

        return response;
    }
    /*************************Add hub End**************************/



}
