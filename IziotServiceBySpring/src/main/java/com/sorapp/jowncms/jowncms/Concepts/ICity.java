package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.city_tbl;

import java.util.List;

public abstract interface ICity
{

    //Get City
    public abstract city_tbl GetCity(int id);

    //Get City
    public abstract List<city_tbl> GetCites();

    //Insert new city
    public abstract city_tbl NewCity(String name, int area, String status, String datetime,String timezone);

    //Update city
    public abstract city_tbl UpdateCity(int id, String name, int area, String status, String datetime,String timezone);

}
