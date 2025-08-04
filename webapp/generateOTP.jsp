<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
	response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
	response.setHeader("Pragma", "no-cache"); // HTTP 1.0
	response.setDateHeader("Expires", 0); // Proxies
    // Check if employee is logged in
    String empId = (String) session.getAttribute("empId");
    String empEmail = (String) session.getAttribute("empEmail");
    String empName = (String) session.getAttribute("empName");
    String empPhone = (String) session.getAttribute("empPhone");
    
    if(empId == null) {
        response.sendRedirect("EmployeeLogin.jsp?error=Session+expired.+Please+login+again");
        return;
    }
    
    // Generate 6-digit OTP
    Random random = new Random();
    int otp = 100000 + random.nextInt(900000);
    
    // Store OTP in session with timestamp
    session.setAttribute("generatedOTP", String.valueOf(otp));
    session.setAttribute("otpGeneratedTime", System.currentTimeMillis());
    
    // In a real application, you would send this OTP via email/SMS
    // For demo purposes, we'll just display it
    System.out.println("OTP for Employee " + empId + ": " + otp);
    
    // Store OTP in database for additional security
    boolean otpStoredInDB = false;
    try {
        String url = "jdbc:mysql://localhost:3306/test";
        String username = "root";
        String password = "Dev@98230";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, username, password);
        
        // Check if OTP column exists, if not this will help track the issue
        String sql = "UPDATE employee SET OTP = ?, OTP_GENERATED_TIME = NOW() WHERE EMP_ID = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, String.valueOf(otp));
        pstmt.setString(2, empId);
        
        int rowsUpdated = pstmt.executeUpdate();
        if(rowsUpdated > 0) {
            otpStoredInDB = true;
        }
        
        pstmt.close();
        conn.close();
    } catch(Exception e) {
        e.printStackTrace();
        // Continue even if DB update fails, as OTP is stored in session
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OTP Verification</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .otp-container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            width: 450px;
            text-align: center;
        }
        .otp-container h2 {
            color: #333;
            margin-bottom: 20px;
        }
        .employee-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: left;
        }
        .employee-info strong {
            color: #333;
        }
        .otp-info {
            background: #e8f5e8;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 25px;
            border-left: 4px solid #28a745;
        }
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: bold;
        }
        .form-group input {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 18px;
            text-align: center;
            letter-spacing: 3px;
            box-sizing: border-box;
        }
        .form-group input:focus {
            border-color: #667eea;
            outline: none;
        }
        .verify-btn {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
            transition: transform 0.2s;
            margin-bottom: 15px;
        }
        .verify-btn:hover {
            transform: translateY(-2px);
        }
        .back-btn {
            background: #6c757d;
            color: white;
            padding: 8px 20px;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
        .error-msg {
            color: #e74c3c;
            margin-top: 10px;
            font-size: 14px;
        }
        .success-msg {
            color: #28a745;
            margin-top: 10px;
            font-size: 14px;
        }
        .demo-otp {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            color: #856404;
        }
        .demo-otp strong {
            font-size: 20px;
            color: #d63384;
        }
        .timer {
            color: #666;
            font-size: 14px;
            margin-top: 15px;
            font-weight: bold;
        }
        .contact-info {
            background: #e3f2fd;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 14px;
        }
    </style>
    <script>
        // 5-minute timer for OTP validity
        let timeLeft = 300; // 5 minutes in seconds
        
        function updateTimer() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            const timerElement = document.getElementById('timer');
            
            if (timerElement) {
                timerElement.textContent = 
                    `OTP expires in: ${minutes}:${seconds.toString().padStart(2, '0')}`;
                
                if (timeLeft <= 60) {
                    timerElement.style.color = '#e74c3c';
                }
            }
            
            if (timeLeft <= 0) {
                alert('OTP has expired. Please generate a new one.');
                window.location.href = 'EmployeeLogin.jsp?error=OTP+expired.+Please+login+again';
                return;
            }
            timeLeft--;
        }
        
        // Start timer when page loads
        window.onload = function() {
            updateTimer();
            setInterval(updateTimer, 1000);
        };
        
        // Auto-focus on OTP input
        window.addEventListener('load', function() {
            document.getElementById('userOTP').focus();
        });
        
        // Only allow numbers in OTP field
        function validateOTPInput(input) {
            input.value = input.value.replace(/[^0-9]/g, '');
        }
    </script>
</head>
<body>
    <div class="otp-container">
        <h2>OTP Verification</h2>
        
        <div class="employee-info">
            <strong>Employee:</strong> <%= empName %> (ID: <%= empId %>)
        </div>
        
        <div class="otp-info">
            <p><strong>OTP has been generated for verification</strong></p>
            <p>Please enter the 6-digit OTP to proceed to the dashboard.</p>
        </div>
        
        <% if (empEmail != null && !empEmail.trim().isEmpty()) { %>
        <div class="contact-info">
            📧 <strong>Email:</strong> <%= empEmail %>
        </div>
        <% } %>
        
        <% if (empPhone != null && !empPhone.trim().isEmpty()) { %>
        <div class="contact-info">
            📱 <strong>Phone:</strong> <%= empPhone %>
        </div>
        <% } %>
        
        <!-- Demo purposes - showing OTP (remove in production) -->
        <div class="demo-otp">
            <strong>Demo OTP: <%= otp %></strong><br>
            <small>⚠️ This is for demo purposes only. In production, OTP would be sent via email/SMS</small>
        </div>
        
        <% if (otpStoredInDB) { %>
        <div class="success-msg">
            ✅ OTP stored securely in database
        </div>
        <% } %>
        
        <form action="verifyOTP.jsp" method="post">
            <div class="form-group">
                <label for="userOTP">Enter 6-Digit OTP:</label>
                <input type="text" id="userOTP" name="userOTP" maxlength="6" required 
                       placeholder="000000" pattern="[0-9]{6}"
                       oninput="validateOTPInput(this)"
                       autocomplete="one-time-code">
            </div>
            <button type="submit" class="verify-btn">Verify OTP & Continue</button>
        </form>
        
        <a href="viewEmployeeDetails.jsp" class="back-btn">← Back to Details</a>
        
        <div class="timer" id="timer"></div>
        
        <% if(request.getParameter("error") != null) { %>
            <div class="error-msg">
                <%= request.getParameter("error").replace("+", " ") %>
            </div>
        <% } %>
    </div>
</body>
</html>