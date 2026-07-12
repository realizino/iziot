package com.sorapp.jowncms.jowncms.Models.Response;

public class LoadResponse_Model
{

    String status;
    String LastSensed;
    String LastAirQuality;

    public LoadResponse_Model(String status, String lastSensed,String lastairquality)
    {
        this.status = status;
        LastSensed = lastSensed;
        LastAirQuality=lastairquality;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getLastSensed() {
        return LastSensed;
    }

    public void setLastSensed(String lastSensed) {
        LastSensed = lastSensed;
    }

    public String getLastAirQuality() {
        return LastAirQuality;
    }

    public void setLastAirQuality(String lastAirQuality) {
        LastAirQuality = lastAirQuality;
    }
}
