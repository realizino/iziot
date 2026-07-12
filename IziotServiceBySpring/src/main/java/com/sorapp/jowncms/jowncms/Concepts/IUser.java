package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.city_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.file_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;

import java.util.List;

public interface IUser
{

    //Get All Users
    public List<users_tbl> GetAllUsers();

    //Get All Admin users
    public List<users_tbl> GetAllAdminUsers();

    //Get User
    public users_tbl GetUser(int id);

    //Login User
    public users_tbl Login(String username,String password);

    //Login User
    public users_tbl LoginByToken(String token);

    //Insert
    public users_tbl NewUser(String name, String family, String username, String password, String LoginToken, String phone, String email, String bio, String date_time, String user_type, String status, String website, String address, String google_auth, file_tbl profile_image_file_id, city_tbl city_id);

    //Update
    public users_tbl UpdateUser(int id,String name, String family, String username, String password, String phone, String email, String bio, String date_time, String user_type, String status, String website, String address, file_tbl profile_image_file_id, city_tbl city_id);

    //Update User BY Admin
    public users_tbl UpdateUserByAdmin(int id,String name, String family, String username, String password, String phone, String email, String bio, String date_time, String user_type, String status, String website, String address, file_tbl profile_image_file_id, city_tbl city_id);

    //Active 2F
    public void Google2F(users_tbl user_id,String State,String Key);

    //Get Search User
    public List<users_tbl> GetSeachUser(String seach);

    //Get Check exist Seach User
    public List<users_tbl> GetCheckUserExist(String username);

}
