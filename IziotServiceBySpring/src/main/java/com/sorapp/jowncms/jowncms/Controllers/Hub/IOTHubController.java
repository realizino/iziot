package com.sorapp.jowncms.jowncms.Controllers.Hub;

import com.sorapp.jowncms.jowncms.Models.Database.airquality_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.images_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.location_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.temperatures_tbl;
import com.sorapp.jowncms.jowncms.Service.AirQuality.AirQuality_Service;
import com.sorapp.jowncms.jowncms.Service.Hubs.Hub_Service;
import com.sorapp.jowncms.jowncms.Service.IOTToken.IOTToken_Model;
import com.sorapp.jowncms.jowncms.Service.Images.Images_Service;
import com.sorapp.jowncms.jowncms.Service.Location.Location_Service;
import com.sorapp.jowncms.jowncms.Service.Tempreture.Tempreture_Service;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.List;

@RestController
@RequestMapping("/NProtocol/api")
public class IOTHubController
{

    //Global variables
    hub_tbl Hub;

    //Global variables
    List<hub_tbl> RamHubs;

    boolean is_running = false;

    @Autowired
    Hub_Service HubService;

    @Autowired
    Tempreture_Service Tempreture;

    @Autowired
    AirQuality_Service AirQuality;

    @Autowired
    Images_Service Images;

    @Autowired
    Location_Service Location;

    @Autowired
    Hub_Service IOTHubService;

    @Value("${FileManagerRoot}")
    String FileManager;


    //Get receive image
    @PostMapping("/UploadImage")
    public ResponseEntity<String> UploadSnapshot(@RequestHeader("HubFlag") String HubFlag, @RequestParam("snapshot") MultipartFile snapshot)
    {
        System.out.println("New Image Request");
        if(GetHubData(HubFlag))
        {
            if (Hub.getStatus().equals("Enable") || Hub.getStatus().equals("Poor")) {
                boolean upload_status = false;
                try {
                    upload_status = UploadImage(Hub.getId(),
                            snapshot,
                            Hub.getSerial_number(),
                            Hub.getTitle(),
                            Hub.getLat(),
                            Hub.getLng(),
                            Hub.getTimezone(),
                            Hub.getDefault_resolution()
                    );


                    //Get enable hub status when poor
                    if (Hub.getStatus().equals("Poor"))
                    {
                        hub_tbl PoorHub = HubService.GetHub(Hub.getId());
                        PoorHub.setStatus("Enable");
                        HubService.UpdateHub(PoorHub);
                    }

                } catch (Exception e) {
                    System.err.println("Error : "+e.getMessage());
                }
                if (upload_status) {
                    return ResponseEntity.ok().body("{\"status\":\"success\"}");
                } else {
                    return ResponseEntity.ok().body("{\"status\":\"rejected\"}");
                }
            } else {
                return ResponseEntity.status(403).body("{\"status\":\"error\", \"message\":\"Access denied\"}");
            }
        }
        else
        {
            return ResponseEntity.status(403).body("{\"status\":\"error\", \"message\":\"Access denied\"}");
        }
    }



    //Get receive tempreture
    @PostMapping("/Temp")
    public ResponseEntity<String> AddTemp(@RequestHeader("HubFlag") String HubFlag, @RequestParam("temp") String temp)
    {
        if(GetHubData(HubFlag)) {

            if (Hub.getStatus().equals("Enable") || Hub.getStatus().equals("Poor")) {
                //Get add new tempreture
                AddNewTempreture(Hub.getId(), temp, Hub.getTimezone());
                return ResponseEntity.ok().body("{\"status\":\"success\"}");
            } else {
                return ResponseEntity.ok().body("{\"status\":\"rejected\"}");
            }
        }
        else
        {
            return ResponseEntity.status(403).body("{\"status\":\"error\", \"message\":\"Access denied\"}");
        }
    }



