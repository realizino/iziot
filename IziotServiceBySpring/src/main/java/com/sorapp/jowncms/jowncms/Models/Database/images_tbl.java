package com.sorapp.jowncms.jowncms.Models.Database;

import javax.persistence.*;

@Entity
@Table(name = "images_tbl")
public class images_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    @ManyToOne
    @JoinColumn(name = "hub_id")
    hub_tbl hub_id;
    String date_time;
    String file_address;
    String status;
    String resolution;
    String size;
    String lat;
    String lng;

    public images_tbl(){

    }

    public images_tbl(int id, hub_tbl hub_id, String date_time, String file_address, String status, String resolution, String size, String lat, String lng) {
        this.id = id;
        this.hub_id = hub_id;
        this.date_time = date_time;
        this.file_address = file_address;
        this.status = status;
        this.resolution = resolution;
        this.size = size;
        this.lat = lat;
        this.lng = lng;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public hub_tbl getHub_id() {
        return hub_id;
    }

    public void setHub_id(hub_tbl hub_id) {
        this.hub_id = hub_id;
    }

    public String getDate_time() {
        return date_time;
    }

    public void setDate_time(String date_time) {
        this.date_time = date_time;
    }

    public String getFile_address() {
        return file_address;
    }

    public void setFile_address(String file_address) {
        this.file_address = file_address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResolution() {
        return resolution;
    }

    public void setResolution(String resolution) {
        this.resolution = resolution;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
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
}
