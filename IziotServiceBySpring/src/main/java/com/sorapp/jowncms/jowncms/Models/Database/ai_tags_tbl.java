package com.sorapp.jowncms.jowncms.Models.Database;

import javax.persistence.*;

@Entity
@Table(name = "ai_tags_tbl")
public class ai_tags_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    @ManyToOne
    @JoinColumn(name = "image_id")
    images_tbl image_id;
    String date_time;
    String tags;

    public ai_tags_tbl(){

    }

    public ai_tags_tbl(int id, images_tbl image_id, String date_time, String tags) {
        this.id = id;
        this.image_id = image_id;
        this.date_time = date_time;
        this.tags = tags;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public images_tbl getImage_id() {
        return image_id;
    }

    public void setImage_id(images_tbl image_id) {
        this.image_id = image_id;
    }

    public String getDate_time() {
        return date_time;
    }

    public void setDate_time(String date_time) {
        this.date_time = date_time;
    }

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }
}
