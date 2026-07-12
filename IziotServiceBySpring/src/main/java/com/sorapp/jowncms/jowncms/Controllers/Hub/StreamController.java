package com.sorapp.jowncms.jowncms.Controllers.Hub;

import com.sorapp.jowncms.jowncms.Service.Images.Images_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.concurrent.atomic.AtomicBoolean;

@RestController
@RequestMapping("/Stream")
public class StreamController {

    @Autowired
    Images_Service ImageService;

    @GetMapping(value = "/HubStream/{hub_serial}", produces = "multipart/x-mixed-replace;boundary=frameboundary")
    public ResponseEntity<StreamingResponseBody> streamFrames(@PathVariable String hub_serial) {

        StreamingResponseBody body = new StreamingResponseBody() {
            @Override
            public void writeTo(OutputStream os) throws IOException {
                AtomicBoolean isRunning = new AtomicBoolean(true);
                int errorCount = 0;
                final int MAX_ERRORS = 5;
                final long START_TIME = System.currentTimeMillis();
                final long TIMEOUT_MS = 10 * 60 * 1000; // 10 minutes

                try {
                    while (isRunning.get() && !Thread.currentThread().isInterrupted() && errorCount < MAX_ERRORS) {
                        // Check if 10 minutes have passed
                        if (System.currentTimeMillis() - START_TIME >= TIMEOUT_MS) {
                            System.out.println("Stream timeout: 10 minutes reached, closing connection");
                            isRunning.set(false);
                            break;
                        }
                        try {
                            String imagePath = ImageService.GetLastImageBySerialNumber(hub_serial).getFile_address();

                            if (imagePath == null || imagePath.isEmpty()) {
                                Thread.sleep(500);
                                continue;
                            }

                            File imageFile = new File(imagePath);

                            if (imageFile.exists() && imageFile.isFile() && imageFile.canRead()) {
                                try {
                                    byte[] imageBytes = Files.readAllBytes(imageFile.toPath());

                                    if (imageBytes != null && imageBytes.length > 0) {
                                        try {
                                            // Write boundary
                                            os.write("--frameboundary\r\n".getBytes());

                                            // Write headers
                                            os.write("Content-Type: image/jpeg\r\n".getBytes());
                                            os.write(("Content-Length: " + imageBytes.length + "\r\n\r\n").getBytes());

                                            // Write image data
                                            os.write(imageBytes);

                                            // Write CRLF
                                            os.write("\r\n".getBytes());

                                            os.flush();
                                            errorCount = 0; // Reset error count on successful write

                                        } catch (IOException e) {
                                            errorCount++;
                                            System.err.println("Error writing to stream (attempt " + errorCount + "): " + e.getMessage());
                                            if (errorCount >= MAX_ERRORS) {
                                                System.err.println("Max errors reached, stopping stream");
                                                isRunning.set(false);
                                            }
                                            Thread.sleep(1000); // Wait before retry
                                        }
                                    }
                                } catch (IOException e) {
                                    errorCount++;
                                    System.err.println("Error reading image file: " + e.getMessage());
                                }
                            }

                            // Wait before next frame
                            Thread.sleep(500);

                        } catch (InterruptedException e) {
                            System.out.println("Stream interrupted");
                            isRunning.set(false);
                            Thread.currentThread().interrupt();
                        } catch (Exception e) {
                            errorCount++;
                            System.err.println("Error streaming frame: " + e.getMessage());
                            e.printStackTrace();
                        }
                    }
                } finally {
                    isRunning.set(false);
                    try {
                        os.close();
                    } catch (IOException e) {
                        System.err.println("Error closing stream: " + e.getMessage());
                    }
                }
            }
        };

        HttpHeaders headers = new HttpHeaders();
        headers.add("Cache-Control", "no-cache, no-store, must-revalidate");
        headers.add("Pragma", "no-cache");
        headers.add("Expires", "0");
        headers.add("Connection", "keep-alive");

        return ResponseEntity
                .ok()
                .headers(headers)
                .contentType(org.springframework.http.MediaType.valueOf("multipart/x-mixed-replace;boundary=frameboundary"))
                .body(body);
    }
}