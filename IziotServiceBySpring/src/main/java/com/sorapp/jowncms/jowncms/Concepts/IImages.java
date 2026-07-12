package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.images_tbl;

import java.util.List;

public interface IImages
{

    //Add new image
    public void AddNewImage(images_tbl img);

    //Get image
    public images_tbl GetImageByid(int id);

    //Get last image
    public images_tbl GetLastImageBySerialNumber(String serial);

    //Get Count of images from a day
    public int GetCountOfImagesInADay(String serial);

    //Get random images from today
    public List<images_tbl> GetRandomImagesFromToDay(String serial);

    //Get random images from today
    public List<images_tbl> GetRandomImagesFromToDay(String serial,int rate);

    //Get 24
    public List<images_tbl> Get24Image(String serial);

    //Get archive
    public void ArchiveImages();


}
