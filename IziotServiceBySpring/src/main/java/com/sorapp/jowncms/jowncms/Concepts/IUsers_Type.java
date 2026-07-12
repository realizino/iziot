package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.userstype_tbl;

import java.util.List;

public interface IUsers_Type
{

    //Get All User Type
    public List<userstype_tbl> GetAllUserType();

    //Get User Type
    public userstype_tbl GetUserType(int user_type_id);

    //New Type
    public userstype_tbl NewType(String title,String en_title);

    //Update Type
    public userstype_tbl UpdateType(int id,String title,String en_title);

    //Remove Type
    public void RemoveType(int id);

}
