package com.sorapp.jowncms.jowncms.Models.Database;

import javax.persistence.*;

@Entity
@Table(name = "settings_tbls")
public class settings_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;

    String Version;

    @Column(columnDefinition = "LONGTEXT")
    String ESP32CAM_Code;

    @Column(columnDefinition = "LONGTEXT")
    String config;


    public settings_tbl() {
    }


    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getVersion() {
        return Version;
    }

    public void setVersion(String version) {
        Version = version;
    }

    public String getESP32CAM_Code() {
        return ESP32CAM_Code;
    }

    public void setESP32CAM_Code(String ESP32CAM_Code) {
        this.ESP32CAM_Code = ESP32CAM_Code;
    }

    public String getConfig() {
        return config;
    }

    public void setConfig(String config) {
        this.config = config;
    }
}