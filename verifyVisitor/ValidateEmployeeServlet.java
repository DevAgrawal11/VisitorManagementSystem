package com.verifyVisitor;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class ValidateEmployeeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Database configuration
    private static final String DB_URL = "jdbc:sqlserver://10.80.50.153:1433;databaseName=Instagram_clone;encrypt=true;trustServerCertificate=true";
    private static final String DB_USER = "Intern"; 
    private static final String DB_PASSWORD = "Intern@2025";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String empId = request.getParameter("empId");

        if (empId == null || empId.trim().isEmpty()) {
            response.sendRedirect("EmployeeLogin.jsp?error=Employee+ID+is+required");
            return;
        }

        Connection conn = null;
        CallableStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Use stored procedure
            stmt = conn.prepareCall("{ call GetEmployeeDetails(?) }");
            stmt.setString(1, empId.trim());

            rs = stmt.executeQuery();

            if (rs.next()) {
            	
            	System.out.println("=== ValidateEmployeeServlet Debug ===");
                System.out.println("Employee ID: " + empId);
                System.out.println("Name from DB: " + rs.getString("EMP_EMPOWERNAME"));
                System.out.println("Phone from DB: " + rs.getString("ContactNo"));
                
                HttpSession session = request.getSession();
                session.setAttribute("empId", empId.trim());
                session.setAttribute("empName", rs.getString("EMP_EMPOWERNAME"));
                session.setAttribute("empPhone", rs.getString("ContactNo"));
                session.setAttribute("userRole", "employee");

                System.out.println("Employee validated: " + empId);
                System.out.println("Name: " + rs.getString("EMP_EMPOWERNAME"));

                response.sendRedirect("viewEmployeeDetails.jsp");
            } else {
                response.sendRedirect("EmployeeLogin.jsp?error=Invalid+Employee+ID");
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("EmployeeLogin.jsp?error=Driver+not+found");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("EmployeeLogin.jsp?error=Database+error");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("EmployeeLogin.jsp?error=Unexpected+error");
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("EmployeeLogin.jsp");
    }
}
