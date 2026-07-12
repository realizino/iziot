package com.sorapp.jowncms.jowncms.Function.Hash;

import org.yaml.snakeyaml.external.biz.base64Coder.Base64Coder;

import java.io.*;
import java.nio.file.Files;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class HashService
{

    //Get Hash Text start
    public static String HashText(String text)
    {
        try
        {
            MessageDigest md = MessageDigest.getInstance("SHA3-256");
            byte[] result = md.digest(text.getBytes());
            return new String(result);
        }
        catch (Exception e)
        {
            return "";
        }
    }
    //Get Hash Text end

    //Get hash file start
    public static String HashFile(File file) throws Exception
    {
        InputStream is = Files.newInputStream(file.toPath());
        return org.apache.commons.codec.digest.DigestUtils.sha256Hex(is);
    }
    //Get hash file end

}
