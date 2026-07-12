package com.sorapp.jowncms.jowncms.Models.Database;

import javax.persistence.*;

@Entity
@Table(name = "file_tbls")
public class file_tbl
{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    String file_name;
    String file_address;
    String file_address_server;
    String file_type;
    String file_extention;
    String file_size;
    String file_hash;
    String file_date_time;

    public file_tbl() {
    }

    public file_tbl(String file_name, String file_address, String file_address_server, String file_type, String file_extention, String file_size, String file_hash, String file_date_time) {
        this.file_name = file_name;
        this.file_address = file_address;
        this.file_address_server = file_address_server;
        this.file_type = file_type;
        this.file_extention = file_extention;
        this.file_size = file_size;
        this.file_hash = file_hash;
        this.file_date_time = file_date_time;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFile_name() {
        return file_name;
    }

    public void setFile_name(String file_name) {
        this.file_name = file_name;
    }

    public String getFile_address() {
        return file_address;
    }

    public void setFile_address(String file_address) {
        this.file_address = file_address;
    }

    public String getFile_address_server() {
        return file_address_server;
    }

    public void setFile_address_server(String file_address_server) {
        this.file_address_server = file_address_server;
    }

    public String getFile_type() {
        return file_type;
    }

    public void setFile_type(String file_type) {
        this.file_type = file_type;
    }

    public String getFile_extention() {
        return file_extention;
    }

    public void setFile_extention(String file_extention) {
        this.file_extention = file_extention;
    }

    public String getFile_size() {
        return file_size;
    }

    public void setFile_size(String file_size) {
        this.file_size = file_size;
    }

    public String getFile_hash() {
        return file_hash;
    }

    public void setFile_hash(String file_hash) {
        this.file_hash = file_hash;
    }

    public String getFile_date_time() {
        return file_date_time;
    }

    public void setFile_date_time(String file_date_time) {
        this.file_date_time = file_date_time;
    }

}
