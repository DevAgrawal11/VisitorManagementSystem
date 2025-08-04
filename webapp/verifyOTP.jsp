<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OTP Verification</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: linear-gradient(to right, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }

        .otp-box {
            background-color: #fff;
            padding: 40px;
            border-radius: 10px;
            max-width: 450px;
            width: 90%;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
        }

        h2 {
            color: #333;
            margin-bottom: 20px;
            text-align: center;
        }

        p {
            color: #555;
            font-size: 15px;
        }

        strong {
            color: #111;
        }

        label {
            font-weight: bold;
            display: block;
            margin-bottom: 8px;
            color: #444;
        }

        input[type="text"] {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            border: 2px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
            text-align: center;
            letter-spacing: 2px;
        }

        input[type="text"]:focus {
            outline: none;
            border-color: #667eea;
        }

        .info-box {
            background-color: #f8f9fa;
            padding: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            margin: 15px 0;
            font-size: 14px;
            color: #333;
        }

        .info-box small {
            color: #999;
        }

        button {
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            font-size: 15px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            margin-top: 15px;
        }

        button:hover {
            background-color: #0056b3;
        }

        form {
            margin-bottom: 15px;
        }

        .resend-btn {
            background-color: #28a745;
        }

        .resend-btn:hover {
            background-color: #218838;
        }

        .link-btn {
            display: inline-block;
            margin-top: 10px;
            color: #6c757d;
            text-decoration: none;
            font-size: 14px;
        }

        .link-btn:hover {
            text-decoration: underline;
        }

        .error-msg {
            color: red;
            font-weight: bold;
            margin-top: 15px;
            text-align: center;
        }
        
        .debug-info {
            font-size: 12px;
            color: #666;
            margin-top: 20px;
            border-top: 1px solid #eee;
            padding-top: 10px;
        }
    </style>
</head>
<body>

<%

// Using the implicit session object provided by JSP
if (session == null) {
    response.sendRedirect("EmployeeLogin.jsp?error=Session+expired.+Please+login+again");
    return;
}

String empId = (String) session.getAttribute("empId");
String empName = (String) session.getAttribute("empName");
String empPhone = (String) session.getAttribute("empPhone");
String generatedOTP = (String) session.getAttribute("generatedOTP");
String userRole = (String) session.getAttribute("userRole");

if (empId == null || empPhone == null) {
    response.sendRedirect("EmployeeLogin.jsp?error=Session+expired.+Please+login+again");
    return;
    }

%>

<div class="otp-box">
    <h2>OTP Verification</h2>

    <p>Hello <strong><%= empName %></strong>,</p>
    <p>An OTP has been sent to your mobile number: <strong><%= empPhone %></strong></p>

    <% if (generatedOTP != null) { %>
        <div class="info-box">
            <strong>Demo OTP: <%= generatedOTP %></strong><br>
            <small>⚠️ This is shown only for demo/testing. In production, it should be sent via SMS or Email.</small>
        </div>
    <% } %>

<form action="${pageContext.request.contextPath}/verifyOTP" method="post" autocomplete="off">
    <input type="hidden" name="jsessionid" value="${pageContext.session.id}">
    <label for="otp">Enter OTP:</label>
    <input type="text" id="otp" name="otp" required maxlength="6">
    <button type="submit">Verify OTP</button>
</form>

    <form action="generateOTP" method="post">
        <button type="submit" class="resend-btn">Resend OTP</button>
    </form>

    <a href="EmployeeLogin.jsp" class="link-btn">← Back to Login</a>

    <% if(request.getParameter("error") != null) { %>
        <div class="error-msg"><%= request.getParameter("error") %></div>
    <% } %>
    
</div>

<script>
    
var formSubmitted = false;

function preventDoubleSubmission() {
    if (formSubmitted) {
        alert("Please wait, processing your request...");
        return false;
    }
    formSubmitted = true;
    
    // Disable the submit button
    var submitBtn = document.getElementById("submitBtn");
    if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.value = "Verifying...";
    }
    
    return true;
}

// Re-enable form if there's an error (page reload)
window.onload = function() {
    formSubmitted = false;
    var submitBtn = document.getElementById("submitBtn");
    if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.value = "Verify OTP";
    }
}
    
    const otpInput = document.getElementById('otp');
    otpInput.focus();
    otpInput.addEventListener('input', function () {
        this.value = this.value.replace(/[^0-9]/g, '');
    });
</script>

</body>
</html>