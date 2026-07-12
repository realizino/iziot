package com.sorapp.jowncms.jowncms.Concepts;

import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;

public interface IUser_Verify
{

    //Get Check Verify Code
    public boolean CheckVerifyCode(String hash,int user_id);

    //New user verify code
    public void NewUserVerifyCode(String hash_code, users_tbl user_id);

    //Remove user verify code
    public void RemoveUserVerifyCode(users_tbl user_id);


}
