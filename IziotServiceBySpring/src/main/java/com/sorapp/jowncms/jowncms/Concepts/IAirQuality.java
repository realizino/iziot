package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.airquality_tbl;

import java.util.List;

public interface IAirQuality
{

    //Add new Value
    public void AddValue(airquality_tbl airquality);

    //Get tempreture by id
    public airquality_tbl GetValueById(int id);

    //Get tempreture by id
    public airquality_tbl GetValueBySerial(String serial);

    //Get 24 hours tempretures
    public List<airquality_tbl> Get24Values(String serial);

    public void Archiving();

}
