package com.sorapp.jowncms.jowncms.Scheduling;

import com.sorapp.jowncms.jowncms.Function.Requets.Requests;
import com.sorapp.jowncms.jowncms.Models.Database.airquality_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.images_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.location_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.temperatures_tbl;
import com.sorapp.jowncms.jowncms.Models.Hub.FailModel;
import com.sorapp.jowncms.jowncms.Service.AirQuality.AirQuality_Service;
import com.sorapp.jowncms.jowncms.Service.Hubs.Hub_Service;
import com.sorapp.jowncms.jowncms.Service.Images.Images_Service;
import com.sorapp.jowncms.jowncms.Service.Location.Location_Service;
import com.sorapp.jowncms.jowncms.Service.Tempreture.Tempreture_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Component
public class HubsSchedule
{

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

    public static ArrayList<FailModel> HubFailMatrix=new ArrayList<>();

    @Value("${FileManagerRoot}")
    String FileManager;


    //Get schedule
    @Scheduled(fixedRate = 100000)
    public void InitHubsSchedule()
    {
        //Get hubs
        RamHubs = HubService.GetAllHubs();
    }


    //Get schedule
    @Scheduled(fixedRate = 30000)
    public void RunSchedule()
    {
        new Thread(new Runnable() {
            @Override
            public void run() {

                if(!is_running)
                {
                    //Get hubs data
                    GetHubs();
                }
            }
        }).start();
    }


    //Get hubs
    private void GetHubs()
    {
        try
        {
            for (int i = 0; i < RamHubs.size(); i++)
            {
                is_running = true;

                if(RamHubs.get(i).getIot_model().equals("ESP32CAM"))
                {
                    if (RamHubs.get(i).getStatus().equals("Enable"))
                    {
                        int index = i;
                        try {
                            System.out.println("Serial number : " + RamHubs.get(index).getSerial_number());

                            //Get hubs url
                            String HubAddress = RamHubs.get(index).getIp_address();


                            //Get tempreture
                            if (RamHubs.get(index).getAttribute().contains("Thermometer")) {
                                int ErrorCounter = 0;
                                String tmp = "-";
                                for (int j = 0; j < 5; j++) {
                                    String res_tmp = Requests.StringRequest(HubAddress + "/temp");
                                    if (res_tmp.equals("ERROR")) {
                                        ErrorCounter++;
                                        if (ErrorCounter == 3) {
                                            break;
                                        }
                                    } else if (!res_tmp.equals("")) {
                                        if (Float.parseFloat(res_tmp.split(";")[0]) > 125 || Float.parseFloat(res_tmp.split(";")[0]) < -55) {
                                            continue;
                                        }
                                        tmp = res_tmp;
                                        break;
                                    }
                                }
                                AddNewTempreture(RamHubs.get(index).getId(), tmp, RamHubs.get(index).getTimezone());
                                System.out.println(tmp.equals("-") ? "Tempreture is can not resived" : "Tempreture is resived");
                            }


                            //Get air quality
                            if (RamHubs.get(index).getAttribute().contains("Air quality")) {
                                String res_air_quality = Requests.StringRequest(HubAddress + "/air_quality");
                                AddNewAirQuality(RamHubs.get(index).getId(), res_air_quality);
                                System.out.println((res_air_quality.equals("-") || res_air_quality.equals("")) ? "Air quality is can not resived" : "Air quality is resived");
                            }


                            //Get location (Neo M6 GPS)
                            if (RamHubs.get(index).getAttribute().contains("Neo M6")) {
                                String res_location = Requests.StringRequest(HubAddress + "/location");
                                AddNewLocation(RamHubs.get(index).getId(), res_location, RamHubs.get(index).getTimezone());
                                System.out.println((res_location.equals("-") || res_location.equals("") || res_location.equals("ERROR")) ? "Location is can not resived" : "Location is resived");
                            }


                            //Get image
                            DownloadImage(RamHubs.get(index).getId(), HubAddress + "/snapshot", RamHubs.get(index).getSerial_number(), RamHubs.get(index).getTitle(), RamHubs.get(index).getLat().toString(), RamHubs.get(index).getLng().toString(), RamHubs.get(index).getTimezone(), RamHubs.get(index).getDefault_resolution());

                            //Take picture
                            Requests.StringRequest(HubAddress + "/capture");
                            System.out.println("Take shot");

                            //Get set matrix zero
                            SetFailMatrixZero(RamHubs.get(index).getSerial_number());

                            System.out.println("-------------------------------------------------------------------");
                        } catch (Exception e) {
                            System.out.println("Error : " + e.getMessage());
                            AddNewFailMatrix(RamHubs.get(index).getSerial_number(), index);
                            System.out.println("-------------------------------------------------------------------");
                        }
                    }
                }
            }
            is_running = false;
        }
        catch (Exception e)
        {

        }
    }


