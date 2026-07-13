package com.sorapp.jowncms.jowncms.Scheduling;

import com.sorapp.jowncms.jowncms.Service.AirQuality.AirQuality_Service;
import com.sorapp.jowncms.jowncms.Service.Images.Images_Service;
import com.sorapp.jowncms.jowncms.Service.Location.Location_Service;
import com.sorapp.jowncms.jowncms.Service.Tempreture.Tempreture_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class ArchiveSchedule
{

    //Global vairiables

    @Autowired
    Tempreture_Service tempretureService;

    @Autowired
    Images_Service imagesService;

    @Autowired
    AirQuality_Service airqualityService;

    @Autowired
    Location_Service locationService;

    //@Scheduled(cron = "0 0 10 * * ?")
    //Every week in monday
    @Scheduled(cron = "0 0 0 * * MON")
    public void GetArchive()
    {
        System.out.println("Archiving");
        System.out.println("-------------------------------------------------------------------");

        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    tempretureService.Archiving();
                }
                catch (Exception e)
                {

                }
            }
        }).start();



        new Thread(new Runnable() {
            @Override
            public void run() {
                try
                {
                    airqualityService.Archiving();
                }
                catch (Exception e)
                {

                }
            }
        }).start();



        new Thread(new Runnable() {
            @Override
            public void run() {
                try
                {
                    imagesService.ArchiveImages();
                }
                catch (Exception e)
                {

                }
            }
        }).start();



        new Thread(new Runnable() {
            @Override
            public void run() {
                try
                {
                    locationService.Archiving();
                }
                catch (Exception e)
                {

                }
            }
        }).start();

        System.out.println("Archiving Done");
        System.out.println("-------------------------------------------------------------------");
    }


}