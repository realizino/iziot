package com.sorapp.jowncms.jowncms.SMTP;

import com.sorapp.jowncms.jowncms.Service.Users.Users_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.stereotype.Service;

import java.util.Properties;

@Service
public class Mail
{

    @Autowired
    Users_Service usersService;


    //Send mail when constract start
    public Mail()
    {
        System.out.println("salam");
        try
        {
            System.out.println("Mail start sending");
//            SendSimpleEmail("rezafarazi1378@gmail.com", "iziot", "iziot Service started");
            System.out.println("Mail start sended");
        }
        catch (Exception e)
        {
            System.out.println(e.getMessage());
        }
    }
    //Send mail when constract end


    //Send mail funtion start
    public void SendSimpleEmail(String to, String subject, String text)
    {
        try
        {
            JavaMailSenderImpl mailSender = new JavaMailSenderImpl();
            mailSender.setHost("mail12.ezhostingserver.com");
            mailSender.setPort(587);

            mailSender.setUsername("noreply@iziot.ir");
            mailSender.setPassword("Rf&gt;29dYP");

            Properties props = mailSender.getJavaMailProperties();
            props.put("mail.transport.protocol", "smtp");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.debug", "true");

            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject(subject);
            message.setText(text);
            message.setFrom("NoReply@iziot.ir");

            mailSender.send(message);
        }
        catch (Exception e)
        {

        }
    }
    //Send mail funtion end

}