    //Fail matrix
    private void AddNewFailMatrix(String serial,int RamIndex)
    {
        int CheckExist=GetCheckFailMatrix(serial);
        if(CheckExist >= 0)
        {
            int fail_count=HubFailMatrix.get(CheckExist).getFail();
            fail_count++;
            HubFailMatrix.get(CheckExist).setFail(fail_count);

            if(fail_count >= 5)
            {
                System.out.println("-------------------------------------------------------------------");
                System.out.println("Hub with "+serial+" serial number is disabled");
                System.out.println("-------------------------------------------------------------------");
                RamHubs.get(RamIndex).setStatus("Diasable");
                HubService.GetDisableHubBySerial(serial);
            }

        }
        else
        {
            FailModel n_fail=new FailModel();
            n_fail.setSerial(serial);
            n_fail.setFail(1);
            HubFailMatrix.add(n_fail);
        }
    }


    //Get check fail matrix
    private int GetCheckFailMatrix(String serial)
    {
        int checkexist=-1;

        for(int i=0;i<HubFailMatrix.size();i++)
        {
            if(HubFailMatrix.get(i).getSerial().equals(serial))
            {
                checkexist=i;
            }
        }

        return checkexist;
    }


    //Get check fail matrix
    private void SetFailMatrixZero(String serial)
    {
        for(int i=0;i<HubFailMatrix.size();i++)
        {
            if(HubFailMatrix.get(i).getSerial().equals(serial))
            {
                HubFailMatrix.get(i).setFail(0);
            }
        }
    }



