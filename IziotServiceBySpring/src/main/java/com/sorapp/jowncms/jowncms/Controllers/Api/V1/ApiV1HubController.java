package com.sorapp.jowncms.jowncms.Controllers.Api.V1;

import com.sorapp.jowncms.jowncms.Models.Database.hub_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import com.sorapp.jowncms.jowncms.Service.File.IOTFile_Service;
import com.sorapp.jowncms.jowncms.Service.Hubs.Hub_Service;
import com.sorapp.jowncms.jowncms.Service.IOTToken.IOTToken;
import com.sorapp.jowncms.jowncms.Service.IOTToken.IOTToken_Model;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/V1")
public class ApiV1HubController
{

    @Autowired
    Hub_Service HubService;

    @Autowired
    IOTFile_Service IotFileService;

    @Value("${IotFileRepo}")
    String Repository;

    @Value("${middledomain}")
    String MiddleDomain;


    /*************************Add hub Start**************************/
    @PostMapping("Hub/Add")
    public ResponseEntity<Map<String, Object>> AddHub(
            @RequestAttribute("authenticatedUser") users_tbl user_req,
            @RequestParam String serial_number,
            @RequestParam String title,
            @RequestParam String iot_type,
            @RequestParam String iot_model,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String resolution,
            @RequestParam String admin_number,
            @RequestParam(required = false) String ip_address,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String password,
            @RequestParam(required = false) String lat,
            @RequestParam(required = false) String lng,
            @RequestParam(required = false) String timezone,
            @RequestParam(required = false) String attribute_inpt)
    {
        Map<String, Object> response = new HashMap<>();

        try
        {
            hub_tbl n_hub = new hub_tbl();
            n_hub.setSerial_number(serial_number);
            n_hub.setTitle(title);
            n_hub.setIot_model(iot_model + "-" + MiddleDomain);
            n_hub.setIot_type(iot_type);
            n_hub.setStatus((status != null) ? status : "Enable");
            n_hub.setLat(lat);
            n_hub.setLng(lng);
            n_hub.setAdmin_mobile(admin_number);
            n_hub.setIp_address(ip_address);

            if (iot_model != null && iot_model.toUpperCase().contains("CAM")) {
                n_hub.setDefault_resolution(resolution);
            } else {
                n_hub.setDefault_resolution("-");
            }

            n_hub.setTimezone(timezone);
            n_hub.setAttribute(attribute_inpt);
            n_hub.setUsername(username);
            n_hub.setPassword(password);
            n_hub.setPermission("");

            if (iot_model != null && iot_model.contains("NEWPROTOCOL"))
                n_hub.setUrl("");
            else
                n_hub.setUrl(ip_address + "/snapshop.jpg");

            n_hub.setUser_id(user_req);

            HubService.AddNewHub(n_hub);
            IotFileService.CreateHubDirectory(Repository, n_hub.getId() + "");

            response.put("status", "200");
            response.put("message", "OK");
            response.put("hub", n_hub);
        }
        catch (Exception e)
        {
            response.put("status", "500");
            response.put("message", "Failed to add hub: " + e.getMessage());
        }

        return ResponseEntity.ok(response);
    }
    /*************************Add hub End**************************/


    /*************************List hubs Start**************************/
    @GetMapping("Hub/List")
    public ResponseEntity<Map<String, Object>> ListHubs(@RequestAttribute("authenticatedUser") users_tbl user_req)
    {
        Map<String, Object> response = new HashMap<>();

        List<hub_tbl> hubs = HubService.GetHubsByUser(user_req.getId());

        response.put("status", "200");
        response.put("message", "OK");
        response.put("hubs", hubs);

        return ResponseEntity.ok(response);
    }
    /*************************List hubs End**************************/


    /*************************Get single hub Start**************************/
    @GetMapping("Hub/{hub_id}")
    public ResponseEntity<Map<String, Object>> GetHub(
            @RequestAttribute("authenticatedUser") users_tbl user_req,
            @PathVariable String hub_id)
    {
        Map<String, Object> response = new HashMap<>();

        try
        {
            hub_tbl hub = HubService.GetHub(Integer.parseInt(hub_id));

            // Ownership check: users can only access their own hubs
            if (hub.getUser_id() == null || hub.getUser_id().getId() != user_req.getId())
            {
                response.put("status", "403");
                response.put("message", "You do not have access to this hub");
                return ResponseEntity.ok(response);
            }

            response.put("status", "200");
            response.put("message", "OK");
            response.put("hub", hub);
        }
        catch (Exception e)
        {
            response.put("status", "404");
            response.put("message", "Hub not found");
        }

        return ResponseEntity.ok(response);
    }
    /*************************Get single hub End**************************/


