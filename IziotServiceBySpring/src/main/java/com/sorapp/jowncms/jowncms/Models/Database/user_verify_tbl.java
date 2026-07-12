package com.sorapp.jowncms.jowncms.Models.Database;

import javax.persistence.*;

@Entity
@Table(name = "user_verify_tbls")
public class user_verify_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    String hash_code;
    @ManyToOne
    @JoinColumn(name = "user_id")
    users_tbl user_id;

    public user_verify_tbl() {
    }

    public user_verify_tbl(String hash_code, users_tbl user_id) {
        this.hash_code = hash_code;
        this.user_id = user_id;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getHash_code() {
        return hash_code;
    }

    public void setHash_code(String hash_code) {
        this.hash_code = hash_code;
    }

    public users_tbl getUser_id() {
        return user_id;
    }

    public void setUser_id(users_tbl user_id) {
        this.user_id = user_id;
    }
}
