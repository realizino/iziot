package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.settings_tbl;

public interface ISetting
{
    settings_tbl GetSetting();
    settings_tbl NewSetting(String Version, String ESP32CAM_Code, String Config);
}