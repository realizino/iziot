package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.temperatures_tbl;

import java.util.List;

public interface ITemreture
{

    //Add new Tempreture
    public void AddTemreture(temperatures_tbl tempreture);

    //Get tempreture by id
    public temperatures_tbl GetTempretureById(int id);

    //Get tempreture by id
    public temperatures_tbl GetTempretureBySerial(String serial);

    //Get 24 hours tempretures
    public List<temperatures_tbl> Get24Tempretures(String serial);

    public void Archiving();

}
