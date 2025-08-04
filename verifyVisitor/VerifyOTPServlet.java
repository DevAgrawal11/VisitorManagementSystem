package com.verifyVisitor;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class VerifyOTPServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("EmployeeLogin.jsp?error=Session+expired.+Please+login+again");
            return;
        }

        // CHECK IF ALREADY AUTHENTICATED (Prevent double submission)
        Boolean isAuthenticated = (Boolean) session.getAttribute("isAuthenticated");
        if (isAuthenticated != null && isAuthenticated) {
            System.out.println("User already authenticated, redirecting...");
            String role = (String) session.getAttribute("userRole");
            if ("employee".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/HostScreen.jsp");
                return;
            } else if ("security".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/SecurityScreen.jsp");
                return;
            }
        }

        String enteredOTP = request.getParameter("otp");
        String mobileNo = (String) session.getAttribute("empPhone");
        String empId = (String) session.getAttribute("empId");
        String role = (String) session.getAttribute("userRole");

        System.out.println("=== OTP Verification Debug ===");
        System.out.println("Entered OTP: " + enteredOTP);
        System.out.println("Mobile from session: " + mobileNo);
        System.out.println("Employee ID: " + empId);
        System.out.println("Role: " + role);
        System.out.println("Session ID: " + session.getId());

        if (enteredOTP == null || enteredOTP.trim().isEmpty()) {
            response.sendRedirect("verifyOTP.jsp?error=Please+enter+OTP");
            return;
        }

        try {
            if (OTPUtil.verifyOTP(mobileNo, enteredOTP.trim())) {
                // Set authentication attributes
                session.setAttribute("isAuthenticated", true);
                session.setAttribute("loginTime", System.currentTimeMillis());

                // Clean up OTP related attributes
                session.removeAttribute("generatedOTP");
                session.removeAttribute("otpMobile");

                System.out.println("OTP verification successful for role: " + role);
                System.out.println("Employee ID: " + empId);
                System.out.println("Mobile: " + mobileNo);

                // Redirect based on user role
                if (role.equals("employee")) {
                	System.out.println("Redirecting to HostScreen.jsp");
                    response.sendRedirect(request.getContextPath() + "/HostScreen.jsp");
                } else if (role.equals("security")) {
                	System.out.println("Redirecting to SecurityScreen.jsp");
                    response.sendRedirect(request.getContextPath() + "/SecurityScreen.jsp");
                } else {
                    response.sendRedirect("EmployeeLogin.jsp?error=Unknown+role");
                }
            }
        }
         catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("verifyOTP.jsp?error=System+error+occurred");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("EmployeeLogin.jsp");
    }
}