    //Get receive Air Quality
    @PostMapping("/AirQ")
    public ResponseEntity<String> AddAirQ(@RequestHeader("HubFlag") String HubFlag, @RequestParam("airQ") String airQ)
    {
        if(GetHubData(HubFlag)) {

            if (Hub.getStatus().equals("Enable") || Hub.getStatus().equals("Poor")) {
                AddNewAirQuality(Hub.getId(), airQ);
                return ResponseEntity.ok().body("{\"status\":\"success\"}");
            } else {
                return ResponseEntity.ok().body("{\"status\":\"rejected\"}");
            }
        }
        else
        {
            return ResponseEntity.status(403).body("{\"status\":\"error\", \"message\":\"Access denied\"}");
        }
    }



    //Get receive Location (GPS: Neo M6 / SIM800C)
    @PostMapping("/Loc")
    public ResponseEntity<String> AddLoc(@RequestHeader("HubFlag") String HubFlag, @RequestParam("loc") String loc)
    {
        System.out.println("Loc : "+loc);
        if(GetHubData(HubFlag)) {

            if (Hub.getStatus().equals("Enable") || Hub.getStatus().equals("Poor")) {
                AddNewLocation(Hub.getId(), loc, Hub.getTimezone());
                return ResponseEntity.ok().body("{\"status\":\"success\"}");
            } else {
                return ResponseEntity.ok().body("{\"status\":\"rejected\"}");
            }
        }
        else
        {
            return ResponseEntity.status(403).body("{\"status\":\"error\", \"message\":\"Access denied\"}");
        }
    }







    /************************************************************************************/



    //Get download image
    private boolean UploadImage(int hub_id,MultipartFile snapshot,String serial_number,String hubtitle,String lat,String lng,String timezone,String default_resolution) throws Exception
    {

        //Get check file
        if (snapshot.isEmpty())
        {
            return false;
        }


        //Get resoltion
        String resoultion[]=default_resolution.split("×");

        ZonedDateTime CurrentDateTime = ZonedDateTime.now(ZoneId.of(timezone));


        // Format time components with leading zeros
        String year = String.format("%04d", CurrentDateTime.getYear());
        String month = CurrentDateTime.getMonth().toString();
        String day = String.format("%02d", CurrentDateTime.getDayOfMonth());
        String hour = String.format("%02d", CurrentDateTime.getHour()); // 24-hour format (00-23)
        String minute = String.format("%02d", CurrentDateTime.getMinute());
        String second = String.format("%02d", CurrentDateTime.getSecond());

//        // Repository path
//        String localDirPath = "Repository/Snapshots/Snapshots" + year + month + day + "/" + serial_number + "/";
//        String localFilePath = localDirPath + hour + minute + second + ".jpg";
//
//        // Default resolution
//        String localDirPathDefRes = "Present/Snapshots/Snapshots" + year + month + day + "/" + resoultion[0] + "/" + serial_number + "/";
//        String localFilePathDefRes = localDirPathDefRes + hour + minute + second + ".jpg";
//
//        // 160 resolution
//        String localDirPath160 = "Present/Snapshots/Snapshots" + year + month + day + "/160/" + serial_number + "/";
//        String localFilePath160 = localDirPath160 + hour + minute + second + ".jpg";

        String localDirPath = FileManager+"/Repository/Snapshots/Snapshots" + year + month + day + "/" + serial_number + "/";
        String localFilePath = localDirPath + hour + minute + second + ".jpg";

        // Default resolution
        String localDirPathDefRes = FileManager+"/Present/Snapshots/Snapshots" + year + month + day + "/" + resoultion[0] + "/" + serial_number + "/";
        String localFilePathDefRes = localDirPathDefRes + hour + minute + second + ".jpg";

        // 160 resolution
        String localDirPath160 = FileManager+"Present/Snapshots/Snapshots" + year + month + day + "/160/" + serial_number + "/";
        String localFilePath160 = localDirPath160 + hour + minute + second + ".jpg";


        File FilesRepo=new File(localDirPath);
        FilesRepo.mkdirs();

        /*File FilesRepo480=new File(localDirPath480);
        FilesRepo480.mkdirs();*/
        File FilesRepoDefRes=new File(localDirPathDefRes);
        FilesRepoDefRes.mkdirs();

        File FilesRepo160=new File(localDirPath160);
        FilesRepo160.mkdirs();


        /************************/
        Files.write(Path.of(localFilePath), snapshot.getBytes());
        /************************/


        String mon_name=new String(CapitalizeFirstLetter(CurrentDateTime.getMonth().name().toString()));
        String day_week=new String(CapitalizeFirstLetter(CurrentDateTime.getDayOfWeek().name().toString()));

        String DateString=day_week.substring(0,3) + "," + mon_name.substring(0,3)+ " " + CurrentDateTime.getDayOfMonth() + " " +  CurrentDateTime.getYear();
        String TimeString=String.format("%02d:%02d",CurrentDateTime.getHour(),CurrentDateTime.getMinute());
        //String TimeString=CurrentDateTime.getHour()+":"+CurrentDateTime.getMinute()+":"+CurrentDateTime.getSecond();

        String HubFooter=hubtitle + " - "+DateString+" - "+TimeString;

        //160
        ConvertImage(localFilePath,localFilePath160,200,160);

        //Default resolution
        ConvertImage(localFilePath,localFilePathDefRes,Integer.parseInt(resoultion[0]),Integer.parseInt(resoultion[1]));
        AddFooterTextToImage(localFilePathDefRes,HubFooter,Integer.parseInt(resoultion[0]),Integer.parseInt(resoultion[1]));
        AddWaterMark(localFilePathDefRes,resoultion);
        AddNewSnapshot(hub_id,localFilePathDefRes,default_resolution,lat,lng);

        return true;
    }


