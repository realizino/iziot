package com.sorapp.jowncms.jowncms.Service.Images;

import com.sorapp.jowncms.jowncms.Models.Database.images_arch_tbl;
import com.sorapp.jowncms.jowncms.Models.Database.images_tbl;
import com.sorapp.jowncms.jowncms.Concepts.IImages;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class Images_Service implements IImages
{

    //Global variables
    @Autowired
    private SessionFactory sessionFactory;


    @Override
    public void AddNewImage(images_tbl img)
    {
        try(Session session=sessionFactory.openSession())
        {
            session.beginTransaction();
            session.save(img);
            session.getTransaction().commit();
        }
    }

    @Override
    public images_tbl GetImageByid(int id)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (images_tbl) session.createQuery("FROM images_tbl image WHERE image.id="+id+" order by image.id desc ").list().get(0);
        }
    }

    @Override
    public images_tbl GetLastImageBySerialNumber(String serial)
    {
        try(Session session=sessionFactory.openSession())
        {
            return (images_tbl) session.createQuery("FROM images_tbl image WHERE image.hub_id.serial_number="+serial+" order by image.id desc ").list().get(0);
        }
    }

    @Override
    public int GetCountOfImagesInADay(String serial)
    {
        LocalDateTime CurrentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String formattedDate = CurrentDateTime.format(formatter);

        try(Session session=sessionFactory.openSession())
        {
            //return session.createQuery("FROM images_tbl images WHERE images.date_time LIKE '%"+formattedDate+"%' ORDER BY rand(),images.date_time desc").setMaxResults(10).list();
            return session.createQuery("FROM images_tbl images WHERE images.date_time LIKE '%"+formattedDate+"%' AND images.hub_id.serial_number LIKE '%"+serial+"%' ORDER BY images.id desc").setMaxResults(24).list().size();
        }
    }

    @Override
    public List<images_tbl> GetRandomImagesFromToDay(String serial)
    {
        LocalDateTime CurrentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String formattedDate = CurrentDateTime.format(formatter);

        try(Session session=sessionFactory.openSession())
        {
            //return session.createQuery("FROM images_tbl images WHERE images.date_time LIKE '%"+formattedDate+"%' ORDER BY rand(),images.date_time desc").setMaxResults(10).list();
            return session.createQuery("FROM images_tbl images WHERE MOD(images.id , 120) = 0 AND images.date_time LIKE '%"+formattedDate+"%' AND images.hub_id.serial_number LIKE '%"+serial+"%' ORDER BY images.id desc").setMaxResults(24).list();
        }
    }

    @Override
    public List<images_tbl> GetRandomImagesFromToDay(String serial, int rate)
    {
        LocalDateTime CurrentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String formattedDate = CurrentDateTime.format(formatter);

        try(Session session=sessionFactory.openSession())
        {
            //return session.createQuery("FROM images_tbl images WHERE images.date_time LIKE '%"+formattedDate+"%' ORDER BY rand(),images.date_time desc").setMaxResults(10).list();
            return session.createQuery("FROM images_tbl images WHERE MOD(images.id , "+rate+") = 0 AND images.date_time LIKE '%"+formattedDate+"%' AND images.hub_id.serial_number LIKE '%"+serial+"%' ORDER BY images.id desc").setMaxResults(24).list();
        }
    }

    @Override
    public List<images_tbl> Get24Image(String serial)
    {
//        // Get the current date and time
//        LocalDateTime currentDateTime = LocalDateTime.now();
//
//        // Define a formatter for the desired date format
//        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
//
//        // Format the current date into a String
//        String formattedDate = currentDateTime.format(dateFormatter);
//
//        // Define a formatter for the time (e.g., HH:mm:ss for 24-hour format)
//        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm:ss");
//
//        // Format the current time into a String
//        String formattedTime = currentDateTime.format(timeFormatter);
//
//        // You can also get individual time components as integers
//        int hour = currentDateTime.getHour();
//        int minute = currentDateTime.getMinute();
//        int second = currentDateTime.getSecond();
//        int nano = currentDateTime.getNano(); // Nanoseconds
//
//        // Print the results to verify
////        System.out.println("Current Date and Time: " + currentDateTime);
////        System.out.println("Formatted Date: " + formattedDate);
////        System.out.println("Formatted Time: " + formattedTime);
////        System.out.println("Hour: " + hour);
////        System.out.println("Minute: " + minute);
////        System.out.println("Second: " + second);
////        System.out.println("Nanosecond: " + nano);
//
//        // You can assign these to other variables as needed:
//        String myDateVariable = formattedDate;
//        String myTimeVariable = formattedTime;
//        int myHourVariable = hour;
//        int myMinuteVariable = minute;
//
//        try(Session session=sessionFactory.openSession())
//        {
//            //return session.createQuery("FROM images_tbl images WHERE images.date_time LIKE '%"+formattedDate+"%' ORDER BY rand(),images.date_time desc").setMaxResults(10).list();
//            return session.createQuery("FROM images_tbl images " +
//                    "                       WHERE (images.date_time LIKE '%"+formattedDate+"T"+hour+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-1)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-2)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-3)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-4)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-5)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-6)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-7)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-8)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-9)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-10)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-11)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-12)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-13)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-14)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-15)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-16)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-17)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-18)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-19)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-20)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-21)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-22)+":"+minute+"%' " +
//                    "                               OR images.date_time LIKE '%"+formattedDate+"T"+(hour-23)+":"+minute+"%' " +
//                    "                     ) " +
//                    "                       AND images.hub_id.serial_number LIKE '%"+serial+"%' " +
//                    "                       ORDER BY images.id desc").setMaxResults(24).list();
//        }

        DateTimeFormatter DATABASE_DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
        List<images_tbl> resultImages = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        try (Session session = sessionFactory.openSession()) {
            for (int i = 0; i < 24; i++) {
                LocalDateTime targetDateTime = now.minusHours(i);

                LocalDateTime specificTimePoint = targetDateTime
                        .withMinute(1) // Set the desired minute (e.g., 1 for :01)
                        .withSecond(0)
                        .withNano(0);

                LocalDateTime searchStartPoint = specificTimePoint.minusMinutes(1).minusSeconds(30);
                LocalDateTime searchEndPoint = specificTimePoint.plusMinutes(1).plusSeconds(30);

                // Format these LocalDateTime objects into the String format your database uses
                String searchStartString = searchStartPoint.format(DATABASE_DATE_TIME_FORMATTER);
                String searchEndString = searchEndPoint.format(DATABASE_DATE_TIME_FORMATTER);

                String hql = "FROM images_tbl images " +
                        "WHERE images.hub_id.serial_number = :serial " +
                        "AND images.date_time BETWEEN :searchStartString AND :searchEndString " +
                        "ORDER BY images.date_time DESC"; // Fallback: just get the latest within the range

                images_tbl image = (images_tbl) session.createQuery(hql)
                        .setParameter("serial", serial)
                        .setParameter("searchStartString", searchStartString)
                        .setParameter("searchEndString", searchEndString)
                        .setMaxResults(1)
                        .uniqueResult();

                if (image != null) {
                    resultImages.add(image);
                }
            }
        } catch (Exception e) {
            System.err.println("Error fetching images: " + e.getMessage());
            // Log the exception properly in a production environment
        }
        return resultImages;
    }

    @Override
    public void ArchiveImages()
    {
        try(Session session=sessionFactory.openSession())
        {
            List<images_tbl> imgs = session.createQuery("FROM images_tbl img order by img.id desc").list();
            for(int i=0;i<imgs.size() - 1200;i++)
            {
                images_arch_tbl arch=new images_arch_tbl();

                arch.setDate_time(imgs.get(i).getDate_time());
                arch.setHub_id(imgs.get(i).getHub_id().getId());
                arch.setLat(imgs.get(i).getLat());
                arch.setLng(imgs.get(i).getLng());
                arch.setResolution(imgs.get(i).getResolution());
                arch.setSize(imgs.get(i).getSize());
                arch.setFile_address(imgs.get(i).getFile_address());
                arch.setStatus(imgs.get(i).getStatus());

                session.beginTransaction();
                session.save(arch);
                session.getTransaction().commit();
            }

        }
        try (Session session = sessionFactory.openSession())
        {
            session.beginTransaction();
            session.createQuery("DELETE FROM images_tbl ").executeUpdate();
            session.getTransaction().commit();
        }
    }


}
