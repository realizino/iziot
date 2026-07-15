package com.sorapp.jowncms.jowncms.Controllers.Admin;

import com.fasterxml.jackson.databind.ObjectMapper;
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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/Admin")
public class AdminDashController
{

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



}
