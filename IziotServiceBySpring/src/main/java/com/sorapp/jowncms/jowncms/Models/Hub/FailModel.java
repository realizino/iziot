package com.sorapp.jowncms.jowncms.Models.Hub;

public class FailModel
{

    String serial;
    int fail;

    public FailModel()
    {
    }

    public FailModel(String serial, int fail)
    {
        this.serial = serial;
        this.fail = fail;
    }

    public String getSerial() {
        return serial;
    }

    public void setSerial(String serial) {
        this.serial = serial;
    }

    public int getFail() {
        return fail;
    }

    public void setFail(int fail) {
        this.fail = fail;
    }
}
