package com.verifyVisitor;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

//@WebServlet({"/ValidateSecurityServlet", "/ValidateSecurity"}) // Added both mappings
public class ValidateSecurityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:sqlserver://10.80.50.153:1433;databaseName=Instagram_clone;encrypt=true;trustServerCertificate=true";
    private static final String DB_USER = "Intern"; 
    private static final String DB_PASSWORD = "Intern@2025";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String mobileNo = request.getParameter("empId");

        if (mobileNo == null || mobileNo.trim().isEmpty()) {
            response.sendRedirect("EmployeeLogin.jsp?error=Mobile+number+required");
            return;
        }

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            try (
                Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                CallableStatement cstmt = conn.prepareCall("{call GetSecurityData(?)}")
            ) {
                cstmt.setString(1, mobileNo.trim());
                ResultSet rs = cstmt.executeQuery();

                if (rs.next()) {
                    HttpSession session = request.getSession();
                    
                    // Set security attributes
                    session.setAttribute("securityId", rs.getString("Sec_MobNo"));
                    session.setAttribute("securityName", rs.getString("Sec_Name"));
                    session.setAttribute("securityPhone", rs.getString("Sec_MobNo"));
                    session.setAttribute("securityLocation", rs.getString("Sec_Location"));
                    
                    // Set common attributes for OTP verification
                    session.setAttribute("empId", rs.getString("Sec_MobNo")); // For OTP verification
                    session.setAttribute("empName", rs.getString("Sec_Name")); // For OTP verification
                    session.setAttribute("empPhone", rs.getString("Sec_MobNo")); // For OTP verification
                    session.setAttribute("userRole", "security"); // Set role as security
                    
                    System.out.println("Security validation successful for: " + rs.getString("Sec_Name"));
                    response.sendRedirect("viewSecurityDetails.jsp");
                } else {
                    response.sendRedirect("EmployeeLogin.jsp?error=No+security+record+found+for+mobile+number");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("EmployeeLogin.jsp?error=Internal+error+occurred");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("EmployeeLogin.jsp");
    }
}