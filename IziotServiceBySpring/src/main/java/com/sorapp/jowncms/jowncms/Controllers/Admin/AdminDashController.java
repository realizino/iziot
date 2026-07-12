package com.sorapp.jowncms.jowncms.Controllers.Admin;

import com.sorapp.jowncms.jowncms.Function.Encript.EncriptService;
import com.sorapp.jowncms.jowncms.Function.Requets.Requests;
import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.settings_tbl;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.lang.management.ManagementFactory;
import java.lang.management.OperatingSystemMXBean;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/Admin")
public class AdminDashController
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





    /****************Dashboard Start****************/
    @RequestMapping("/Panel/Dashboard")
    public ModelAndView Dashboard(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();

        // Get CPU usage start
        OperatingSystemMXBean osBean = ManagementFactory.getOperatingSystemMXBean();
        if (osBean instanceof com.sun.management.OperatingSystemMXBean) {
            com.sun.management.OperatingSystemMXBean sunOsBean = (com.sun.management.OperatingSystemMXBean) osBean;
            for (int i = 0; i < 3; i++) {
                double systemCpuLoad = sunOsBean.getSystemCpuLoad() * 100;
                double processCpuLoad = sunOsBean.getProcessCpuLoad() * 100;

                // Debugging
//                System.out.println("Attempt " + (i + 1) + ": System CPU Load: " + systemCpuLoad + "%");
//                System.out.println("Attempt " + (i + 1) + ": Process CPU Load: " + processCpuLoad + "%");

                if (systemCpuLoad > 0 && processCpuLoad > 0) {
                    response.addObject("systemCpuLoad", systemCpuLoad);
                    response.addObject("processCpuLoad", processCpuLoad);
                    break;
                }

                try {
                    Thread.sleep(1000); // Wait for a second before retrying
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

            if (response.getModel().isEmpty()) {
                response.addObject("systemCpuLoad", 0.0);
                response.addObject("processCpuLoad", 0.0);
            }
        } else {
            response.addObject("systemCpuLoad", 0.0);
            response.addObject("processCpuLoad", 0.0);
        }
        // Get CPU usage end


        // Get RAM usage start
        Runtime runtime = Runtime.getRuntime();

        // Calculate the used memory
        long usedMemory = runtime.totalMemory() - runtime.freeMemory();
        long totalMemory = runtime.totalMemory();
        long maxMemory = runtime.maxMemory();

//        // Print memory usage in MB
//        System.out.println("Used Memory: " + (usedMemory / 1024 / 1024) + " MB");
//        System.out.println("Total Memory: " + (totalMemory / 1024 / 1024) + " MB");
//        System.out.println("Max Memory: " + (maxMemory / 1024 / 1024) + " MB");

        response.addObject("totalram", (totalMemory / 1024 / 1024));
        response.addObject("usageram", (usedMemory / 1024 / 1024));
        response.addObject("maxram", (maxMemory / 1024 / 1024));
        // Get RAM usage end

        // Get Storage usage start
        File root = new File("/");

        long totalSpace = root.getTotalSpace();
        long freeSpace = root.getFreeSpace();
        long usableSpace = root.getUsableSpace();

        response.addObject("storage_total", (totalSpace / 1024 / 1024 / 1024));
        response.addObject("storage_free", (freeSpace / 1024 / 1024 / 1024));
        response.addObject("storage_used", (usableSpace / 1024 / 1024 / 1024));
        // Get Storage usage end


        response.setViewName("Admin/dashboard");
        response.addObject("user_data", AdminAuthCheckMiddleware.user_data);
        return response;
    }
    /****************Dashboard End****************/





    /****************Opration done Start****************/
    @RequestMapping("/Panel/Done")
    public ModelAndView OprationDone(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/done");
        return response;
    }

    @RequestMapping("/Panel/DonePnl")
    public ModelAndView OprationPnlDone(HttpServletRequest request)
    {
        users_tbl user = User_Services.GetUser(AdminAuthCheckMiddleware.user_data.getId());

        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/donepnl");
        response.addObject("user_data",user);
        return response;
    }

    @RequestMapping("/Panel/NotDone")
    public ModelAndView OprationNotDone(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/notdone");
        return response;
    }

    @RequestMapping("/Panel/NotDonePnl")
    public ModelAndView OprationNotPnlDone(HttpServletRequest request)
    {
        users_tbl user = User_Services.GetUser(AdminAuthCheckMiddleware.user_data.getId());

        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/notdonepnl");
        response.addObject("user_data",user);
        return response;
    }
    /****************Opration done End****************/




    /****************Cites Start****************/

    @RequestMapping(value = "/Panel/Cities")
    public ModelAndView Cites(HttpServletRequest request)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/cites");
        response.addObject("user_data",AdminAuthCheckMiddleware.user_data);
        response.addObject("Cites",City_Services.GetCites());
        return response;
    }

    @RequestMapping(value = "/Panel/Cities/New",method = RequestMethod.POST)
    public String City_New(HttpServletRequest request,String name,String area,String status,String timezone)
    {
        LocalDateTime datetime = LocalDateTime.now();
        String time=datetime.getYear()+"/"+datetime.getMonthValue()+"/"+datetime.getDayOfMonth()+" "+datetime.getHour()+":"+datetime.getMinute()+":"+datetime.getSecond();

        City_Services.NewCity(name,Integer.parseInt(area),status,time,timezone);
        return "redirect:" + request.getHeader("referer");
    }

    @RequestMapping(value = "/Panel/Cities/Edit/{id}")
    public ModelAndView EditCity(HttpServletRequest request,@PathVariable String id)
    {
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/cites");
        response.addObject("user_data",AdminAuthCheckMiddleware.user_data);
        response.addObject("Cites",City_Services.GetCites());
        response.addObject("edit_city",City_Services.GetCity(Integer.parseInt(id)));
        return response;
    }

    @RequestMapping(value = "/Panel/Cities/Edit",method = RequestMethod.POST)
    public String City_Edit(HttpServletRequest request,String id,String name,String area,String status,String timezone)
    {
        LocalDateTime datetime = LocalDateTime.now();
        String time=datetime.getYear()+"/"+datetime.getMonthValue()+"/"+datetime.getDayOfMonth()+" "+datetime.getHour()+":"+datetime.getMinute()+":"+datetime.getSecond();

        City_Services.UpdateCity(Integer.parseInt(id),name,Integer.parseInt(area),status,time,timezone);
        return "redirect:" + "/Admin/Panel/Cities";
    }

    /****************Cites End****************/







    /****************Setting Start****************/

    @RequestMapping("/Panel/Settings")
    public ModelAndView Settins()
    {
        settings_tbl settings_tbl=Setting_Services.GetSetting();

        ModelAndView response=new ModelAndView();
        response.addObject("version",settings_tbl.getVersion());
        response.addObject("code",settings_tbl.getESP32CAM_Code());
        response.addObject("user_data", AdminAuthCheckMiddleware.user_data);
        response.setViewName("Admin/settings");
        return response;
    }

    @RequestMapping(value = "/Panel/Settings/Done",method = RequestMethod.POST)
    public String Settings(String esp32cam_code,String version)
    {
        Setting_Services.NewSetting(version,esp32cam_code);


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
