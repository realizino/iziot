package com.sorapp.jowncms.jowncms.Models.Database;

import javax.persistence.*;

@Entity
@Table(name = "temperatures_arch_tbl")
public class temperatures_arch_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;

    int hub_id;
    String date_time;
    String temperature;
    String attribute;

    public temperatures_arch_tbl(){

    }

    public temperatures_arch_tbl(int id, int hub_id, String date_time, String temperature, String attribute) {
        this.id = id;
        this.hub_id = hub_id;
        this.date_time = date_time;
        this.temperature = temperature;
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

    public String getTemperature() {
        return temperature;
    }

    public void setTemperature(String temperature) {
        this.temperature = temperature;
    }

    public String getAttribute() {
        return attribute;
    }

    public void setAttribute(String attribute) {
        this.attribute = attribute;
    }
}
