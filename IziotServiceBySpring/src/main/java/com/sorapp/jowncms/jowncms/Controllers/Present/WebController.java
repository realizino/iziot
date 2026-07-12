package com.sorapp.jowncms.jowncms.Controllers.Present;

import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.location_tbl;
import com.sorapp.jowncms.jowncms.SMTP.Mail;
import com.sorapp.jowncms.jowncms.Service.Hubs.Hub_Service;
import com.sorapp.jowncms.jowncms.Service.Location.Location_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import reactor.core.publisher.Flux;

import java.time.Duration;
import java.util.List;

@Controller
public class WebController
{

    @Autowired
    Hub_Service HubSerivce;

    @Autowired
    Location_Service LocationService;

    @Autowired
    Mail mail;



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

                    //Get last known location for the initial render
                    try
                    {
                        location_tbl last_loc = LocationService.GetLocationBySerial(hub_serial);
                        result.addObject("lat", last_loc.getLat());
                        result.addObject("lng", last_loc.getLng());
                    }
                    catch (Exception e)
                    {
                        //No location recorded yet, fall back to the hub's registered lat/lng
                        result.addObject("lat", hub.getLat());
                        result.addObject("lng", hub.getLng());
                    }
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

}