package com.sorapp.jowncms.jowncms.Models.Database;

import org.json.JSONObject;

import javax.persistence.*;

@Entity
@Table(name = "hub_tbl")
public class hub_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    String title;
    String serial_number;
    String iot_model;
    String iot_type;
    String status;
    String permission;
    String date_time;
    String lat;
    String lng;
    String attribute;
    String timezone;
    String default_resolution;
    String admin_mobile;
    String ip_address;
    String url;
    String username;
    String password;

    public hub_tbl(){

    }

    public hub_tbl(String json) {
        JSONObject obj = new JSONObject(json);

        if(obj.has("id")) this.id = obj.getInt("id");
        if(obj.has("title")) this.title = obj.getString("title");
        if(obj.has("serial_number")) this.serial_number = obj.getString("serial_number");
        if(obj.has("iot_model")) this.iot_model = obj.getString("iot_model");
        if(obj.has("iot_type")) this.iot_type = obj.getString("iot_type");
        if(obj.has("status")) this.status = obj.getString("status");
        if(obj.has("permission")) this.permission = obj.getString("permission");
        if(obj.has("date_time")) this.date_time = obj.getString("date_time");
        if(obj.has("lat")) this.lat = obj.getString("lat");
        if(obj.has("lng")) this.lng = obj.getString("lng");
        if(obj.has("attribute")) this.attribute = obj.getString("attribute");
        if(obj.has("timezone")) this.timezone = obj.getString("timezone");
        if(obj.has("default_resolution")) this.default_resolution = obj.getString("default_resolution");
        if(obj.has("admin_mobile")) this.admin_mobile = obj.getString("admin_mobile");
        if(obj.has("ip_address")) this.ip_address = obj.getString("ip_address");
        if(obj.has("url")) this.url = obj.getString("url");
        if(obj.has("username")) this.username = obj.getString("username");
        if(obj.has("password")) this.password = obj.getString("password");
    }

    public hub_tbl(int id, String serial_number,String title, String iot_model, String iot_type, String status, String permission, String date_time, String lat, String lng, String attribute, String default_resolution, String admin_mobile, String ip_address, String url,String username,String password,String timezone) {
        this.id = id;
        this.title = title;
        this.serial_number = serial_number;
        this.iot_model = iot_model;
        this.iot_type = iot_type;
        this.status = status;
        this.permission = permission;
        this.date_time = date_time;
        this.lat = lat;
        this.lng = lng;
        this.attribute = attribute;
        this.default_resolution = default_resolution;
        this.admin_mobile = admin_mobile;
        this.ip_address = ip_address;
        this.url = url;
        this.username = username;
        this.password = password;
        this.timezone = timezone;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSerial_number() {
        return serial_number;
    }

    public void setSerial_number(String serial_number) {
        this.serial_number = serial_number;
    }

    public String getIot_model() {
        return iot_model;
    }

    public void setIot_model(String iot_model) {
        this.iot_model = iot_model;
    }

    public String getIot_type() {
        return iot_type;
    }

    public void setIot_type(String iot_type) {
        this.iot_type = iot_type;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPermission() {
        return permission;
    }

    public void setPermission(String permission) {
        this.permission = permission;
    }

    public String getDate_time() {
        return date_time;
    }

    public void setDate_time(String date_time) {
        this.date_time = date_time;
    }

    public String getLat() {
        return lat;
    }

    public void setLat(String lat) {
        this.lat = lat;
    }

    public String getLng() {
        return lng;
    }

    public void setLng(String lng) {
        this.lng = lng;
    }

    public String getAttribute() {
        return attribute;
    }

    public void setAttribute(String attribute) {
        this.attribute = attribute;
    }

    public String getDefault_resolution() {
        return default_resolution;
    }

    public void setDefault_resolution(String default_resolution) {
        this.default_resolution = default_resolution;
    }

    public String getAdmin_mobile() {
        return admin_mobile;
    }

    public void setAdmin_mobile(String admin_mobile) {
        this.admin_mobile = admin_mobile;
    }

    public String getIp_address() {
        return ip_address;
    }

    public void setIp_address(String ip_address) {
        this.ip_address = ip_address;
    }

    public String getUrl() {
        return url;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) { this.username = username; }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) { this.password = password; }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getTimezone() {
        return timezone;
    }

    public void setTimezone(String timezone) {
        this.timezone = timezone;
    }
}
