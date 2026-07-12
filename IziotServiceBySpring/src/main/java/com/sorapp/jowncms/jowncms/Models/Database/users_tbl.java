package com.sorapp.jowncms.jowncms.Models.Database;

import org.json.JSONObject;

import javax.persistence.*;


@Entity
@Table(name = "users_tbls")
public class users_tbl
{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    String username;
    String password;
    String name;
    String family;
    String phone;
    String email;
    String bio;
    String login_token;
    String date_time;
    String user_type;
    String status;
    String website;
    String address;
    String google_auth;
    @ManyToOne
    @JoinColumn(name = "profile_image_file_id")
    file_tbl profile_image_file_id;
    @ManyToOne
    @JoinColumn(name = "city_id")
    city_tbl city_id;

    public users_tbl FromJson(String jsonstring)
    {
        JSONObject json=new JSONObject(jsonstring);
        return new users_tbl(
                Integer.parseInt(json.get("id").toString()),
                json.get("username").toString(),
                json.get("password").toString(),
                json.get("name").toString(),
                json.get("family").toString(),
                json.get("phone").toString(),
                json.get("email").toString(),
                json.get("bio").toString(),
                json.get("login_token").toString(),
                json.get("date_time").toString(),
                json.get("user_type").toString(),
                json.get("status").toString(),
                json.get("website").toString(),
                json.get("address").toString()
        );
    }

    public users_tbl() {
    }

    public users_tbl(int id, String username, String password, String name, String family, String phone, String email, String bio, String login_token, String date_time, String user_type, String status, String website, String address) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.name = name;
        this.family = family;
        this.phone = phone;
        this.email = email;
        this.bio = bio;
        this.login_token = login_token;
        this.date_time = date_time;
        this.user_type = user_type;
        this.status = status;
        this.website = website;
        this.address = address;
    }

    public users_tbl(String username, String password, String name, String family, String phone, String email, String bio, String login_token, String date_time, String user_type, String status, String website, String address, String google_auth, file_tbl profile_image_file_id, city_tbl city_id) {
        this.username = username;
        this.password = password;
        this.name = name;
        this.family = family;
        this.phone = phone;
        this.email = email;
        this.bio = bio;
        this.login_token = login_token;
        this.date_time = date_time;
        this.user_type = user_type;
        this.status = status;
        this.website = website;
        this.address = address;
        this.google_auth = google_auth;
        this.profile_image_file_id = profile_image_file_id;
        this.city_id = city_id;
    }

    public users_tbl(String username, String password, String name, String family, String phone, String email, String bio, String login_token, String date_time, String user_type, String status, String website, String address, String google_auth, city_tbl city_id) {
        this.username = username;
        this.password = password;
        this.name = name;
        this.family = family;
        this.phone = phone;
        this.email = email;
        this.bio = bio;
        this.login_token = login_token;
        this.date_time = date_time;
        this.user_type = user_type;
        this.status = status;
        this.website = website;
        this.address = address;
        this.google_auth = google_auth;
        this.city_id = city_id;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getFamily() {
        return family;
    }

    public void setFamily(String family) {
        this.family = family;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getLogin_token() {
        return login_token;
    }

    public void setLogin_token(String login_token) {
        this.login_token = login_token;
    }

    public String getDate_time() {
        return date_time;
    }

    public void setDate_time(String date_time) {
        this.date_time = date_time;
    }

    public String getUser_type() {
        return user_type;
    }

    public void setUser_type(String user_type) {
        this.user_type = user_type;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getGoogle_auth() {
        return google_auth;
    }

    public void setGoogle_auth(String google_auth) {
        this.google_auth = google_auth;
    }

    public file_tbl getProfile_image_id() {
        return profile_image_file_id;
    }

    public void setProfile_image_id(file_tbl profile_image_id) {
        this.profile_image_file_id = profile_image_id;
    }

    public city_tbl getCity_id() {
        return city_id;
    }

    public void setCity_id(city_tbl city_id) {
        this.city_id = city_id;
    }
}

