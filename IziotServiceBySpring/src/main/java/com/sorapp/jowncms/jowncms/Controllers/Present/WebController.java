package com.sorapp.jowncms.jowncms.Controllers.Present;

import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.location_tbl;
import com.sorapp.jowncms.jowncms.SMTP.Mail;
import com.sorapp.jowncms.jowncms.Service.Hubs.Hub_Service;
import com.sorapp.jowncms.jowncms.Service.Images.Images_Service;
import com.sorapp.jowncms.jowncms.Service.Location.Location_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import org.springframework.core.io.Resource;

@Controller
public class WebController
{

    @Autowired
    Hub_Service HubSerivce;

    @Autowired
    Location_Service LocationService;

    @Autowired
    Mail mail;

    @Autowired
    Images_Service ImageService;




    //Get index
    @RequestMapping("/")
    public ModelAndView Index()
    {
        ModelAndView result=new ModelAndView();
        result.setViewName("Web/index");

        return result;
    }

    //Get hub empty
    @RequestMapping("/Hub")
    public ModelAndView Hub()
    {
        ModelAndView result=new ModelAndView();
        result.setViewName("Web/player");
        result.addObject("hub_serial","0");
        return result;
    }

    //Get hub by serial number
    @RequestMapping("/Hub/{hub_serial}")
    public ModelAndView Hub(@PathVariable String hub_serial)
    {
        try
        {
            hub_tbl hub = HubSerivce.GetHubBySerial(hub_serial);

            if (hub.getStatus().equals("Enable"))
            {
                ModelAndView result=new ModelAndView();
                //Get GPS equipped hub (Neo M6 / SIM800C) start
                if (hub.getAttribute().contains("Neo M6"))
                {
                    result.setViewName("Web/maps");
                    result.addObject("hub_serial", hub.getSerial_number());
                    result.addObject("hub_title", hub.getTitle());

                    // This device class (Neo M6 GPS tracker) is always ESP32-CAM based,
                    // so the camera snapshot panel is always shown for it.
                    // If some Neo M6 units ship without a camera, switch this to an
                    // actual attribute/model check instead.
                    result.addObject("hub_has_camera", true);

                    //Get last known location for the initial render
                    boolean hasLocation;
                    try
                    {
                        location_tbl last_loc = LocationService.GetLocationBySerial(hub_serial);
                        result.addObject("lat", last_loc.getLat());
                        result.addObject("lng", last_loc.getLng());
                        hasLocation = true;
                    }
                    catch (Exception e)
                    {
                        //No location recorded yet, fall back to the hub's registered lat/lng
                        //if it has one, otherwise there's genuinely nothing to show on the map.
                        if (hub.getLat() != null && hub.getLng() != null)
                        {
                            result.addObject("lat", hub.getLat());
                            result.addObject("lng", hub.getLng());
                            hasLocation = true;
                        }
                        else
                        {
                            result.addObject("lat", 0);
                            result.addObject("lng", 0);
                            hasLocation = false;
                        }
                    }
                    result.addObject("hub_has_location", hasLocation);
                    return result;
                }
                //Get GPS equipped hub (Neo M6 / SIM800C) end
                if(hub.getAttribute().contains("RealTime")) {
                    result.setViewName("Web/playervideo");
                }
                else{
                    result.setViewName("Web/player");
                }
                result.addObject("hub_serial",hub.getSerial_number());
                return result;
            }
            else
            {
                return new ModelAndView("redirect:/Hub");
            }
        }
        catch (Exception e)
        {
            return new ModelAndView("redirect:/Hub");
        }

    }


    //Get latest GPS location as JSON (used by Web/maps.html to move the live marker)
    @GetMapping("/api/hub-location/{hub_serial}")
    @ResponseBody
    public String HubLocation(@PathVariable String hub_serial)
    {
        try
        {
            location_tbl last_loc = LocationService.GetLocationBySerial(hub_serial);

            return "{\"status\":\"success\",\"lat\":\"" + last_loc.getLat() + "\",\"lng\":\"" + last_loc.getLng() + "\",\"date_time\":\"" + last_loc.getDate_time() + "\"}";
        }
        catch (Exception e)
        {
            return "{\"status\":\"error\"}";
        }
    }


    //Get the last 24 hours movement trail as JSON (used by Web/maps.html to draw the path)
    @GetMapping("/api/hub-location-history/{hub_serial}")
    @ResponseBody
    public String HubLocationHistory(@PathVariable String hub_serial)
    {
        try
        {
            List<location_tbl> history = LocationService.GetLast24HoursLocations(hub_serial);

            StringBuilder json = new StringBuilder();
            json.append("{\"status\":\"success\",\"points\":[");

            for (int i = 0; i < history.size(); i++)
            {
                location_tbl loc = history.get(i);
                json.append("{\"lat\":\"").append(loc.getLat())
                        .append("\",\"lng\":\"").append(loc.getLng())
                        .append("\",\"date_time\":\"").append(loc.getDate_time())
                        .append("\"}");

                if (i < history.size() - 1)
                {
                    json.append(",");
                }
            }

            json.append("]}");
            return json.toString();
        }
        catch (Exception e)
        {
            return "{\"status\":\"error\",\"points\":[]}";
        }
    }


    //Get the most recent camera snapshot for a hub, served as raw JPEG bytes
    //(used by Web/maps.html for the camera panel + zoomable lightbox)
    @GetMapping("/api/hub-snapshot/{serial}")
    public ResponseEntity<Resource> GetHubSnapshot(@PathVariable String serial) throws Exception
    {
        File file = new File(ImageService.GetLastImageBySerialNumber(serial).getFile_address());

        InputStreamResource resource = new InputStreamResource(new FileInputStream(file.getAbsoluteFile()));

        return ResponseEntity.ok()
                .contentLength(file.length())
                .contentType(MediaType.IMAGE_JPEG)
                .body(resource);
    }

}