    //Image conver
    private void ConvertImage(String address,String destination,int Width,int Height) throws Exception
    {
        try
        {
            // Load the original image
            BufferedImage originalImage = ImageIO.read(new File(address));

            // Define the new dimensions
            int newWidth = Width;
            int newHeight = Height;

            // Resize the image
            Image resizedImage = originalImage.getScaledInstance(newWidth, newHeight, Image.SCALE_SMOOTH);

            // Save the resized image (optional)
            BufferedImage outputImage = new BufferedImage(newWidth, newHeight, BufferedImage.TYPE_INT_RGB);
            outputImage.getGraphics().drawImage(resizedImage, 0, 0, null);
            ImageIO.write(outputImage, "jpg", new File(destination));

            //System.out.println("Image resized successfully!");
        }
        catch (Exception e)
        {
            System.out.println("Error convert snapshot : "+e.getMessage());
        }
    }


    //Add text to image footer
    private void AddFooterTextToImage(String address,String text,int Width,int Height) throws Exception
    {
        try
        {
            // Load the image
            BufferedImage image = ImageIO.read(new File(address));
            File fontFile = new File("CenturyGothic.ttf");

            float fontsize = (float) (Width * 0.028);
            Font customFont = Font.createFont(Font.TRUETYPE_FONT, fontFile).deriveFont(fontsize);
            //Font customFont = Font.createFont(Font.TRUETYPE_FONT, fontFile).deriveFont(12f);

            // Get the Graphics object
            Graphics g = image.getGraphics();
            g.setFont(customFont);
            g.setColor(Color.lightGray);

            // Draw the text
            //g.drawString(text, Width / 2 + 30, Height - 20);
            //g.drawString(text, Width / 2 + 40, Height - 20);
            int around_space = ((int)(Height - fontsize));
            g.drawString(text, Width / 2 + 20, around_space - 20);
            g.dispose();

            // Save the new image
            ImageIO.write(image, "jpg", new File(address));
            System.out.println("Text added to image successfully.");
        }
        catch (Exception e)
        {
            System.out.println("Error add footer snapshot : "+e.getMessage());
        }
    }


    //Add iziot watermark
    private void AddWaterMark(String address,String resolution[]) throws Exception
    {
        try
        {
            // Load the base JPG image
            BufferedImage baseImage = ImageIO.read(new File(address));

            // Load the overlay PNG image
            BufferedImage overlayImage = ImageIO.read(new File("watermark.png"));

            // Get the Graphics object from the base image
            Graphics g = baseImage.getGraphics();

            int Width= (int) (Integer.parseInt(resolution[0]) * 0.1);
            int Height= (int) (Integer.parseInt(resolution[0]) * 0.1);

            // Draw the overlay image on top of the base image at position (x, y)
            g.drawImage(overlayImage, 0, 0,Width,Height, null);
            g.dispose();

            // Save the new image
            ImageIO.write(baseImage, "jpg", new File(address));
            System.out.println("Image overlay completed successfully.");
        }
        catch (IOException e)
        {
            System.out.println("Error watermark snapshot : "+e.getMessage());
        }
    }


