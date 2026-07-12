package com.sorapp.jowncms.jowncms.Controllers.Admin;

import com.sorapp.jowncms.jowncms.Function.Encript.EncriptService;
import com.sorapp.jowncms.jowncms.Middleware.AdminAuthCheckMiddleware;
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
import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.FileInputStream;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/Admin")
public class AdminFileManageController
{


    @Autowired
    EncriptService Encription;

    @Autowired
    Users_Service User_Services;

    @Autowired
    City_Service City_Services;

    @Autowired
    IFileUpload FileUploadRepo;

    @Autowired
    Setting_Service Setting_Services;

    @Autowired
    UserType_Service UserType_Services;

    @Autowired
    Notification_Service Notification_Services;

    @Autowired
    IOTFile_Service IotFileService;

    @Value("${FileManagerRoot}")
    String FileManager;

    @Value("${IotFileRepo}")
    String Repository;

    @Value("${ServerPassword}")
    String ServerPassword;

    private final GoogleAuthenticator gAuth;





    /****************FileMnager Start****************/
    @RequestMapping("/Panel/FileManager")
    public ModelAndView FileManager(HttpServletRequest request)
    {
        String Path=request.getParameter("path");
        ModelAndView response=new ModelAndView();
        response.setViewName("Admin/filemanager");
        response.addObject("user_data", AdminAuthCheckMiddleware.user_data);
        response.addObject("address",Path);

        if(Path==null) {
            File folder = new File(FileManager);
            File[] folders = folder.listFiles();
            response.addObject("fileslen",folder.listFiles().length);
            response.addObject("files",folder.listFiles());
            response.addObject("curentlocation",FileManager);
        }
        else{
            File folder = new File(FileManager+"/"+Path);
            File[] folders = folder.listFiles();
            response.addObject("fileslen",folder.listFiles().length);
            response.addObject("files",folder.listFiles());
            response.addObject("curentlocation",FileManager);
        }

        return response;
    }

    @RequestMapping(value = "/Panel/FileManager/CreateFolder",method = RequestMethod.POST)
    public String CreateFolder(HttpServletRequest request,String Folder_Name,String Addrs)
    {
        try
        {

            if(Addrs==null)
            {
                File NewFolder = new File(FileManager + "/" + Folder_Name);
                NewFolder.mkdir();
                NewFolder.mkdirs();
            }
            else
            {
                File NewFolder = new File(FileManager + "/" + Addrs + "/" + Folder_Name);
                NewFolder.mkdir();
                NewFolder.mkdirs();
            }
        }
        catch (Exception e)
        {

        }
        return "redirect:" + request.getHeader("referer");
    }

    @RequestMapping(value = "/Panel/FileManager/Upload",method = RequestMethod.POST)
    public String UploadFile(HttpServletRequest request, MultipartFile Upload_File, String Address)
    {
        try
        {
            String FileName = Upload_File.getOriginalFilename();
            Upload_File.transferTo(new File(FileManager+"/"+Address+"/"+FileName));
        }
        catch (Exception e)
        {
            System.out.println(e.getMessage());
        }
        return "redirect:" + request.getHeader("referer");
    }

    @RequestMapping(value = "/Panel/FileManager/Delete",method = RequestMethod.GET)
    public String RemoveFile(HttpServletRequest request)
    {
        System.out.println("Get remove file");
        try
        {
            String path=request.getParameter("path");
            String name=request.getParameter("name");
            if(path.equals("null"))
            {
                File file = new File(FileManager + "/" + name);
                file.delete();
                System.out.println("Removed"+file.getPath());
            }
            else
            {
                File file = new File(FileManager + "/" + path + "/" + name);
                file.delete();
                System.out.println("Removed"+file.getPath());
            }
        }
        catch (Exception e)
        {
            System.out.println(e.getMessage());
        }
        return "redirect:" + request.getHeader("referer");
    }

    @RequestMapping(value = "/Panel/FileManager/Download",method = RequestMethod.GET)
    public ResponseEntity<Resource> DownloadFile(HttpServletRequest request)
    {
        System.out.println("Get remove file");
        try
        {
            String path=request.getParameter("path");
            String name=request.getParameter("name");
            File file;
            if(path.equals("null"))
            {
                file = new File(FileManager + "/" + name);
                System.out.println("Removed"+file.getPath());
            }
            else
            {
                file = new File(FileManager + "/" + path + "/" + name);
                System.out.println("Removed"+file.getPath());
            }


            InputStreamResource resource = new InputStreamResource(new FileInputStream(file.getAbsoluteFile()));

            return ResponseEntity.ok()
                    .contentLength(file.length())
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(resource);
        }
        catch (Exception e)
        {
            System.out.println(e.getMessage());
        }
        return null;
    }

    @RequestMapping(value = "/Panel/FileManager/DeleteDir",method = RequestMethod.GET)
    public String RemoveDirectory(HttpServletRequest request)
    {
        try
        {
            String path=request.getParameter("path").replace("null/","");
            FileUtils.deleteDirectory(new File(FileManager+"\\"+path));
        }
        catch (Exception e)
        {

        }
        return "redirect:" + request.getHeader("referer");
    }
    /****************FileMnager End****************/





}
