package com.sorapp.jowncms.jowncms.Function.Render;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.Comparator;
import java.util.logging.Logger;

public class Render
{


    //Terminal runner start
    private static final Logger logger = Logger.getLogger(Render.class.getName());

    public static void runFFmpegCommand(String[] command)
    {
        try
        {
            logger.info("Running FFmpeg command: " + String.join(" ", command));
            ProcessBuilder builder = new ProcessBuilder(command);
            builder.redirectErrorStream(true); // Merge error stream with standard output stream

            // Start the process
            Process process = builder.start();

            // Wait for the process to complete
            int exitCode = process.waitFor();

            if (exitCode == 0)
            {
                System.out.println("Render Log : Ffmpeg seccess");
            }
            else
            {
                process.getErrorStream().transferTo(System.out);
                System.out.println("Render Log : Ffmpeg not worked :(");
            }
        }
        catch (Exception e)
        {
            System.out.println("Render Log Error : "+e.getMessage());
        }
    }
    //Terminal runner end





    //Get render from frames start
    public void GetRenderTimeLaps(String DirectoryAddrs,String NFileName,String Resolution,String Password)
    {
        try
        {
            //Get write image on render file
            GetWriteImageOnFile(DirectoryAddrs,NFileName);

            //Get render
            GetRenderTimeLaps(DirectoryAddrs,Resolution,Password);
        }
        catch (Exception e)
        {
            System.out.println("Rander error : " + e.getMessage() );
        }
    }
    //Get render from frames end



    //Get render from frames start
    public void GetRenderVideo(String DirectoryAddrs,String NFileName,String Resolution,String Password)
    {
        try
        {
            //Get write image on render file
            GetWriteImageOnFile(DirectoryAddrs,NFileName);

            //Get render
            GetRenderVideo(DirectoryAddrs,Resolution,Password);
        }
        catch (Exception e)
        {
            System.out.println("Rander error : " + e.getMessage() );
        }
    }
    //Get render from frames end


    //Get write image on render file start
    private void GetWriteImageOnFile(String DirectoryAddrs,String NFileName) throws Exception
    {
        //Render list file
        File RenderFile = new File(DirectoryAddrs+"/render.txt");

        //Check render file exist
        if(RenderFile.exists())
        {
            FileWriter FW=new FileWriter(RenderFile,true);
            FW.append("file '"+DirectoryAddrs+"/"+NFileName+"'\r\n");
            FW.close();
        }
        else
        {
            FileWriter FW=new FileWriter(RenderFile,true);
            FW.write("file '"+DirectoryAddrs+"/"+NFileName+"'\r\n");
            FW.close();
        }

    }
    //Get write image on render file end


    //Get render function start
    private void GetRenderTimeLaps(String DirPath,String Resolution,String Password) throws Exception
    {
        //Get running path
        //String currentDir = System.getProperty("user.dir");
        //DirPath=currentDir+"\\"+DirPath;
        //System.out.println(currentDir);

        File directory=new File(DirPath);
        File [] ListOfFile = directory.listFiles();

        Arrays.sort(ListOfFile, Comparator.comparingLong(File::lastModified));

        String Result="";
        for(int i=0;i< ListOfFile.length;i++)
        {
            Result+="file '/" + DirPath + "/" +ListOfFile[i].getName()+"'\r\n";
            //System.out.println("file '" + address + "/" +ListOfFile[i].getName()+"'");
        }

        File outfile=new File(DirPath+"/render.txt");
        FileWriter fw=new FileWriter(outfile);
        fw.write(Result);
        fw.close();
        System.out.println("-------------------------------------------------------------------");
        System.out.println("Render file is ready");

        //String Command="ffmpeg -y -r 25 -f concat -safe 0 -i \""+DirPath+"/"+"render.txt"+"\" -c:v libx264 -vf \"fps=25,format=yuv420p\" \""+DirPath+"/"+"out.mp4"+"\"";
        //String Command="echo \"@Key123456\" | sudo -S ffmpeg -y -r 25 -f concat -safe 0 -i \"/"+DirPath+"/render.txt\" -c:v libx264 -vf \"fps=25,format=yuv420p\" \"/home/iziot/Files/out.mp4\"";
        //String Commnad = "ffmpeg -y -r 25 -f concat -safe 0 -i \"/"+DirPath+"/render.txt\" -c:v libx264 -vf \"fps=25,format=yuv420p\" \"/home/iziot/Files/out.mp4\"";
        //System.out.println(Commnad);
//        Runtime runtime=Runtime.getRuntime();
//        runtime.exec(Commnad);


        /*******************************************************************/
//        String[] ffmpegCommand = {
//                "ffmpeg",
//                "-y",
//                "-r", "25",
//                "-f", "concat",
//                "-safe", "0",
//                "-i", "/"+DirPath+"/render.txt",
//                "-c:v", "libx264",
//                "-vf", "fps=25,format=yuv420p",
//                "/home/iziot/Files/out.mp4"
//        };
//        runFFmpegCommand(ffmpegCommand);
        /**********************************************************************/


        try
        {
            // Command to be executed
            String command = "echo \""+Password+"\" | sudo -S ffmpeg -y -r 25 -f concat -safe 0 -i \"/"+DirPath+"/render.txt\" -c:v libx264 -vf \"fps=25,format=yuv420p\" \"/home/iziot/Files/out.mp4\"";

            // Create a process to execute the command
            ProcessBuilder processBuilder = new ProcessBuilder("bash", "-c", command);
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();

            System.out.println("Render command : "+command);

            // Read the output from the command
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null)
            {
                System.out.println(line);
            }

            // Wait for the process to complete
            int exitCode = process.waitFor();
            System.out.println("Exited with code: " + exitCode);
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }


        System.out.println("Rendered is end");
        System.out.println("-------------------------------------------------------------------");
    }
    //Get render function end




    //Get render function start
    private void GetRenderVideo(String DirPath,String Resolution,String Password) throws Exception
    {
        //Get running path
        //String currentDir = System.getProperty("user.dir");
        //DirPath=currentDir+"\\"+DirPath;
        //System.out.println(currentDir);

        File directory=new File(DirPath);
        File [] ListOfFile = directory.listFiles();

        Arrays.sort(ListOfFile, Comparator.comparingLong(File::lastModified));

        String Result="";
        for(int i=0;i< ListOfFile.length;i++)
        {
            Result+="file '/" + DirPath + "/" +ListOfFile[i].getName()+"'\r\n";
            //System.out.println("file '" + address + "/" +ListOfFile[i].getName()+"'");
        }

        File outfile=new File(DirPath+"/render.txt");
        FileWriter fw=new FileWriter(outfile);
        fw.write(Result);
        fw.close();
        System.out.println("-------------------------------------------------------------------");
        System.out.println("Render file is ready");

        try
        {
            // Command to be executed
            String command = "echo \""+Password+"\" | sudo -S ffmpeg -f concat -safe 0 -i \"/"+DirPath+"/render.txt\" -c:v libx264 -pix_fmt yuv420p -vf \"fps=30,format=yuv420p\" \"/home/iziot/Files/out.mp4\"";

            // Create a process to execute the command
            ProcessBuilder processBuilder = new ProcessBuilder("bash", "-c", command);
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();

            System.out.println("Render command : "+command);

            // Read the output from the command
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null)
            {
                System.out.println(line);
            }

            // Wait for the process to complete
            int exitCode = process.waitFor();
            System.out.println("Exited with code: " + exitCode);
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }


        System.out.println("Rendered is end");
        System.out.println("-------------------------------------------------------------------");
    }
    //Get render function end


}