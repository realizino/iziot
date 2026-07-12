package com.sorapp.jowncms.jowncms.Service.IOTToken;

import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import org.springframework.stereotype.Component;

@Component
public class IOTToken
{

    public IOTToken_Model GetToken(hub_tbl hub_data)
    {
        String []hbs_url = hub_data.getIot_model().split("-");
        return new IOTToken_Model(
                hub_data.getId(),
                hbs_url[hbs_url.length - 1],
                hub_data.getAttribute(),
                hub_data.getDefault_resolution().replace("×"," ")
        );
    }

}
