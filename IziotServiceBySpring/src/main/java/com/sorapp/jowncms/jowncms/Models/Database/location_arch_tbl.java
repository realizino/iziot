package com.sorapp.jowncms.jowncms.Models.Database;

import javax.persistence.*;

@Entity
@Table(name = "location_arch_tbl")
public class location_arch_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;

    int hub_id;
    String date_time;
    String lat;
    String lng;
    String attribute;

    public location_arch_tbl(){

    }

    public location_arch_tbl(int id, int hub_id, String date_time, String lat, String lng, String attribute) {
        this.id = id;
        this.hub_id = hub_id;
        this.date_time = date_time;
        this.lat = lat;
        this.lng = lng;
        this.attribute = attribute;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getHub_id() {
        return hub_id;
    }

    public void setHub_id(int hub_id) {
        this.hub_id = hub_id;
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
}