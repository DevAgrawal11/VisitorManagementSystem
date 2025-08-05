<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OTP Verification</title>
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #8BC34A 0%, #689F38 30%, #4A6741 70%, #2E4D32 100%);
            margin: 0;
            padding: 0;
            height: 100vh;
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Animated Background Elements */
        .bg-animation {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 1;
        }

        /* Floating Particles */
        .particle {
            position: absolute;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            animation: float 8s ease-in-out infinite;
        }

        .particle:nth-child(odd) {
            animation-direction: reverse;
            animation-duration: 10s;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-30px) rotate(180deg); }
        }

        /* Floating Icons */
        .floating-icon {
            position: absolute;
            font-size: 18px;
            color: rgba(255, 255, 255, 0.12);
            animation: floatIcon 12s ease-in-out infinite;
            pointer-events: none;
        }

        .floating-icon:nth-child(even) {
            animation-direction: reverse;
            animation-duration: 15s;
        }

        @keyframes floatIcon {
            0%, 100% { 
                transform: translateY(0px) rotate(0deg) scale(1); 
                opacity: 0.12;
            }
            25% { 
                transform: translateY(-25px) rotate(90deg) scale(1.1); 
                opacity: 0.2;
            }
            50% { 
                transform: translateY(-15px) rotate(180deg) scale(0.9); 
                opacity: 0.15;
            }
            75% { 
                transform: translateY(-20px) rotate(270deg) scale(1.05); 
                opacity: 0.18;
            }
        }

        /* Geometric Shapes */
        .shape {
            position: absolute;
            opacity: 0.08;
            animation: shapeFloat 20s linear infinite;
        }

        .shape.circle {
            border-radius: 50%;
            background: linear-gradient(45deg, #66BB6A, #4CAF50);
        }

        .shape.square {
            background: linear-gradient(45deg, #81C784, #A5D6A7);
            transform: rotate(45deg);
        }

        @keyframes shapeFloat {
            0% { transform: translateY(100vh) rotate(0deg); }
            100% { transform: translateY(-100px) rotate(360deg); }
        }

        .otp-box {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(15px);
            padding: 30px 35px;
            border-radius: 20px;
            max-width: 420px;
            width: 90%;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.3);
            position: relative;
            z-index: 10;
            animation: slideUp 0.8s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        h2 {
            color: #2E4D32;
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 25px;
            text-align: center;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        p {
            color: #4A6741;
            font-size: 16px;
            margin-bottom: 15px;
            line-height: 1.5;
        }

        strong {
            color: #2E4D32;
            font-weight: 600;
        }

        label {
            font-weight: 600;
            display: block;
            margin-bottom: 10px;
            color: #2E4D32;
            font-size: 15px;
        }

        input[type="text"] {
            width: 100%;
            padding: 15px 18px;
            font-size: 18px;
            border: 2px solid #E8F5E8;
            border-radius: 12px;
            box-sizing: border-box;
            text-align: center;
            letter-spacing: 4px;
            font-weight: 600;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.9);
        }

        input[type="text"]:focus {
            outline: none;
            border-color: #4CAF50;
            box-shadow: 0 0 0 4px rgba(76, 175, 80, 0.1);
            background: #ffffff;
            transform: translateY(-1px);
        }

        .info-box {
            background: linear-gradient(135deg, #E8F5E8 0%, #F1F8E9 100%);
            padding: 18px 20px;
            border: 1px solid rgba(76, 175, 80, 0.2);
            border-radius: 12px;
            margin: 20px 0;
            font-size: 15px;
            color: #2E4D32;
            border-left: 4px solid #4CAF50;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.1);
        }

        .info-box strong {
            font-size: 18px;
            color: #388E3C;
        }

        .info-box small {
            color: #689F38;
            font-size: 13px;
            display: block;
            margin-top: 8px;
        }

        button {
            background: linear-gradient(to right, #4CAF50 0%, #66BB6A 50%, #388E3C 100%);
            color: white;
            padding: 15px 25px;
            font-size: 16px;
            font-weight: 600;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            margin-top: 15px;
            width: 100%;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            box-shadow: 0 8px 20px rgba(76, 175, 80, 0.3);
        }

        button:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 25px rgba(76, 175, 80, 0.4);
            background: linear-gradient(to right, #388E3C 0%, #4CAF50 50%, #66BB6A 100%);
        }

        button:active {
            transform: translateY(-1px);
            box-shadow: 0 6px 15px rgba(76, 175, 80, 0.35);
        }

        form {
            margin-bottom: 15px;
        }

        .resend-btn {
            background: linear-gradient(to right, #66BB6A 0%, #81C784 50%, #4CAF50 100%);
            margin-top: 10px;
        }

        .resend-btn:hover {
            background: linear-gradient(to right, #4CAF50 0%, #66BB6A 50%, #81C784 100%);
        }

        .link-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-top: 15px;
            color: #4CAF50;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            padding: 10px 20px;
            border-radius: 8px;
            transition: all 0.3s ease;
            background: rgba(76, 175, 80, 0.1);
            width: 100%;
        }

        .link-btn:hover {
            background: rgba(76, 175, 80, 0.15);
            color: #388E3C;
            transform: translateY(-1px);
        }

        .error-msg {
            color: #D32F2F;
            background: linear-gradient(135deg, #FFEBEE 0%, #FFCDD2 100%);
            border: 1px solid #FFCDD2;
            padding: 12px 15px;
            border-radius: 8px;
            margin-top: 15px;
            text-align: center;
            font-weight: 500;
            border-left: 4px solid #F44336;
            box-shadow: 0 4px 10px rgba(244, 67, 54, 0.1);
        }
        
        .debug-info {
            font-size: 12px;
            color: #689F38;
            margin-top: 20px;
            border-top: 1px solid rgba(76, 175, 80, 0.2);
            padding-top: 15px;
        }

        @media screen and (max-width: 600px) {
            .otp-box {
                padding: 25px 30px;
                margin: 20px;
            }

            h2 {
                font-size: 24px;
            }

            input[type="text"] {
                font-size: 16px;
                letter-spacing: 3px;
            }

            .info-box {
                padding: 15px;
                font-size: 14px;
            }
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

<!-- Animated Background -->
<div class="bg-animation">
    <!-- Floating Particles -->
    <div class="particle" style="width: 4px; height: 4px; top: 12%; left: 15%; animation-delay: 0s;"></div>
    <div class="particle" style="width: 6px; height: 6px; top: 28%; left: 85%; animation-delay: 1s;"></div>
    <div class="particle" style="width: 5px; height: 5px; top: 45%; left: 10%; animation-delay: 2s;"></div>
    <div class="particle" style="width: 7px; height: 7px; top: 62%; left: 90%; animation-delay: 3s;"></div>
    <div class="particle" style="width: 4px; height: 4px; top: 78%; left: 20%; animation-delay: 4s;"></div>
    <div class="particle" style="width: 6px; height: 6px; top: 35%; left: 75%; animation-delay: 5s;"></div>
    <div class="particle" style="width: 8px; height: 8px; top: 55%; left: 25%; animation-delay: 6s;"></div>
    <div class="particle" style="width: 5px; height: 5px; top: 85%; left: 80%; animation-delay: 7s;"></div>

    <!-- OTP/Verification Related Icons -->
    <div class="floating-icon" style="top: 15%; left: 8%; animation-delay: 0s;">📱</div>
    <div class="floating-icon" style="top: 25%; left: 92%; animation-delay: 1s;">🔢</div>
    <div class="floating-icon" style="top: 35%; left: 5%; animation-delay: 2s;">✅</div>
    <div class="floating-icon" style="top: 45%; left: 88%; animation-delay: 3s;">🔐</div>
    <div class="floating-icon" style="top: 55%; left: 12%; animation-delay: 4s;">📲</div>
    <div class="floating-icon" style="top: 65%; left: 85%; animation-delay: 5s;">🛡️</div>
    <div class="floating-icon" style="top: 75%; left: 10%; animation-delay: 6s;">🔑</div>
    <div class="floating-icon" style="top: 85%; left: 90%; animation-delay: 7s;">⏰</div>
    <div class="floating-icon" style="top: 20%; left: 70%; animation-delay: 8s;">📨</div>
    <div class="floating-icon" style="top: 40%; left: 30%; animation-delay: 9s;">🎯</div>
    <div class="floating-icon" style="top: 60%; left: 65%; animation-delay: 10s;">📋</div>
    <div class="floating-icon" style="top: 80%; left: 35%; animation-delay: 11s;">🔔</div>

    <!-- Geometric Shapes -->
    <div class="shape circle" style="width: 18px; height: 18px; top: 18%; left: 45%; animation-delay: 0s;"></div>
    <div class="shape square" style="width: 16px; height: 16px; top: 32%; left: 20%; animation-delay: 4s;"></div>
    <div class="shape circle" style="width: 22px; height: 22px; top: 52%; left: 60%; animation-delay: 8s;"></div>
    <div class="shape square" style="width: 20px; height: 20px; top: 72%; left: 15%; animation-delay: 12s;"></div>
    <div class="shape circle" style="width: 24px; height: 24px; top: 88%; left: 70%; animation-delay: 16s;"></div>
    <div class="shape square" style="width: 18px; height: 18px; top: 25%; left: 80%; animation-delay: 20s;"></div>
</div>

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
    <input type="text" id="otp" name="otp" required maxlength="6" placeholder="000000">
    <button type="submit" id="submitBtn">Verify OTP</button>
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
        submitBtn.innerHTML = "Verifying...";
    }
    
    return true;
}

// Re-enable form if there's an error (page reload)
window.onload = function() {
    formSubmitted = false;
    var submitBtn = document.getElementById("submitBtn");
    if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.innerHTML = "Verify OTP";
    }
}
    
    const otpInput = document.getElementById('otp');
    otpInput.focus();
    otpInput.addEventListener('input', function () {
        this.value = this.value.replace(/[^0-9]/g, '');
    });

    // Add form submission handler
    document.querySelector('form[action*="verifyOTP"]').addEventListener('submit', function(e) {
        if (!preventDoubleSubmission()) {
            e.preventDefault();
        }
    });

    // Dynamic Background Animation
    function createDynamicParticle() {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.width = Math.random() * 5 + 3 + 'px';
        particle.style.height = particle.style.width;
        particle.style.left = Math.random() * 100 + '%';
        particle.style.top = '100%';
        particle.style.animationDuration = Math.random() * 4 + 8 + 's';
        particle.style.opacity = Math.random() * 0.15 + 0.05;
        
        document.querySelector('.bg-animation').appendChild(particle);
        
        setTimeout(() => {
            particle.remove();
        }, 12000);
    }

    // Create new particles periodically
    setInterval(createDynamicParticle, 4500);
</script>

</body>
</html>
