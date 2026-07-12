package com.sorapp.jowncms.jowncms.Models.Response;

public class StatusResponse_Model
{

    String status;

    public StatusResponse_Model(String status)
    {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
