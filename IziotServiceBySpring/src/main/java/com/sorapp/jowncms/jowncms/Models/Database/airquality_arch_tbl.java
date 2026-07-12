package com.sorapp.jowncms.jowncms.Models.Database;

import javax.persistence.*;

@Entity
@Table(name = "airquality_arch_tbl")
public class airquality_arch_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    int hub_id;
    String date_time;
    String value;
    String attribute;

    public airquality_arch_tbl(){

    }

    public airquality_arch_tbl(int id, int hub_id, String date_time, String value, String attribute) {
        this.id = id;
        this.hub_id = hub_id;
        this.date_time = date_time;
        this.value = value;
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

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getAttribute() {
        return attribute;
    }

    public void setAttribute(String attribute) {
        this.attribute = attribute;
    }
}
