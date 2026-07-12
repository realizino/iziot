package com.sorapp.jowncms.jowncms.Scheduling;

import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Service.AirQuality.AirQuality_Service;
import com.sorapp.jowncms.jowncms.Service.Hubs.Hub_Service;
import com.sorapp.jowncms.jowncms.Service.Images.Images_Service;
import com.sorapp.jowncms.jowncms.Service.Tempreture.Tempreture_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class CheckNewProtocolHubsSchedule
{

    //Global variables
    List<hub_tbl> RamHubs;

    @Autowired
    Hub_Service HubService;

    @Autowired
    Tempreture_Service Tempreture;

    @Autowired
    AirQuality_Service AirQuality;

    @Autowired
    Images_Service Images;



    //Get schedule
    @Scheduled(fixedRate = 100000)
    public void CheckHubsStatusSchedule()
    {
        //Get hubs
        RamHubs = HubService.GetAllHubs();

        //Get all hubs
        for(int i=0;i<RamHubs.size();i++)
        {
            if(RamHubs.get(i).getIot_model().contains("NEWPROTOCOL"))
            {
                if (RamHubs.get(i).getStatus().equals("Enable"))
                {
                    //Get latest image date time
                    String LatestImageDateTime = Images.GetLastImageBySerialNumber(RamHubs.get(i).getSerial_number()).getDate_time();

                    //Get current date time
                    LocalDateTime CurrentDateTime = LocalDateTime.now();

//                    System.out.println("1 : "+CurrentDateTime.toString().split(":")[0]);
//                    System.out.println("1 : "+LatestImageDateTime.split(":")[0]);
//                    System.out.println("1 : "+CurrentDateTime.toString().split(":")[1]);
//                    System.out.println("1 : "+LatestImageDateTime.split(":")[1]);

                    if(!CurrentDateTime.toString().split(":")[0].equals(LatestImageDateTime.split(":")[0]) && !CurrentDateTime.toString().split(":")[1].equals(LatestImageDateTime.split(":")[1]))
                    {
                        HubService.GetPoorConnectionHubBySerial(RamHubs.get(i).getSerial_number());

                        System.out.println("-------------------------------------------------------------------");
                        System.out.println("Hub "+RamHubs.get(i).getId()+" Latest Image datetime is : "+LatestImageDateTime+" And Current Time is : "+CurrentDateTime.toString() +" So Disabled Hub");
                        System.out.println("-------------------------------------------------------------------");
                    }

                }
            }
        }
    }

}