    //Word replacer
    public static String CapitalizeFirstLetter(String str)
    {
        if (str == null || str.isEmpty()) {
            return str;
        }
        return str.substring(0, 1).toUpperCase() + str.substring(1).toLowerCase();
    }

    /******************************************************************************************/

    //Get add tempreture to db
    private void AddNewTempreture(int hub_id,String TempretureValue,String HubTimeZone)
    {
        if(!TempretureValue.trim().equals(""))
        {
            //LocalDateTime CurrentDateTime = LocalDateTime.now();
            ZonedDateTime currentDateTime = ZonedDateTime.now(ZoneId.of(HubTimeZone));

            // Use DateTimeFormatter for cleaner formatting
            //DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS");
            String dateTime = currentDateTime.format(formatter);

            temperatures_tbl n_tmp = new temperatures_tbl();
            n_tmp.setHub_id(HubService.GetHub(hub_id));
            //n_tmp.setDate_time(CurrentDateTime.toString());
            n_tmp.setDate_time(dateTime);
            n_tmp.setTemperature(TempretureValue.split(";")[0]);
            n_tmp.setAttribute("-");

            Tempreture.AddTemreture(n_tmp);
        }
    }


    //Get add airquality to db
    private void AddNewAirQuality(int hub_id,String Value)
    {
        if(!Value.trim().equals(""))
        {
            LocalDateTime CurrentDateTime = LocalDateTime.now();

            airquality_tbl air_q = new airquality_tbl();
            air_q.setHub_id(HubService.GetHub(hub_id));
            air_q.setDate_time(CurrentDateTime.toString());
            air_q.setValue(Value);
            air_q.setAttribute("-");

            AirQuality.AddValue(air_q);
        }
    }


    //Get add location to db (GPS: lat;lng, e.g. "35.7219;51.3347")
    private void AddNewLocation(int hub_id,String LocationValue,String HubTimeZone)
    {
        if(!LocationValue.trim().equals(""))
        {
            String[] parts = LocationValue.split(",");

            if(parts.length < 2)
            {
                return;
            }

            String lat = parts[0].trim();
            String lng = parts[1].trim();

            ZonedDateTime currentDateTime = ZonedDateTime.now(ZoneId.of(HubTimeZone));
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS");
            String dateTime = currentDateTime.format(formatter);

            location_tbl n_loc = new location_tbl();
            n_loc.setHub_id(HubService.GetHub(hub_id));
            n_loc.setDate_time(dateTime);
            n_loc.setLat(lat);
            n_loc.setLng(lng);
            n_loc.setAttribute("-");

            Location.AddLocation(n_loc);
        }
    }


    //Get add image to db
    private void AddNewSnapshot(int hub_id,String address,String resolution,String lat,String lng)
    {
        if(!address.trim().equals(""))
        {
            long file_size = 0;
            Path path = Paths.get(address);
            try
            {
                file_size = Files.size(path);
            }
            catch (IOException e)
            {
                e.printStackTrace();
            }

            LocalDateTime CurrentDateTime = LocalDateTime.now();

            images_tbl img=new images_tbl();
            img.setHub_id(HubService.GetHub(hub_id));
            img.setDate_time(CurrentDateTime.toString());
            img.setStatus("1");
            img.setResolution(resolution);
            img.setLat(lat);
            img.setLng(lng);
            img.setSize(file_size+"");
            img.setFile_address(address);

            Images.AddNewImage(img);

        }
    }




    //Get Data From header
    private boolean GetHubData(String HubFlag)
    {
        try
        {
            byte[] decodedHubFlagBytes = Base64.getDecoder().decode(HubFlag);
            String decodedHeaderFlag = new String(decodedHubFlagBytes);
            JSONObject HeaderToJson = new JSONObject(decodedHeaderFlag);

            IOTToken_Model iot_token=new IOTToken_Model(HeaderToJson.toString());
            Hub = IOTHubService.GetHub(iot_token.getId());

            return true;
        }
        catch (Exception e)
        {
            return false;
        }
    }


}