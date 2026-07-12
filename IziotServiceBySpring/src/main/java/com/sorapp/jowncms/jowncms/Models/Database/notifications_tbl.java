package com.sorapp.jowncms.jowncms.Models.Database;

import javax.persistence.*;

@Entity
@Table(name = "notifications_tbls")
public class notifications_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    String title;
    String content;
    String link;
    String from_user;
    boolean seen;
    @ManyToOne
    @JoinColumn(name = "user_id")
    users_tbl user_id;

    public notifications_tbl() {
    }

    public notifications_tbl(String title, String content, String link, String from_user, boolean seen, users_tbl user_id) {
        this.title = title;
        this.content = content;
        this.link = link;
        this.from_user = from_user;
        this.seen = seen;
        this.user_id = user_id;
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

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
    }

    public String getFrom() {
        return from_user;
    }

    public void setFrom(String from_user) {
        this.from_user = from_user;
    }

    public boolean isSeen() {
        return seen;
    }

    public void setSeen(boolean seen) {
        this.seen = seen;
    }

    public users_tbl getUser_id() {
        return user_id;
    }

    public void setUser_id(users_tbl user_id) {
        this.user_id = user_id;
    }
}
