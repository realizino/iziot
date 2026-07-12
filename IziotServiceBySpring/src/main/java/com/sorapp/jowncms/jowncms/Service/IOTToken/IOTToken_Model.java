package com.sorapp.jowncms.jowncms.Service.IOTToken;

import org.json.JSONObject;

public class IOTToken_Model
{
//    long id;
//    String serial;
//    String title;
//    String lat;
//    String lng;
//    String timezone;
//    String resolution;
//    String iot_model;
//
//    public IOTToken_Model(long id, String serial, String title, String lat, String lng, String timezone, String resolution, String iot_model)
//    {
//        this.id = id;
//        this.serial = serial;
//        this.title = title;
//        this.lat = lat;
//        this.lng = lng;
//        this.timezone = timezone;
//        this.resolution = resolution;
//        this.iot_model = iot_model;
//    }
//
//    public IOTToken_Model() {
//    }
//
//
//    public IOTToken_Model(String json) {
//        JSONObject obj = new JSONObject(json);
//
//        if (obj.has("id")) this.id = obj.getLong("id");
//        if (obj.has("serial")) this.serial = obj.getString("serial");
//        if (obj.has("title")) this.title = obj.getString("title");
//        if (obj.has("lat")) this.lat = obj.getString("lat");
//        if (obj.has("lng")) this.lng = obj.getString("lng");
//        if (obj.has("timezone")) this.timezone = obj.getString("timezone");
//        if (obj.has("resolution")) this.resolution = obj.getString("resolution");
//        if (obj.has("iot_model")) this.iot_model = obj.getString("iot_model");
//    }
//
//    public long getId() {
//        return id;
//    }
//
//    public void setId(long id) {
//        this.id = id;
//    }
//
//    public String getSerial() {
//        return serial;
//    }
//
//    public void setSerial(String serial) {
//        this.serial = serial;
//    }
//
//    public String getTitle() {
//        return title;
//    }
//
//    public void setTitle(String title) {
//        this.title = title;
//    }
//
//    public String getLat() {
//        return lat;
//    }
//
//    public void setLat(String lat) {
//        this.lat = lat;
//    }
//
//    public String getLng() {
//        return lng;
//    }
//
//    public void setLng(String lng) {
//        this.lng = lng;
//    }
//
//    public String getTimezone() {
//        return timezone;
//    }
//
//    public void setTimezone(String timezone) {
//        this.timezone = timezone;
//    }
//
//    public String getResolution() {
//        return resolution;
//    }
//
//    public void setResolution(String resolution) {
//        this.resolution = resolution;
//    }
//
//    public String getIot_model() {
//        return iot_model;
//    }
//
//    public void setIot_model(String iot_model) {
//        this.iot_model = iot_model;
//    }


    int id;
    String url;
    String attribute;
    String resolution;


    public IOTToken_Model(int id, String url,String attributes,String resolution) {
        this.id = id;
        this.url = url;
        this.attribute = attributes;
        this.resolution = resolution;
    }

    public IOTToken_Model(String json) {
        JSONObject obj = new JSONObject(json);

        if (obj.has("id")) this.id = obj.getInt("id");
        if (obj.has("url")) this.url = obj.getString("url");
        if (obj.has("attribute")) this.attribute = obj.getString("attribute");
        if (obj.has("resolution")) this.resolution = obj.getString("resolution");
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getAttribute() {
        return attribute;
    }

    public void setAttribute(String attribute) {
        this.attribute = attribute;
    }

    public String getResolution() {
        return resolution;
    }

    public void setResolution(String resolution) {
        this.resolution = resolution;
    }
}
