package com.sorapp.jowncms.jowncms.Controllers.Hub;

import com.sorapp.jowncms.jowncms.Models.Database.airquality_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.images_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.temperatures_tbl;
import com.sorapp.jowncms.jowncms.Models.Response.LoadResponse_Model;
import com.sorapp.jowncms.jowncms.Models.Response.TempreturesResponse_Model;
import com.sorapp.jowncms.jowncms.Models.Response.ValueResponse_Model;
import com.sorapp.jowncms.jowncms.Service.AirQuality.AirQuality_Service;
import com.sorapp.jowncms.jowncms.Service.Hubs.Hub_Service;
import com.sorapp.jowncms.jowncms.Service.Images.Images_Service;
import com.sorapp.jowncms.jowncms.Service.Tempreture.Tempreture_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api")
public class CamApiController
{

    //Global variables
    @Autowired
    Hub_Service HubService;

    @Autowired
    Tempreture_Service TempretureService;

    @Autowired
    AirQuality_Service AirQualityService;

    @Autowired
    Images_Service ImageService;



    //Get last tempreture
    @RequestMapping("/tempreture/{hub_serial}")
    public ValueResponse_Model tempreture(HttpServletRequest request, @PathVariable String hub_serial) throws Exception
    {
        temperatures_tbl data = TempretureService.GetTempretureBySerial(hub_serial);
        return new ValueResponse_Model("\uD83C\uDF21"+data.getTemperature());
    }


    //Get last air quality
    @RequestMapping("/airq/{hub_serial}")
    public ValueResponse_Model airquality(HttpServletRequest request, @PathVariable String hub_serial) throws Exception
    {
        airquality_tbl data = AirQualityService.GetValueBySerial(hub_serial);
        return new ValueResponse_Model("\uD83C\uDF21"+data.getValue());
    }


    //Get last image
    @RequestMapping("/last_img/{hub_serial}/{counter}")
    public ResponseEntity<Resource> LastImage(HttpServletRequest request,@PathVariable String hub_serial) throws Exception
    {
        File file = new File(ImageService.GetLastImageBySerialNumber(hub_serial).getFile_address());

        InputStreamResource resource = new InputStreamResource(new FileInputStream(file.getAbsoluteFile()));

        return ResponseEntity.ok()
                .contentLength(file.length())
                .contentType(MediaType.IMAGE_JPEG)
                .body(resource);
    }


    //Get image
    @RequestMapping("/img/{image_id}")
    public ResponseEntity<Resource> GetImage(HttpServletRequest request,@PathVariable String image_id) throws Exception
    {
        File file = new File(ImageService.GetImageByid(Integer.parseInt(image_id)).getFile_address());

        InputStreamResource resource = new InputStreamResource(new FileInputStream(file.getAbsoluteFile()));

        return ResponseEntity.ok()
                .contentLength(file.length())
                .contentType(MediaType.IMAGE_JPEG)
                .body(resource);
    }


    //Get last tempreture
    @RequestMapping("/hub/{hub_serial}")
    public LoadResponse_Model GetHub(HttpServletRequest request,@PathVariable String hub_serial) throws Exception
    {
        try {
            try {
                hub_tbl hub = HubService.GetHubBySerial(hub_serial);
                ImageService.GetLastImageBySerialNumber(hub.getSerial_number());
                String tempreture = TempretureService.GetTempretureBySerial(hub.getSerial_number()).getTemperature();

                String airquality="";
                try
                {
                    airquality = AirQualityService.GetValueBySerial(hub.getSerial_number()).getValue();
                    airquality=(airquality.equals("1")?"\uD83C\uDF2C\uFE0F Good Air Quality":"\uD83C\uDF2B\uFE0F Poor Air Quality");
                }
                catch (Exception e)
                {

                }

                return new LoadResponse_Model("OK", "\uD83C\uDF21"+tempreture,airquality);
            } catch (Exception e) {
                return new LoadResponse_Model("nosignal", "","");
            }
        } catch (Exception e) {
            return new LoadResponse_Model("noaccess", "","");
        }
    }


    //Get last day images
    @RequestMapping("/last-day-images/{hub_serial}")
    public String GetLastDayImages(HttpServletRequest request,@PathVariable String hub_serial) throws Exception
    {
        hub_tbl Hub = HubService.GetHubBySerial(hub_serial);

//        if(Hub.getIot_model().contains("NEWPROTOCOL"))
//        {
//
//            //Get rate of all images in a day
//            int rate = ImageService.GetCountOfImagesInADay(hub_serial) / 24;
//
//            List<images_tbl> images = ImageService.GetRandomImagesFromToDay(hub_serial,rate);
//            String ss = "";
//            for (int i = 0; i < images.size(); i++) {
//                ss += "<img src='/api/img/" + images.get(i).getId() + "'/>";
//            }
//            return ss;
//        }
//        else
//        {
//            List<images_tbl> images = ImageService.GetRandomImagesFromToDay(hub_serial);
//            String ss = "";
//            for (int i = 0; i < images.size(); i++) {
//                ss += "<img src='/api/img/" + images.get(i).getId() + "'/>";
//            }
//            return ss;
//        }

        //Get rate of all images in a day
        List<images_tbl> images = ImageService.Get24Image(hub_serial);
        String ss = "";
        for (int i = 0; i < images.size(); i++) {
            ss += "<img src='/api/img/" + images.get(i).getId() + "'/>";
        }
        return ss;
    }


    //Get last day images
    @RequestMapping("/last-day-temp/{hub_serial}")
    public List<TempreturesResponse_Model> Get24Tempretures(HttpServletRequest request,@PathVariable String hub_serial) throws Exception
    {
        if(request.getHeader("auth").toString().equals("@Kfvbfdvb--6-565cdscsdcjh@vdfjkvbkdfj") && (request.getHeader("referer").toUpperCase().toString().contains("LOCALHOST") || (request.getHeader("referer").toUpperCase().toString().contains("IZIOT"))))
        {
            List<temperatures_tbl> tmps = TempretureService.Get24Tempretures(hub_serial);
            List<TempreturesResponse_Model> result = new ArrayList<>();

            for (int i = 0; i < tmps.size(); i++) {
                result.add(new TempreturesResponse_Model(ChangeDateTime(tmps.get(i).getDate_time()), tmps.get(i).getTemperature().toString()));
            }

            return result;
        }
        else
        {
            throw new Exception("Empty");
        }
    }


    //Get date time format to webformat
    private String ChangeDateTime(String date)
    {
//        // Step 1: Parse the ISO 8601 date-time string
//        String isoDateTime = date;
//        DateTimeFormatter isoFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
//        LocalDateTime dateTime = LocalDateTime.parse(isoDateTime, isoFormatter);
//
//        // Step 2: Format the LocalDateTime object to the desired format
//        DateTimeFormatter desiredFormatter = DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm:ss");
//        String formattedDateTime = dateTime.format(desiredFormatter);
//
//        // Output the formatted date-time
//        //System.out.println(formattedDateTime); // Output: 08/05/2024 20:32:36
//        return formattedDateTime;

        String []datetime=date.split("T");
        String time=datetime[1].split(" ")[0];
        String []times=time.split(":");
        return times[0]+":"+times[1];
    }


}
