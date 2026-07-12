package com.sorapp.jowncms.jowncms.Scheduling;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;

@Component
public class OverHillSchedule
{

    boolean F_Restart=false;


    //Over hill every 48 hours
    @Scheduled(fixedRate = 172800000) // 48 hours in milliseconds
    public void restartService()
    {
        if(F_Restart) {
            String serviceName = "iziot";
            try {
                String[] command = {"systemctl", "restart", serviceName};
                ProcessBuilder processBuilder = new ProcessBuilder(command);
                Process process = processBuilder.start();

                BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println("Log : " + line);
                }

                BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()));
                while ((line = errorReader.readLine()) != null) {
                    System.out.println("Log : " + line);
                }

                int exitCode = process.waitFor();
                if (exitCode == 0) {
                    System.out.println("Overhill success");
                } else {
                    System.out.println("Can not Overhill");
                }

            } catch (Exception e) {
                System.out.println("Error in overhill : " + e.getMessage());
            }
        }
        else
        {
            F_Restart=true;
        }
    }

}
