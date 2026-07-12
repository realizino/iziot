package com.sorapp.jowncms.jowncms.Service.File;

import com.google.j2objc.annotations.Property;
import lombok.Value;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import java.io.File;

@Service
public class IOTFile_Service
{
    public void CreateHubDirectory(String RepoAddr,String Hub_Id)
    {
        try
        {
            File file=new File(RepoAddr+"/"+Hub_Id);
            file.mkdirs();
        }
        catch (Exception e)
        {
            System.out.println("Iot File Error : "+e.getMessage());
        }
    }


}
