package com.verifyVisitor;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

//@WebServlet({"/GenerateOTPServlet", "/generateOTP"}) // Added both mappings
public class GenerateOTPServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check if it's an employee or security login
        String empId = (String) session.getAttribute("empId");
        String securityId = (String) session.getAttribute("securityId");
        String userRole = (String) session.getAttribute("userRole");

        String phoneNumber = null;
        String userName = null;
        String userType = null;
        String detailsPageRedirect = null;
        String verifyPageRedirect = "verifyOTP.jsp"; // Shared OTP page

        if ("security".equalsIgnoreCase(userRole) || securityId != null) {
            // Security login
            phoneNumber = (String) session.getAttribute("securityPhone");
            userName = (String) session.getAttribute("securityName");
            userType = "Security";
            detailsPageRedirect = "viewSecurityDetails.jsp";
            
            // Fallback to request parameters if not in session
            if (phoneNumber == null) {
                phoneNumber = request.getParameter("mobileNo");
            }
            if (userName == null) {
                userName = request.getParameter("name");
            }
        } else if (empId != null) {
            // Employee login
            phoneNumber = (String) session.getAttribute("empPhone");
            userName = (String) session.getAttribute("empName");
            userType = "Employee";
            detailsPageRedirect = "viewEmployeeDetails.jsp";
        } else {
            response.sendRedirect("EmployeeLogin.jsp?error=Session+expired.+Please+login+again");
            return;
        }

        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            response.sendRedirect(detailsPageRedirect + "?error=Mobile+number+not+found");
            return;
        }
        
     // Add this debug code in GenerateOTPServlet before generating OTP
        System.out.println("=== GenerateOTPServlet Debug ===");
        System.out.println("Employee ID from session: " + empId);
        System.out.println("Phone from session: " + session.getAttribute("empPhone"));
        System.out.println("User role: " + userRole);

        phoneNumber = (String) session.getAttribute("empPhone");
        System.out.println("Phone number to use for OTP: " + phoneNumber);

        try {
            // Generate OTP
            String otp = OTPUtil.generateOTP();

            // Store OTP
            OTPUtil.storeOTP(phoneNumber, otp);

            // Send OTP via SMS
            System.out.println("Attempting to send OTP to: " + phoneNumber + " for " + userType + ": " + userName);
            boolean smsSent = SMSUtil.sendOTP(phoneNumber, otp);

            if (smsSent) {
                // Save data for verification
                session.setAttribute("otpMobile", phoneNumber);
                session.setAttribute("userType", userType);
                session.setAttribute("generatedOTP", otp); // For testing, remove in production

                System.out.println("OTP sent successfully to: " + phoneNumber + " | OTP: " + otp + " | User: " + userType);

                // Redirect to OTP verification page
                response.sendRedirect(verifyPageRedirect + "?message=OTP+sent+to+your+mobile+number");
            } else {
                System.out.println("Failed to send OTP to: " + phoneNumber + " for " + userType);
                response.sendRedirect(detailsPageRedirect + "?error=Failed+to+send+OTP");
            }

        } catch (Exception e) {
            System.out.println("Exception in GenerateOTPServlet for " + userType + ": " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(detailsPageRedirect + "?error=Failed+to+generate+OTP");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("EmployeeLogin.jsp");
    }
}