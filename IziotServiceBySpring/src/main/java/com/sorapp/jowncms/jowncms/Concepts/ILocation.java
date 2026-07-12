package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.location_tbl;

import java.util.List;

public interface ILocation
{
    void AddLocation(location_tbl location);

    location_tbl GetLocationById(int id);

    location_tbl GetLocationBySerial(String serial);

    List<location_tbl> Get24Locations(String serial);

    //Get the ordered movement trail for the last 24 hours (used to draw the path on the map)
    List<location_tbl> GetLast24HoursLocations(String serial);

    void Archiving();
}