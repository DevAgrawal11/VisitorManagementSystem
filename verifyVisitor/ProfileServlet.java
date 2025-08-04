package com.verifyVisitor;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

//@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:sqlserver://10.80.50.153:1433;databaseName=helpdesk;encrypt=true;trustServerCertificate=true";
    private static final String DB_USER = "Intern"; 
    private static final String DB_PASSWORD = "Intern@2025"; 

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if employee is logged in and OTP verified
        HttpSession session = request.getSession();
        String empId = (String) session.getAttribute("empId");
        String otpVerified = (String) session.getAttribute("otpVerified");
        
        if (empId == null || !"true".equals(otpVerified)) {
            response.sendRedirect("EmployeeLogin.jsp?error=Please+login+and+verify+OTP+first");
            return;
        }

        // Forward to profile page
        RequestDispatcher dispatcher = request.getRequestDispatcher("profile.jsp");
        dispatcher.forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if employee is logged in and OTP verified
        HttpSession session = request.getSession();
        String empId = (String) session.getAttribute("empId");
        String otpVerified = (String) session.getAttribute("otpVerified");
        
        if (empId == null || !"true".equals(otpVerified)) {
            response.sendRedirect("EmployeeLogin.jsp?error=Please+login+and+verify+OTP+first");
            return;
        }

        String action = request.getParameter("action");
        
        if ("updateProfile".equals(action)) {
            updateProfile(request, response, session, empId);
        } else if ("changePassword".equals(action)) {
            changePassword(request, response, session, empId);
        } else {
            response.sendRedirect("profile.jsp?error=Invalid+action");
        }
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response, 
                              HttpSession session, String empId) 
            throws ServletException, IOException {
        
        // Get form parameters
        String empName = request.getParameter("empName");
        String empEmail = request.getParameter("empEmail");
        String empPhone = request.getParameter("empPhone");
        String empDepartment = request.getParameter("empDepartment");

        // Validate required fields
        if (empName == null || empName.trim().isEmpty()) {
            response.sendRedirect("profile.jsp?error=Name+is+required");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            // DEMO - Database connection (replace with actual stored procedure)
        	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // DEMO - Update employee profile (replace with stored procedure call)
            String sql = "UPDATE helpdesk_usermaster SET EMP_NAME = ?, EMP_EMAIL = ?, EMP_MOBIL_NO = ?, EMP_DEPT = ? WHERE EMP_ID = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, empName.trim());
            stmt.setString(2, empEmail != null ? empEmail.trim() : null);
            stmt.setString(3, empPhone != null ? empPhone.trim() : null);
            stmt.setString(4, empDepartment != null ? empDepartment.trim() : null);
            stmt.setString(5, empId);

            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                // Update session attributes
                session.setAttribute("empName", empName.trim());
                session.setAttribute("empEmail", empEmail != null ? empEmail.trim() : null);
                session.setAttribute("empPhone", empPhone != null ? empPhone.trim() : null);
                session.setAttribute("empDepartment", empDepartment != null ? empDepartment.trim() : null);
                
                response.sendRedirect("profile.jsp?success=Profile+updated+successfully");
            } else {
                response.sendRedirect("profile.jsp?error=Failed+to+update+profile");
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?error=Database+driver+not+found");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?error=Database+error:+" + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?error=System+error+occurred");
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response, 
                               HttpSession session, String empId) 
            throws ServletException, IOException {
        
        // Get form parameters
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate input
        if (currentPassword == null || currentPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            response.sendRedirect("profile.jsp?error=All+password+fields+are+required");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect("profile.jsp?error=New+passwords+do+not+match");
            return;
        }

        if (newPassword.length() < 6) {
            response.sendRedirect("profile.jsp?error=New+password+must+be+at+least+6+characters");
            return;
        }

        Connection conn = null;
        PreparedStatement verifyStmt = null;
        PreparedStatement updateStmt = null;
        ResultSet rs = null;

        try {
            // DEMO - Database connection (replace with actual stored procedure)
        	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // First, verify current password
            String verifySQL = "SELECT EMP_PASSWORD FROM employee WHERE EMP_ID = ?";
            verifyStmt = conn.prepareStatement(verifySQL);
            verifyStmt.setString(1, empId);
            rs = verifyStmt.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("EMP_PASSWORD");
                
                // In production, use proper password hashing (BCrypt, etc.)
                // For demo purposes, assuming plain text comparison
                if (!currentPassword.equals(storedPassword)) {
                    response.sendRedirect("profile.jsp?error=Current+password+is+incorrect");
                    return;
                }

                // Update password
                String updateSQL = "UPDATE employee SET EMP_PASSWORD = ? WHERE EMP_ID = ?";
                updateStmt = conn.prepareStatement(updateSQL);
                // In production, hash the password before storing
                updateStmt.setString(1, newPassword);
                updateStmt.setString(2, empId);

                int affectedRows = updateStmt.executeUpdate();
                
                if (affectedRows > 0) {
                    response.sendRedirect("profile.jsp?success=Password+changed+successfully");
                } else {
                    response.sendRedirect("profile.jsp?error=Failed+to+change+password");
                }
            } else {
                response.sendRedirect("profile.jsp?error=Employee+not+found");
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?error=Database+driver+not+found");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?error=Database+error:+" + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?error=System+error+occurred");
        } finally {
            try {
                if (rs != null) rs.close();
                if (verifyStmt != null) verifyStmt.close();
                if (updateStmt != null) updateStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}