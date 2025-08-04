package com.verifyVisitor;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class SMSUtil {

    // MSG91 Flow API Configuration
    private static final String SMS_API_URL = "https://api.msg91.com/api/v5/flow/";
    private static final String API_KEY = "67c17c06d6fc05147434a752";
    private static final String FLOW_ID = "YOUR_FLOW_ID"; // Replace with your actual Flow ID from MSG91 dashboard
    private static final String SENDER_ID = "TXTUVC";

    /**
     * Sends OTP via MSG91 Flow API
     * @param phoneNumber - Mobile number (10 digits without country code)
     * @param otp - Generated OTP
     * @return true if SMS sent successfully, false otherwise
     */
    public static boolean sendOTP(String phoneNumber, String otp) {
        try {
            // Clean phone number - remove any spaces or special characters
            phoneNumber = phoneNumber.replaceAll("[^0-9]", "");
            
            // Validate phone number
            if (phoneNumber.length() != 10) {
                System.out.println("Invalid phone number format: " + phoneNumber);
                return false;
            }
            
            return sendViaMSG91Flow(phoneNumber, otp);
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Send OTP using MSG91 Flow API
     */
    private static boolean sendViaMSG91Flow(String phoneNumber, String otp) {
        try {
            // Prepare JSON data for Flow API
            String jsonData = "{\n" +
                "  \"flow_id\": \"" + FLOW_ID + "\",\n" +
                "  \"sender\": \"" + SENDER_ID + "\",\n" +
                "  \"mobiles\": \"91" + phoneNumber + "\",\n" +
                "  \"OTP\": \"" + otp + "\"\n" +
                "}";

            System.out.println("Sending SMS to: 91" + phoneNumber);
            System.out.println("JSON Data: " + jsonData);

            // Create connection
            URL url = new URL(SMS_API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setDoOutput(true);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("authkey", API_KEY);

            // Send JSON data
            OutputStream os = conn.getOutputStream();
            os.write(jsonData.getBytes("UTF-8"));
            os.flush();
            os.close();

            // Get response code
            int responseCode = conn.getResponseCode();
            System.out.println("Response Code: " + responseCode);

            // Read response
            BufferedReader br;
            if (responseCode == 200) {
                br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            } else {
                br = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
            }
            
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            br.close();

            System.out.println("MSG91 Flow Response: " + response.toString());

            // Check if successful
            boolean success = responseCode == 200 && 
                             response.toString().contains("\"type\":\"success\"");
            
            if (success) {
                System.out.println("SMS sent successfully to: " + phoneNumber);
            } else {
                System.out.println("SMS failed for: " + phoneNumber);
                System.out.println("Response: " + response.toString());
            }
            
            return success;

        } catch (Exception e) {
            System.out.println("Exception in sending SMS: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}