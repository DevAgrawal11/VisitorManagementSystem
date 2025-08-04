package com.verifyVisitor;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.TimeZone;

import org.json.JSONArray;
import org.json.JSONObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//@WebServlet("/VisitorDashboardServlet")
public class VisitorDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:sqlserver://10.80.50.153:1433;databaseName=Instagram_clone;encrypt=true;trustServerCertificate=true";
    private static final String DB_USER = "Intern";
    private static final String DB_PASSWORD = "Intern@2025";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("dashboard".equals(action)) {
            getVisitorDashboard(request, response);
        } else if ("details".equals(action)) {
            getVisitorDetails(request, response);
        } else {
            sendError(response, "Invalid action specified");
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("update".equals(action)) {
            String updateAction = request.getParameter("updateAction");
            if ("markDone".equals(updateAction)) {
                markVisitComplete(request, response);
            } else {
                sendError(response, "Invalid update action");
            }
        } else {
            sendError(response, "Invalid action specified");
        }
    }

    private void getVisitorDashboard(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        if (fromDate == null || toDate == null) {
            sendError(response, "Missing date parameters");
            return;
        }
        
        String createdBy = (String) request.getSession().getAttribute("empName");
        if (createdBy == null) {
            sendError(response, "Session expired. Please login again.");
            return;
        }

        try (Connection conn = getConnection();
             CallableStatement cstmt = conn.prepareCall("{call GetVisitorsByDateRange(?, ?, ?)}")) {

            cstmt.setString(1, fromDate);
            cstmt.setString(2, toDate);
            cstmt.setString(3, createdBy);
            
            System.out.println("Executing GetVisitorsByDateRange with: " + fromDate + ", " + toDate + ", " + createdBy);
            
            ResultSet rs = cstmt.executeQuery();

            JSONArray visitors = new JSONArray();
            int recordCount = 0;
            
            while (rs.next()) {
                recordCount++;
                JSONObject visitor = new JSONObject();
                visitor.put("passId", rs.getString("Guest_PassID"));
                visitor.put("name", rs.getString("Guest_Name"));
                visitor.put("mobile", rs.getString("Guest_MobNo"));
                visitor.put("whomToMeet", rs.getString("Guest_WhomToMeet"));
                visitor.put("purpose", rs.getString("Guest_MeetPurpose"));
                visitor.put("approxTime", rs.getString("Guest_ApproxInTime"));
                
                // Enhanced date formatting for consistent display
                Timestamp visitDate = rs.getTimestamp("TrDate");
                if (visitDate != null) {
                    visitor.put("visitDate", formatDateForJSON(visitDate));
                } else {
                    visitor.put("visitDate", "");
                }
                
                String rawStatus = rs.getString("Status");
                String normalizedStatus = normalizeStatus(rawStatus);
                visitor.put("status", normalizedStatus);
                
                // Enhanced time formatting
                visitor.put("inTime", formatTimeForJSON(rs.getTimestamp("In_Time")));
                
                // For out time, check if the status is "Ready for Checkout" or "Checked Out"
                Timestamp outTime = rs.getTimestamp("Out_Time");
                if (outTime != null) {
                    visitor.put("outTime", formatTimeForJSON(outTime));
                } else {
                    // If status is "Ready for Checkout", it means host marked complete but no actual checkout yet
                    if ("Ready for Checkout".equals(normalizedStatus)) {
                        visitor.put("outTime", "Pending Checkout");
                    } else {
                        visitor.put("outTime", "N/A");
                    }
                }
                
                visitors.put(visitor);
            }
            
            System.out.println("Found " + recordCount + " visitors for date range " + fromDate + " to " + toDate);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(visitors.toString());

        } catch (SQLException e) {
            System.err.println("Database error in getVisitorDashboard: " + e.getMessage());
            e.printStackTrace();
            sendError(response, "Database error: " + e.getMessage());
        }
    }

    private String formatTimeForJSON(Timestamp timestamp) {
        if (timestamp == null) return "N/A";
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
            sdf.setTimeZone(TimeZone.getDefault());
            return sdf.format(timestamp);
        } catch (Exception e) {
            System.err.println("Error formatting time: " + e.getMessage());
            return "N/A";
        }
    }
    
    private String formatDateForJSON(Timestamp timestamp) {
        if (timestamp == null) return "";
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            return sdf.format(timestamp);
        } catch (Exception e) {
            System.err.println("Error formatting date: " + e.getMessage());
            return "";
        }
    }
    
    private void getVisitorDetails(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String passId = request.getParameter("passId");

        if (passId == null) {
            sendError(response, "Missing passId parameter");
            return;
        }

        try (Connection conn = getConnection();
             CallableStatement cstmt = conn.prepareCall("{call GetVisitorDetails(?)}")) {

            cstmt.setString(1, passId);
            ResultSet rs = cstmt.executeQuery();

            if (rs.next()) {
                JSONObject visitor = new JSONObject();
                visitor.put("passId", rs.getString("Guest_PassID"));
                visitor.put("name", rs.getString("Guest_Name"));
                visitor.put("mobile", rs.getString("Guest_MobNo"));
                visitor.put("whomToMeet", rs.getString("Guest_WhomToMeet"));
                visitor.put("purpose", rs.getString("Guest_MeetPurpose"));
                visitor.put("approxTime", rs.getString("Guest_ApproxInTime"));
                
                Timestamp trDate = rs.getTimestamp("TrDate");
                if (trDate != null) {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");  // Changed to dd-MM-yyyy format
                    visitor.put("visitDate", sdf.format(trDate));
                } else {
                    visitor.put("visitDate", "");
                }
                
                String rawStatus = rs.getString("Status");
                String normalizedStatus = normalizeStatus(rawStatus);
                visitor.put("status", normalizedStatus);

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(visitor.toString());
            } else {
                sendError(response, "Visitor not found");
            }

        } catch (SQLException e) {
            System.err.println("Database error in getVisitorDetails: " + e.getMessage());
            e.printStackTrace();
            sendError(response, "Database error: " + e.getMessage());
        }
    }
    
    private String normalizeStatus(String status) {
        if (status == null) return "Generated";

        String normalized = status.toLowerCase().trim();
        switch (normalized) {
            case "0":
            case "checked out":
            case "completed":
            case "exit":
            case "exited":
                return "Checked Out";
            case "1":
            case "inside":
            case "checked in":
            case "entry":
            case "entered":
                return "Inside";
            case "2":
            case "generated":
            case "pending":
            case "created":
                return "Generated";
            case "3":
            case "host completed":
            case "done by host":
            case "ready for checkout":
                return "Ready for Checkout";
            default:
                return "Generated";
        }
    }

    private void markVisitComplete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String passId = request.getParameter("passId");
        
        if (passId == null) {
            sendError(response, "Missing passId parameter");
            return;
        }
        
        try (Connection conn = getConnection();
             CallableStatement cstmt = conn.prepareCall("{call MarkVisitComplete(?)}")) {
            
            cstmt.setString(1, passId);
            
            // Execute the stored procedure
            boolean hasResultSet = cstmt.execute();
            
            // Check if there were any errors by looking at result or update count
            if (!hasResultSet) {
                int updateCount = cstmt.getUpdateCount();
                System.out.println("MarkVisitComplete executed, update count: " + updateCount);
            }
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            JSONObject result = new JSONObject();
            result.put("status", "success");
            result.put("message", "Visit marked as complete successfully. Visitor is now ready for checkout.");
            response.getWriter().write(result.toString());
            
        } catch (SQLException e) {
            System.err.println("Database error in markVisitComplete: " + e.getMessage());
            e.printStackTrace();
            
            // Provide more specific error messages
            String errorMessage = "Database error: ";
            if (e.getMessage().contains("MarkVisitComplete")) {
                errorMessage += "Stored procedure 'MarkVisitComplete' not found or has issues.";
            } else if (e.getMessage().contains("not found")) {
                errorMessage += "Visitor not found with Pass ID: " + passId;
            } else {
                errorMessage += e.getMessage();
            }
            
            sendError(response, errorMessage);
        }
    }

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("Database connection established successfully");
            return conn;
        } catch (ClassNotFoundException e) {
            System.err.println("JDBC Driver not found: " + e.getMessage());
            throw new SQLException("JDBC Driver not found", e);
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            throw e;
        }
    }

    private void sendError(HttpServletResponse response, String errorMessage) throws IOException {
        JSONObject json = new JSONObject();
        json.put("status", "error");
        json.put("message", errorMessage);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    @Override
    public void init() throws ServletException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("SQL Server JDBC Driver loaded successfully in init()");
        } catch (ClassNotFoundException e) {
            System.err.println("JDBC Driver not found in init(): " + e.getMessage());
            throw new ServletException("JDBC Driver not found", e);
        }
    }
}