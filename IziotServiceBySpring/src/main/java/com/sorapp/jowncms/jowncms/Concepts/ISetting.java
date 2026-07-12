package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.settings_tbl;

public interface ISetting
{

    //Get Last setting
    public settings_tbl GetSetting();

    //New Setting
    public settings_tbl NewSetting(String Version,String ESP32CAM_Code);

}
