package com.verifyVisitor;

import java.util.Random;
import java.util.HashMap;
import java.util.Map;

public class OTPUtil {
    private static final int OTP_LENGTH = 6;
    private static final long OTP_EXPIRY_TIME = 5 * 60 * 1000; // 5 minutes in milliseconds
    
    // In-memory storage for OTPs (in production, use Redis or database)
    private static Map<String, OTPData> otpStorage = new HashMap<>();
    
    // Inner class to store OTP with timestamp
    private static class OTPData {
        String otp;
        long timestamp;
        boolean used; // Add this field
        
        OTPData(String otp, long timestamp) {
            this.otp = otp;
            this.timestamp = timestamp;
            this.used = false;
        }
    }
    
    // Generate random 6-digit OTP
    public static String generateOTP() {
        Random random = new Random();
        StringBuilder otp = new StringBuilder();
        
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(random.nextInt(10));
        }
        
        return otp.toString();
    }
    
    // Store OTP for a mobile number
    public static void storeOTP(String mobileNo, String otp) {
        otpStorage.put(mobileNo, new OTPData(otp, System.currentTimeMillis()));
    }
    
    // Verify OTP
 // Add this updated verifyOTP method to your OTPUtil class
    public static boolean verifyOTP(String mobileNo, String enteredOTP) {
        System.out.println("=== OTP Verification Debug ===");
        System.out.println("Mobile Number: " + mobileNo);
        System.out.println("Entered OTP: " + enteredOTP);
        
        OTPData otpData = otpStorage.get(mobileNo);
        System.out.println("OTP Data found: " + (otpData != null));
        
        if (otpData == null) {
            System.out.println("No OTP found for mobile: " + mobileNo);
            System.out.println("Available mobile numbers in storage: " + otpStorage.keySet());
            return false;
        }
        
        System.out.println("Stored OTP: " + otpData.otp);
        System.out.println("OTP Timestamp: " + otpData.timestamp);
        System.out.println("Current Time: " + System.currentTimeMillis());
        
        
        if (otpData.used) {
            System.out.println("OTP already used!");
            return false;
        }
        
        // Check if OTP has expired
        long elapsed = System.currentTimeMillis() - otpData.timestamp;
        System.out.println("Elapsed time: " + elapsed + " ms");
        System.out.println("Expiry time: " + OTP_EXPIRY_TIME + " ms");
        
        if (elapsed > OTP_EXPIRY_TIME) {
            System.out.println("OTP has expired!");
            otpStorage.remove(mobileNo);
            return false;
        }
        
        // Check if OTP matches
        boolean matches = otpData.otp.equals(enteredOTP);
        System.out.println("OTP matches: " + matches);
        
        if (matches) {
            System.out.println("OTP verification successful!");
            otpStorage.remove(mobileNo); // Remove OTP after successful verification
            return true;
        }
        
        System.out.println("OTP verification failed!");
        return false;
    }
    // Remove OTP (for cleanup)
    public static void removeOTP(String mobileNo) {
        otpStorage.remove(mobileNo);
    }
    
    // Check if OTP exists and is valid
    public static boolean isOTPValid(String mobileNo) {
        OTPData otpData = otpStorage.get(mobileNo);
        
        if (otpData == null) {
            return false;
        }
        
        // Check if expired
        if (System.currentTimeMillis() - otpData.timestamp > OTP_EXPIRY_TIME) {
            otpStorage.remove(mobileNo);
            return false;
        }
        
        return true;
    }
    
    // Get remaining time for OTP expiry (in seconds)
    public static long getRemainingTime(String mobileNo) {
        OTPData otpData = otpStorage.get(mobileNo);
        
        if (otpData == null) {
            return 0;
        }
        
        long elapsed = System.currentTimeMillis() - otpData.timestamp;
        long remaining = (OTP_EXPIRY_TIME - elapsed) / 1000;
        
        return remaining > 0 ? remaining : 0;
    }
}