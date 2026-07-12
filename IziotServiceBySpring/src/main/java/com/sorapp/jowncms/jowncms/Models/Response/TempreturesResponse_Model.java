package com.sorapp.jowncms.jowncms.Models.Response;

public class TempreturesResponse_Model
{

    String date;
    String data;

    public TempreturesResponse_Model(String date, String data)
    {
        this.date = date;
        this.data = data;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }
}
