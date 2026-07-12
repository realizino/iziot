package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Function.Hash.HashService;
import com.sorapp.jowncms.jowncms.Models.Database.file_tbl;
import com.sorapp.jowncms.jowncms.Service.File.File_Service;
import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;

@Component
public class IFileUpload
{

    @Value("${FileManager}")
    String UploadPath;

    @Value("${FileManagerTemp}")
    String TempPath;

    @Autowired
    File_Service file_service;


    public file_tbl UploadFile_Repo(MultipartFile UploadFile) throws Exception
    {
        LocalDateTime datetime = LocalDateTime.now();
        String time=datetime.getYear()+"/"+datetime.getMonthValue()+"/"+datetime.getDayOfMonth()+" "+datetime.getHour()+":"+datetime.getMinute()+":"+datetime.getSecond();

        String file_extention= FilenameUtils.getExtension(UploadFile.getOriginalFilename());

        File TempFile=new File(TempPath+"/"+UploadFile.getName()+"."+file_extention);
        UploadFile.transferTo(TempFile);
        String file_hash= HashService.HashFile(TempFile);

        File MainFile=new File(UploadPath+"/"+file_hash+"."+file_extention);
        Files.copy(TempFile.toPath(),MainFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
        file_tbl file = file_service.NewFile(file_hash,UploadPath+"/"+file_hash+"."+file_extention,UploadPath+"/"+file_hash+"."+file_extention,file_extention,file_extention,UploadFile.getSize()+"",file_hash,time);
        TempFile.delete();
        return file;
    }

}
