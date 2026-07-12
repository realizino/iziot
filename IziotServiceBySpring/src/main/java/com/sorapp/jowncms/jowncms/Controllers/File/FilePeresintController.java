package com.sorapp.jowncms.jowncms.Controllers.File;

import com.sorapp.jowncms.jowncms.Service.File.File_Service;
//import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;

@RequestMapping("/Files")
@Controller
public class FilePeresintController
{


    @Autowired
    File_Service Files_Service;



    //Display file start
    @RequestMapping(value = "/{file_hash}")
    public ResponseEntity<Resource> FileResponse(@PathVariable String file_hash) throws FileNotFoundException
    {
        File file = new File(Files_Service.GetFileByHash(file_hash).getFile_address_server());

        InputStreamResource resource = new InputStreamResource(new FileInputStream(file.getAbsoluteFile()));

        return ResponseEntity.ok()
                .contentLength(file.length())
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(resource);
    }
    //Display file end


}
