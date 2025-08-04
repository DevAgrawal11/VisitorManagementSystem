package com.verifyVisitor;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.json.JSONObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// @WebServlet("/RegisterVisitorServlet")
public class RegisterVisitorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:sqlserver://10.80.50.153:1433;databaseName=Instagram_clone;encrypt=true;trustServerCertificate=true";
    private static final String DB_USER = "Intern";
    private static final String DB_PASSWORD = "Intern@2025";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Allow cross-origin if necessary
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");

        System.out.println("=== RegisterVisitorServlet Debug Log ===");

        try {
            // Step 1: Read JSON body
            StringBuilder jsonBuilder = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    jsonBuilder.append(line);
                }
            } catch (IOException ioEx) {
                System.err.println("ERROR: Unable to read request body: " + ioEx.getMessage());
                sendError(response, "Unable to read request body");
                return;
            }

            System.out.println("Received raw JSON: " + jsonBuilder.toString());

            // Step 2: Parse JSON
            JSONObject jsonData = new JSONObject(jsonBuilder.toString());
            String passId = jsonData.optString("passId");
            String name = jsonData.optString("name");
            String mobile = jsonData.optString("mobile").replaceAll("[^0-9]", "");
            String whomToMeet = jsonData.optString("whomToMeet");
            String purpose = jsonData.optString("purpose");
            String visitDateTime = jsonData.optString("visitDateTime");

            String visitDateStr = "";
            String approxTimeStr = "";

            if (visitDateTime != null && visitDateTime.contains("T")) {
                String[] parts = visitDateTime.split("T");
                visitDateStr = parts[0];
                approxTimeStr = parts[1];
            }

            // Step 3: Validate inputs
            if (passId == null || passId.trim().isEmpty()) {
                sendError(response, "Pass ID is required");
                return;
            }
            if (name == null || name.trim().isEmpty()) {
                sendError(response, "Name is required");
                return;
            }
            if (mobile == null || mobile.trim().isEmpty()) {
                sendError(response, "Mobile number is required");
                return;
            }
            if (!mobile.matches("\\d{10,15}")) {
                sendError(response, "Invalid mobile number format");
                return;
            }
            if (whomToMeet == null || whomToMeet.trim().isEmpty()) {
                sendError(response, "Person to meet is required");
                return;
            }
            if (purpose == null || purpose.trim().isEmpty()) {
                sendError(response, "Purpose is required");
                return;
            }
            if (visitDateStr == null || visitDateStr.trim().isEmpty()) {
                sendError(response, "Visit date is required");
                return;
            }

            System.out.println("All validations passed");

            // Step 4: Parse timestamp
            Timestamp approxInTime = null;
            try {
                if (approxTimeStr != null && !approxTimeStr.trim().isEmpty()) {
                    String dateTimeStr = visitDateStr + " " + approxTimeStr;
                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                    Date parsedDate = dateFormat.parse(dateTimeStr);
                    approxInTime = new Timestamp(parsedDate.getTime());
                    System.out.println("Parsed approxInTime: " + approxInTime);
                }
            } catch (ParseException e) {
                sendError(response, "Invalid date/time format. Expected yyyy-MM-dd HH:mm");
                return;
            }

            // Step 5: Check DB connection
            try (Connection testConn = getConnection()) {
                System.out.println("Database connection successful");
            } catch (SQLException e) {
                sendError(response, "Database connection failed: " + e.getMessage());
                return;
            }

         // Step 6: Call stored procedure
            try (Connection conn = getConnection();
                 CallableStatement stmt = conn.prepareCall("{call HostScreen_GuestData(?, ?, ?, ?, ?, ?, ?, ?)}")) {

                stmt.setString(1, passId);
                stmt.setString(2, name);
                stmt.setString(3, mobile);
                stmt.setString(4, whomToMeet);
                stmt.setString(5, purpose);

                if (approxInTime != null) {
                    stmt.setTimestamp(6, approxInTime);
                } else {
                    stmt.setNull(6, Types.TIMESTAMP);
                }

                HttpSession session = request.getSession(false);
                String createdBy = "Unknown";
                if (session != null && session.getAttribute("empName") != null) {
                    createdBy = session.getAttribute("empName").toString();
                }

                stmt.setString(7, createdBy); // createdBy from session
                stmt.setTimestamp(8, new Timestamp(System.currentTimeMillis())); // createdDate from server

                boolean executed = stmt.execute();
                System.out.println("Stored procedure executed: " + executed);

                sendSuccess(response, "Visitor registered successfully", "passId", passId);

            } catch (SQLException e) {
                e.printStackTrace();
                if (e.getMessage().toLowerCase().contains("hostscreen_guestdata")) {
                    sendError(response, "Stored procedure 'HostScreen_GuestData' not found or has issues.");
                } else if (e.getMessage().toLowerCase().contains("duplicate")) {
                    sendError(response, "Pass ID already exists. Please try again.");
                } else {
                    sendError(response, "Database error: " + e.getMessage());
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Unexpected error: " + e.getMessage());
        }

        System.out.println("=== End Debug Log ===");
    }

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("SQL Server JDBC Driver not found", e);
        }
    }

    private void sendSuccess(HttpServletResponse response, String message, String key, String value)
            throws IOException {
        JSONObject json = new JSONObject();
        json.put("status", "success");
        json.put("message", message);
        json.put(key, value);

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    private void sendError(HttpServletResponse response, String errorMessage) throws IOException {
        JSONObject json = new JSONObject();
        json.put("status", "error");
        json.put("message", errorMessage);

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    @Override
    public void init() throws ServletException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("Driver loaded in init()");
        } catch (ClassNotFoundException e) {
            throw new ServletException("SQL Server JDBC Driver not found in init()", e);
        }
    }
}
