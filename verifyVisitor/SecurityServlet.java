package com.verifyVisitor;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;

import org.json.JSONArray;
import org.json.JSONObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class SecurityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Database configuration
    private static final String DB_URL = "jdbc:sqlserver://10.80.50.153:1433;databaseName=Instagram_clone;encrypt=true;trustServerCertificate=true";
    private static final String DB_USER = "Intern";
    private static final String DB_PASSWORD = "Intern@2025";

    @Override
    public void init() throws ServletException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("SecurityServlet initialized successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("Required class not found: " + e.getMessage());
            throw new ServletException("Required class not found", e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Enable CORS
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        
        try {
            String action = request.getParameter("action");
            
            if (action == null || action.isEmpty()) {
                sendError(response, "Action parameter is required", HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            
            switch (action) {
                case "todaysVisitors":
                    getTodaysVisitors(request, response);
                    break;
                case "visitorDetails":
                    getVisitorDetails(request, response);
                    break;
                case "statistics":
                    getStatistics(request, response);
                    break;
                case "test":
                    // Added test endpoint for debugging
                    handleConnectionTest(request, response);
                    break;
                case "fetchTodaysVisitors":
                    fetchTodaysVisitors(request, response);
                    break;
                default:
                    sendError(response, "Invalid action specified", HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            System.err.println("Error in doGet: " + e.getMessage());
            e.printStackTrace();
            sendError(response, "Server error: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Enable CORS
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        
        try {
            System.out.println("Received POST request with parameters:");
            Enumeration<String> params = request.getParameterNames();
            while(params.hasMoreElements()) {
                String paramName = params.nextElement();
                System.out.println(paramName + ": " + request.getParameter(paramName));
            }
            
            // Check content type
            String contentType = request.getContentType();
            System.out.println("Content-Type: " + contentType);

            if ("application/json".equalsIgnoreCase(contentType)) {
                handleJsonRequest(request, response);
            } else {
                request.setCharacterEncoding("UTF-8");

                String action = request.getParameter("action");
                System.out.println("Action received: " + action);

                if (action == null || action.isEmpty()) {
                    sendError(response, "Action parameter is required", HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
                
                switch (action) {
                    case "processEntry":
                        processVisitorEntry(request, response);
                        break;
                    case "processExit":
                        processVisitorExit(request, response);
                        break;
                    case "manualEntry":
                        processManualEntry(request, response);
                        break;
                    case "processFinalCheckout":
                    	processFinalCheckout(request, response);
                        break;
                    case "checkout":
                        handleCheckout(request, response);
                        break;
                    default:
                        sendError(response, "Invalid action specified", HttpServletResponse.SC_BAD_REQUEST);
                }
            }
        } catch (Exception e) {
            System.err.println("Error in doPost: " + e.getMessage());
            e.printStackTrace();
            sendError(response, "Server error: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // Added test connection handler
    private void handleConnectionTest(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        JSONObject testResult = new JSONObject();
        testResult.put("status", "success");
        testResult.put("message", "Connection test successful");
        testResult.put("timestamp", new Date().toString());
        sendSuccessResponse(response, testResult);
    }

    private void handleJsonRequest(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        StringBuilder jsonBuffer = new StringBuilder();
        String line;
        
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
        }
        
        String jsonString = jsonBuffer.toString();
        System.out.println("Received JSON: " + jsonString);
        
        if (jsonString.isEmpty()) {
            sendError(response, "Empty JSON data received", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            JSONObject jsonData = new JSONObject(jsonString);
            String action = jsonData.optString("action");
            
            if ("manualEntry".equals(action)) {
                processManualEntryJson(jsonData, response);
            } else {
                sendError(response, "Invalid action in JSON request", HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            System.err.println("JSON parsing error: " + e.getMessage());
            sendError(response, "Invalid JSON format: " + e.getMessage(), HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void getTodaysVisitors(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        System.out.println("=== DEBUG: getTodaysVisitors method called ===");
        
        try (Connection conn = getConnection();
             CallableStatement cstmt = conn.prepareCall("{call GetTodaysVisitors()}")) {
            
            System.out.println("Database connection established successfully");
            System.out.println("Calling SP GetTodaysVisitors");
            
            ResultSet rs = cstmt.executeQuery();
            System.out.println("Query executed successfully");
            
            JSONArray visitorsArray = new JSONArray();
            int recordCount = 0;
            
            while (rs.next()) {
                recordCount++;
                System.out.println("Processing record #" + recordCount);
                
                JSONObject visitor = new JSONObject();
                visitor.put("passId", rs.getString("Guest_PassID"));
                visitor.put("name", rs.getString("Guest_Name"));
                visitor.put("mobile", rs.getString("Guest_MobNo"));
                visitor.put("whom", rs.getString("Guest_WhomToMeet"));
                visitor.put("purpose", rs.getString("Guest_MeetPurpose"));
                visitor.put("vehicleType", rs.getString("Vehicle_Type") != null ? rs.getString("Vehicle_Type") : "N/A");
                visitor.put("vehicleNumber", rs.getString("Vehicle_Number") != null ? rs.getString("Vehicle_Number") : "N/A");
                
                // Enhanced status handling using the same method as getVisitorDetails
                String rawStatus = rs.getString("Status");
                System.out.println("Raw status for record " + recordCount + ": " + rawStatus);
                String normalizedStatus = normalizeStatus(rawStatus);
                visitor.put("status", normalizedStatus);
                
                // Time formatting
                visitor.put("inTime", formatTime(rs.getTimestamp("In_Time")));
                
               // Only show out time if visitor has actually checked out
                Timestamp outTime = rs.getTimestamp("Out_Time");
                if ("Checked Out".equals(normalizedStatus) && outTime != null) {
                    visitor.put("outTime", formatTime(outTime));
                } else {
                    visitor.put("outTime", "N/A");
                }
                
                visitor.put("visitDate", rs.getString("Visit_Date"));
                
                visitor.put("hostName", "N/A");
                
                visitorsArray.put(visitor);
                System.out.println("Record " + recordCount + " added to array");
            }
            
            System.out.println("Total records processed: " + recordCount);
            System.out.println("Final JSON Array: " + visitorsArray.toString());
            
            // Set response headers
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            // Send the array directly (not wrapped in another object)
            String jsonResponse = visitorsArray.toString();
            System.out.println("Sending JSON response: " + jsonResponse);
            
            response.getWriter().write(jsonResponse);
            response.getWriter().flush();
            
            System.out.println("Response sent successfully. Total visitors: " + recordCount);
            
        } catch (SQLException e) {
            System.err.println("Database error in getTodaysVisitors: " + e.getMessage());
            e.printStackTrace();
            
            // Make sure we send a proper JSON error response
            try {
                JSONObject errorResponse = new JSONObject();
                errorResponse.put("status", "error");
                errorResponse.put("message", "Database error: " + e.getMessage());
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                
                response.getWriter().write(errorResponse.toString());
                response.getWriter().flush();
            } catch (Exception ex) {
                System.err.println("Failed to send error response: " + ex.getMessage());
            }
        } catch (Exception e) {
            System.err.println("Unexpected error in getTodaysVisitors: " + e.getMessage());
            e.printStackTrace();
            
            // Send generic error response
            try {
                JSONObject errorResponse = new JSONObject();
                errorResponse.put("status", "error");
                errorResponse.put("message", "Unexpected error: " + e.getMessage());
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                
                response.getWriter().write(errorResponse.toString());
                response.getWriter().flush();
            } catch (Exception ex) {
                System.err.println("Failed to send error response: " + ex.getMessage());
            }
        }
    }

    private void getVisitorDetails(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
    	String passId = request.getParameter("passId");
    	System.out.println("Requested Pass ID: " + passId);

    	try (Connection conn = getConnection();
    	     CallableStatement stmt = conn.prepareCall("{call GetVisitorDetails(?)}")) {

    	    stmt.setString(1, passId);
    	    ResultSet rs = stmt.executeQuery();

    	    if (rs.next()) {
    	        System.out.println("✅ Visitor found in SP. Preparing JSON...");

    	        JSONObject visitor = new JSONObject();
    	        visitor.put("passId", rs.getString("passId")); // <- column name must match alias from SP
    	        visitor.put("name", rs.getString("name"));
    	        visitor.put("mobile", rs.getString("mobile"));
    	        visitor.put("whom", rs.getString("whom"));
    	        visitor.put("purpose", rs.getString("purpose"));
    	        visitor.put("status", rs.getString("status"));
    	        visitor.put("inTime", rs.getString("inTime"));
    	        visitor.put("outTime", rs.getString("outTime"));
    	        visitor.put("visitDate", formatDate(rs.getDate("visitDate")));
    	        visitor.put("vehicleNumber", rs.getString("vehicleNumber"));
    	        visitor.put("vehicleType", rs.getString("vehicleType"));
    	        visitor.put("hostName", rs.getString("hostName"));

    	        JSONObject responseJson = new JSONObject();
    	        responseJson.put("status", "success");
    	        responseJson.put("visitor", visitor);

    	        System.out.println("✅ Sending JSON: " + responseJson.toString());

    	        response.setContentType("application/json");
    	        response.setCharacterEncoding("UTF-8");
    	        response.getWriter().write(responseJson.toString());

    	    } else {
    	        System.out.println("❌ Visitor not found in DB");
    	        response.getWriter().write("{\"status\":\"error\",\"message\":\"Visitor not found\"}");
    	    }

    	} catch (Exception e) {
    	    e.printStackTrace();
    	    response.getWriter().write("{\"status\":\"error\",\"message\":\"Server error occurred\"}");
    	}
    }

 // Updated method to normalize status values for consistent frontend handling
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
            case "ready for checkout":
            case "host completed":
            case "done by host":
                return "Ready for Checkout";
            default:
                return "Generated";
        }
    }

    private void getStatistics(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try (Connection conn = getConnection();
             CallableStatement cstmt = conn.prepareCall("{call GetVisitorStatistics()}")) {
            
            ResultSet rs = cstmt.executeQuery();
            
            if (rs.next()) {
                JSONObject stats = new JSONObject();
                stats.put("pending", rs.getInt("Pending_Count"));           // Status 2
                stats.put("inside", rs.getInt("Inside_Count"));             // Status 1  
                stats.put("readyForCheckout", rs.getInt("ReadyForCheckout_Count")); // Status 3 - FIXED
                stats.put("checkedOut", rs.getInt("CheckedOut_Count"));     // Status 0
                stats.put("total", rs.getInt("Total_Count"));
                
                sendSuccessResponse(response, stats);
            } else {
                // Return default stats if no data
                JSONObject stats = new JSONObject();
                stats.put("pending", 0);
                stats.put("inside", 0);
                stats.put("readyForCheckout", 0); // FIXED
                stats.put("checkedOut", 0);
                stats.put("total", 0);
                sendSuccessResponse(response, stats);
            }
            
        } catch (SQLException e) {
            System.err.println("Database error in getStatistics: " + e.getMessage());
            sendError(response, "Database error: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void processVisitorEntry(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String passId = request.getParameter("passId");
        String vehicleType = request.getParameter("vehicleType");
        String vehicleNumber = request.getParameter("vehicleNumber");
        
        System.out.println("Processing visitor entry - PassID: " + passId + 
                          ", VehicleType: " + vehicleType + ", VehicleNumber: " + vehicleNumber);
        
        if (passId == null || passId.isEmpty()) {
            sendError(response, "Pass ID is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        if (vehicleType == null) vehicleType = "";
        if (vehicleNumber == null) vehicleNumber = "";
        
        // Validate vehicle number if vehicle type requires it
        if (("Personal Vehicle".equals(vehicleType) || "Mahyco Vehicle".equals(vehicleType)) 
            && (vehicleNumber == null || vehicleNumber.trim().isEmpty())) {
            sendError(response, "Vehicle number is required for selected vehicle type", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try (Connection conn = getConnection();
        	     CallableStatement cstmt = conn.prepareCall("{call ProcessVisitorEntry(?, ?, ?)}")) {
        	    
        	    cstmt.setString(1, passId);
        	    cstmt.setString(2, vehicleType);
        	    cstmt.setString(3, vehicleNumber);
        	    
        	    int affectedRows = cstmt.executeUpdate();
        	    System.out.println("Entry processing affected rows: " + affectedRows);
        	    
        	    // Return success regardless of affected rows count
        	    // The operation completed without exception, so treat as success
        	    JSONObject result = new JSONObject();
        	    result.put("status", "success");
        	    result.put("message", "Visitor entry processed successfully");
        	    result.put("passId", passId);
        	    
        	    sendSuccessResponse(response, result);
        	    
        	} catch (SQLException e) {
        	    System.err.println("Database error in processVisitorEntry: " + e.getMessage());
        	    e.printStackTrace();
        	    
        	    JSONObject result = new JSONObject();
        	    result.put("status", "error");
        	    result.put("message", "Database error: " + e.getMessage());
        	    sendSuccessResponse(response, result);
        	}
    }
    private void processVisitorExit(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String passId = request.getParameter("passId");
        
        System.out.println("Processing visitor exit - PassID: " + passId);
        
        if (passId == null || passId.isEmpty()) {
            sendError(response, "Pass ID is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try (Connection conn = getConnection();
        	     CallableStatement cstmt = conn.prepareCall("{call ProcessVisitorExit(?)}")) {
        	    
        	    cstmt.setString(1, passId);
        	    
        	    int affectedRows = cstmt.executeUpdate();
        	    System.out.println("Exit processing affected rows: " + affectedRows);
        	    
        	    // Return success regardless of affected rows count
        	    // The operation completed without exception, so treat as success
        	    JSONObject result = new JSONObject();
        	    result.put("status", "success");
        	    result.put("message", "Visitor exit processed successfully");
        	    result.put("passId", passId);
        	    
        	    sendSuccessResponse(response, result);
        	    
        	} catch (SQLException e) {
        	    System.err.println("Database error in processVisitorExit: " + e.getMessage());
        	    e.printStackTrace();
        	    
        	    JSONObject result = new JSONObject();
        	    result.put("status", "error");
        	    result.put("message", "Database error: " + e.getMessage());
        	    sendSuccessResponse(response, result);
        	}
    }
    
    private void processFinalCheckout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String passId = request.getParameter("passId");
        
        System.out.println("Processing final checkout for PassID: " + passId);
        
        if (passId == null || passId.trim().isEmpty()) {
            sendJsonResponse(response, "error", "Pass ID is required");
            return;
        }
        
        try (Connection conn = getConnection();
             CallableStatement cstmt = conn.prepareCall("{call ProcessFinalCheckout(?)}")) {
            
            cstmt.setString(1, passId);
            ResultSet rs = cstmt.executeQuery();
            
            if (rs.next()) {
                String status = rs.getString("status");
                String message = rs.getString("message");
                
                System.out.println("Final checkout result - Status: " + status + ", Message: " + message);
                
                if ("success".equals(status)) {
                    sendJsonResponse(response, "success", "Final checkout completed successfully");
                } else {
                    sendJsonResponse(response, "error", message);
                }
            } else {
                sendJsonResponse(response, "error", "No response from database");
            }
            
        } catch (SQLException e) {
            System.err.println("Database error in processFinalCheckout: " + e.getMessage());
            e.printStackTrace();
            sendJsonResponse(response, "error", "Database error: " + e.getMessage());
        }
    }

    // HELPER: JSON response method (add this if it doesn't exist)
    private void sendJsonResponse(HttpServletResponse response, String status, String message) throws IOException {
        JSONObject json = new JSONObject();
        json.put("status", status);
        json.put("message", message);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(json.toString());
        response.getWriter().flush();
    }
    
	private void processManualEntry(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String name = request.getParameter("name");
        String mobile = request.getParameter("mobile");
        String whom = request.getParameter("whom");
        String purpose = request.getParameter("purpose");
        String vehicleType = request.getParameter("vehicleType");
        String vehicleNumber = request.getParameter("vehicleNumber");

        processManualEntryCommon(name, mobile, whom, purpose, vehicleType, vehicleNumber, response);
    }

    private void processManualEntryJson(JSONObject jsonData, HttpServletResponse response) 
            throws IOException {
        String name = jsonData.optString("name");
        String mobile = jsonData.optString("mobile");
        String whom = jsonData.optString("whom");
        String purpose = jsonData.optString("purpose");
        String vehicleType = jsonData.optString("vehicleType", "");
        String vehicleNumber = jsonData.optString("vehicleNumber", "");

        processManualEntryCommon(name, mobile, whom, purpose, vehicleType, vehicleNumber, response);
    }

    private void processManualEntryCommon(String name, String mobile, String whom, String purpose, 
                                        String vehicleType, String vehicleNumber, HttpServletResponse response) 
            throws IOException {
        System.out.println("Processing manual entry - Name: " + name + ", Mobile: " + mobile + 
                          ", Whom: " + whom + ", Purpose: " + purpose);
        
        // Enhanced validation
        if (name == null || name.trim().isEmpty() || mobile == null || mobile.trim().isEmpty() || 
            whom == null || whom.trim().isEmpty() || purpose == null || purpose.trim().isEmpty()) {
            
            JSONObject result = new JSONObject();
            result.put("status", "error");
            result.put("message", "All required fields must be filled");
            sendSuccessResponse(response, result);
            return;
        }

        name = name.trim();
        mobile = mobile.trim();
        whom = whom.trim();
        purpose = purpose.trim();

        if (!mobile.matches("^[6-9]\\d{9}$")) {
            JSONObject result = new JSONObject();
            result.put("status", "error");
            result.put("message", "Please enter a valid 10-digit mobile number starting with 6-9");
            sendSuccessResponse(response, result);
            return;
        }

        if (vehicleType == null) vehicleType = "";
        if (vehicleNumber == null) vehicleNumber = "";

        try (Connection conn = getConnection();
             CallableStatement cstmt = conn.prepareCall("{call ProcessManualEntry(?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            
            cstmt.setString(1, name);
            cstmt.setString(2, mobile);
            cstmt.setString(3, whom);
            cstmt.setString(4, purpose);
            cstmt.setString(5, vehicleType);
            cstmt.setString(6, vehicleNumber);
            cstmt.setString(7, "Security");
            cstmt.setTimestamp(8, new Timestamp(System.currentTimeMillis()));
            cstmt.registerOutParameter(9, Types.NVARCHAR);

            cstmt.execute();

            String generatedPassId = cstmt.getString(9);

            JSONObject result = new JSONObject();
            if (generatedPassId != null && !generatedPassId.isEmpty()) {
                result.put("status", "success");
                result.put("message", "Visitor registered successfully");
                result.put("passId", generatedPassId);
            } else {
                result.put("status", "error");
                result.put("message", "Failed to generate pass ID");
            }
            sendSuccessResponse(response, result);

        } catch (SQLException e) {
            System.err.println("Database error in processManualEntry: " + e.getMessage());
            e.printStackTrace();
            
            JSONObject result = new JSONObject();
            result.put("status", "error");
            
            if (e.getErrorCode() == 2627) {
                result.put("message", "Mobile number already exists for today's visit");
            } else {
                result.put("message", "Database error: " + e.getMessage());
            }
            
            sendSuccessResponse(response, result);
        }
    }

    private void fetchTodaysVisitors(HttpServletRequest request, HttpServletResponse response) throws IOException {
        PrintWriter out = response.getWriter();
        response.setContentType("application/json");
        
        try (Connection conn = getConnection(); 
             CallableStatement stmt = conn.prepareCall("{call FetchTodaysVisitors()}")) {
            
            boolean hasResults = stmt.execute();
            JSONArray visitorArray = new JSONArray();

            if (hasResults) {
                try (ResultSet rs = stmt.getResultSet()) {
                    while (rs.next()) {
                        JSONObject visitor = new JSONObject();
                        visitor.put("passId", rs.getString("Guest_PassID"));
                        visitor.put("name", rs.getString("Guest_Name"));
                        visitor.put("mobile", rs.getString("Guest_MobNo"));
                        visitor.put("whom", rs.getString("Guest_WhomToMeet"));
                        visitor.put("purpose", rs.getString("Guest_MeetPurpose"));
                        visitor.put("vehicleType", rs.getString("Vehicle_Type"));
                        visitor.put("vehicleNumber", rs.getString("Vehicle_No"));
                        visitor.put("inTime", rs.getString("Guest_InTime"));
                        visitor.put("outTime", rs.getString("Guest_OutTime"));
                        visitor.put("status", rs.getString("Status"));
                        visitorArray.put(visitor);
                    }
                }
            }

            JSONObject result = new JSONObject();
            result.put("status", "success");
            result.put("visitors", visitorArray);
            out.print(result.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            JSONObject error = new JSONObject();
            error.put("status", "error");
            error.put("message", "Database error: " + e.getMessage());
            out.print(error.toString());
        }
    }
    
    private void handleCheckout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String passId = request.getParameter("passId");

        JSONObject jsonResponse = new JSONObject();

        if (passId == null || passId.trim().isEmpty()) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Pass ID is missing.");
            response.setContentType("application/json");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        try (Connection conn = getConnection();
             CallableStatement stmt = conn.prepareCall("{call HandleCheckout(?)}")) {

            conn.setAutoCommit(true); // Ensure immediate commit
            stmt.setString(1, passId);
            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                jsonResponse.put("status", "success");
                jsonResponse.put("message", "Visitor checked out.");
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Check-out failed. Visitor might already be checked out.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Database error: " + e.getMessage());
        }

        response.setContentType("application/json");
        response.getWriter().write(jsonResponse.toString());
    }

    private Connection getConnection() throws SQLException {
         Connection conn=DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
         conn.setAutoCommit(true); // Ensure every update is committed immediately
         return conn;

    }

    private String getStatusText(int statusFlag) {
        switch (statusFlag) {
            case 0: return "Checked Out";	
            case 1: return "Inside";
            case 2: return "Generated";
            default: return "Unknown";
        }
    }

    private String formatTime(Timestamp timestamp) {
        if (timestamp == null) return "N/A";
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm a");
            return sdf.format(timestamp);
        } catch (Exception e) {
            return "N/A";
        }
    }

    private String formatDate(Date date) {
        if (date == null) return "";
        return new SimpleDateFormat("dd-MM-yyyy").format(date);
    }

    private void sendSuccessResponse(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        response.setStatus(HttpServletResponse.SC_OK);
        
        PrintWriter out = response.getWriter();
        out.print(data.toString());
        out.flush();
    }

    private void sendError(HttpServletResponse response, String errorMessage, int statusCode) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        response.setStatus(statusCode);
        
        JSONObject json = new JSONObject();
        json.put("status", "error");
        json.put("message", errorMessage);
        
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }
}