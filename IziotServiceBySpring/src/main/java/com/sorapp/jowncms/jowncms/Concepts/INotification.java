package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.notifications_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;

import java.util.List;

public interface INotification
{

    //Get All Notifications
    public List<notifications_tbl> GetAllUserNotifications(int user_id);

    //New notification
    public notifications_tbl NewNotification(String title, String content, String link, String from, boolean seen, users_tbl user_id);

    //Seen notification
    public void SeenNotification(int id);

}