    //Get download image
    private void DownloadImage(int hub_id,String url,String serial_number,String hubtitle,String lat,String lng,String timezone,String default_resolution) throws Exception
    {

        //Get resoltion
        String resoultion[]=default_resolution.split("×");



//        LocalDateTime CurrentDateTime = LocalDateTime.now();
        ZonedDateTime CurrentDateTime = ZonedDateTime.now(ZoneId.of(timezone));



//        String fileUrl = url;
//        String localDirPath = "Repository/Snapshots/Snapshots"+CurrentDateTime.getYear()+""+CurrentDateTime.getMonth()+""+CurrentDateTime.getDayOfMonth()+"/"+serial_number+"/";
//        String localFilePath =  localDirPath+CurrentDateTime.getHour()+""+CurrentDateTime.getMinute()+""+CurrentDateTime.getSecond()+".jpg";
////        System.out.println(localFilePath);
//
//        //480
//        /*String localDirPath480 = "Present/Snapshots/Snapshots"+CurrentDateTime.getYear()+""+CurrentDateTime.getMonth()+""+CurrentDateTime.getDayOfMonth()+"/480/"+serial_number+"/";
//        String localFilePath480 =  localDirPath480 +CurrentDateTime.getHour()+""+CurrentDateTime.getMinute()+""+CurrentDateTime.getSecond()+".jpg";*/
////        System.out.println(localFilePath480);
//
//        //Default resoltion
//        String localDirPathDefRes = "Present/Snapshots/Snapshots"+CurrentDateTime.getYear()+""+CurrentDateTime.getMonth()+""+CurrentDateTime.getDayOfMonth()+"/"+resoultion[0]+"/"+serial_number+"/";
//        String localFilePathDefRes =  localDirPathDefRes +CurrentDateTime.getHour()+""+CurrentDateTime.getMinute()+""+CurrentDateTime.getSecond()+".jpg";
//
//
//        //160
//        String localDirPath160 = "Present/Snapshots/Snapshots"+CurrentDateTime.getYear()+""+CurrentDateTime.getMonth()+""+CurrentDateTime.getDayOfMonth()+"/160/"+serial_number+"/";
//        String localFilePath160 =  localDirPath160 + CurrentDateTime.getHour()+""+CurrentDateTime.getMinute()+""+CurrentDateTime.getSecond()+".jpg";
//        System.out.println(localFilePath160);


        String fileUrl = url;

        // Format time components with leading zeros
        String year = String.format("%04d", CurrentDateTime.getYear());
        String month = CurrentDateTime.getMonth().toString();
        String day = String.format("%02d", CurrentDateTime.getDayOfMonth());
        String hour = String.format("%02d", CurrentDateTime.getHour()); // 24-hour format (00-23)
        String minute = String.format("%02d", CurrentDateTime.getMinute());
        String second = String.format("%02d", CurrentDateTime.getSecond());

        // Repository path
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


        //Download image start
        //HttpClient httpClient=HttpClient.newHttpClient();
        HttpClient client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5)) // Set the connection timeout to 10 seconds
                .build();

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(fileUrl))
                .build();

        HttpResponse<Path> response = client.send(request, HttpResponse.BodyHandlers.ofFile(Path.of(localFilePath)));
        Path downloadedFile = response.body();
//            System.out.println(url);
//            URL url_addres = new URL(url);
//            BufferedImage image = ImageIO.read(url_addres);
//            image.flush();
//            ImageIO.write(image, "jpg", new File(localFilePath));
        //Download image end


        String mon_name=new String(CapitalizeFirstLetter(CurrentDateTime.getMonth().name().toString()));
        String day_week=new String(CapitalizeFirstLetter(CurrentDateTime.getDayOfWeek().name().toString()));

        String DateString=day_week.substring(0,3) + "," + mon_name.substring(0,3)+ " " + CurrentDateTime.getDayOfMonth() + " " +  CurrentDateTime.getYear();
        String TimeString=String.format("%02d:%02d",CurrentDateTime.getHour(),CurrentDateTime.getMinute());
        //String TimeString=CurrentDateTime.getHour()+":"+CurrentDateTime.getMinute()+":"+CurrentDateTime.getSecond();

        String HubFooter=hubtitle + " - "+DateString+" - "+TimeString;

        //160
        ConvertImage(localFilePath,localFilePath160,200,160);

//480
//        ConvertImage(localFilePath,localFilePath480,480,360);
//        AddFooterTextToImage(localFilePath480,HubFooter,480,360);
//        AddiziotWaterMark(localFilePath480);
//        AddNewSnapshot(hub_id,localFilePath480,"480 × 360",lat,lng);

        //Default resolution
        ConvertImage(localFilePath,localFilePathDefRes,Integer.parseInt(resoultion[0]),Integer.parseInt(resoultion[1]));
        AddFooterTextToImage(localFilePathDefRes,HubFooter,Integer.parseInt(resoultion[0]),Integer.parseInt(resoultion[1]));
        AddWaterMark(localFilePathDefRes,resoultion);
        AddNewSnapshot(hub_id,localFilePathDefRes,default_resolution,lat,lng);
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
        if(!LocationValue.trim().equals("") && !LocationValue.equals("ERROR"))
        {
            String[] parts = LocationValue.split(";");

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


}