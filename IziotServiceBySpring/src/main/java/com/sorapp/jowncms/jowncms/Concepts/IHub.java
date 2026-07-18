package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;

import java.util.List;

public interface IHub
{

    public void AddNewHub(hub_tbl hub);

    public List<hub_tbl> GetAllHubs();

    public List<hub_tbl> GetHubsByUser(int user_id);

    public hub_tbl GetHub(int id);

    public hub_tbl GetHubBySerial(String serial);

    public void GetDisableHubBySerial(String serial);

    public void GetPoorConnectionHubBySerial(String serial);

    public void UpdateHub(hub_tbl hub);

    public void DeleteHub(int id);

}