    /*************************Update hub Start**************************/
    @PostMapping("Hub/Update")
    public ResponseEntity<Map<String, Object>> UpdateHub(
            @RequestAttribute("authenticatedUser") users_tbl user_req,
            @RequestParam String hub_id,
            @RequestParam String serial_number,
            @RequestParam String title,
            @RequestParam String iot_type,
            @RequestParam String iot_model,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String resolution,
            @RequestParam String admin_number,
            @RequestParam(required = false) String ip_address,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String password,
            @RequestParam(required = false) String lat,
            @RequestParam(required = false) String lng,
            @RequestParam(required = false) String timezone,
            @RequestParam(required = false) String attribute_inpt)
    {
        Map<String, Object> response = new HashMap<>();

        try
        {
            int id = Integer.parseInt(hub_id);
            hub_tbl existing = HubService.GetHub(id);

            // Ownership check
            if (existing.getUser_id() == null || existing.getUser_id().getId() != user_req.getId())
            {
                response.put("status", "403");
                response.put("message", "You do not have access to this hub");
                return ResponseEntity.ok(response);
            }

            existing.setSerial_number(serial_number);
            existing.setTitle(title);
            existing.setIot_model(iot_model + "-" + MiddleDomain);
            existing.setIot_type(iot_type);
            if (status != null) existing.setStatus(status);
            existing.setLat(lat);
            existing.setLng(lng);
            existing.setAdmin_mobile(admin_number);
            existing.setIp_address(ip_address);

            if (iot_model != null && iot_model.toUpperCase().contains("CAM")) {
                existing.setDefault_resolution(resolution);
            } else {
                existing.setDefault_resolution("-");
            }

            existing.setTimezone(timezone);
            existing.setUsername(username);
            if (password != null && !password.isEmpty()) {
                existing.setPassword(password);
            }
            existing.setAttribute(attribute_inpt);
            existing.setUrl(ip_address + "/snapshop.jpg");

            HubService.UpdateHub(existing);

            response.put("status", "200");
            response.put("message", "OK");
            response.put("hub", existing);
        }
        catch (Exception e)
        {
            response.put("status", "500");
            response.put("message", "Failed to update hub: " + e.getMessage());
        }

        return ResponseEntity.ok(response);
    }
    /*************************Update hub End**************************/


    /*************************Delete hub Start**************************/
    @PostMapping("Hub/Delete/{hub_id}")
    public ResponseEntity<Map<String, Object>> DeleteHub(
            @RequestAttribute("authenticatedUser") users_tbl user_req,
            @PathVariable String hub_id)
    {
        Map<String, Object> response = new HashMap<>();

        try
        {
            int id = Integer.parseInt(hub_id);
            hub_tbl existing = HubService.GetHub(id);

            // Ownership check
            if (existing.getUser_id() == null || existing.getUser_id().getId() != user_req.getId())
            {
                response.put("status", "403");
                response.put("message", "You do not have access to this hub");
                return ResponseEntity.ok(response);
            }

            HubService.DeleteHub(id);

            response.put("status", "200");
            response.put("message", "OK");
        }
        catch (Exception e)
        {
            response.put("status", "500");
            response.put("message", "Failed to delete hub: " + e.getMessage());
        }

        return ResponseEntity.ok(response);
    }
    /*************************Delete hub End**************************/



    /*************************Get hub token Start**************************/
    @GetMapping("Hub/{hub_id}/Token")
    public ResponseEntity<Map<String, Object>> GetHubToken(
            @RequestAttribute("authenticatedUser") users_tbl user_req,
            @PathVariable String hub_id)
    {
        Map<String, Object> response = new HashMap<>();

        try
        {
            hub_tbl hub = HubService.GetHub(Integer.parseInt(hub_id));

            // Ownership check
            if (hub.getUser_id() == null || hub.getUser_id().getId() != user_req.getId())
            {
                response.put("status", "403");
                response.put("message", "You do not have access to this hub");
                return ResponseEntity.ok(response);
            }

            // Token-based access only exists for PROTOCOL-based models
            if (hub.getIot_model() == null || !hub.getIot_model().toUpperCase().contains("PROTOCOL"))
            {
                response.put("status", "400");
                response.put("message", "This device does not support token-based access");
                return ResponseEntity.ok(response);
            }

            var token = new IOTToken().GetToken(hub);

            response.put("status", "200");
            response.put("message", "OK");
            response.put("token", token);
        }
        catch (Exception e)
        {
            response.put("status", "500");
            response.put("message", "Failed to get token: " + e.getMessage());
        }

        return ResponseEntity.ok(response);
    }
    /*************************Get hub token End**************************/

}