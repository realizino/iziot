package com.sorapp.jowncms.jowncms.Controllers.File;

import com.sorapp.jowncms.jowncms.Models.Database.file_tbl;
import com.sorapp.jowncms.jowncms.Concepts.IFileUpload;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/File")
public class FileController
{



    @Autowired
    IFileUpload FileUploadRepo;


    //Upload file start
    @RequestMapping(value = "Upload",method = RequestMethod.POST)
    public Map<String,String> UploadFile(HttpServletRequest request, MultipartFile UploadFile) throws Exception
    {
        file_tbl file = FileUploadRepo.UploadFile_Repo(UploadFile);
        Map<String,String> result=new HashMap<>();
        result.put("file_id",file.getId()+"");
        return result;
    }
    //Upload file end


}
