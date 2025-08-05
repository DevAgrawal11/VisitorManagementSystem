<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Security Details Verification</title>
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
            font-size: 20px;
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

        .container {
            width: 90%;
            max-width: 550px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(15px);
            border-radius: 20px;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 25px 30px;
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
            margin-bottom: 10px;
            text-align: center;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        h3 {
            color: #4A6741;
            font-size: 16px;
            font-weight: 500;
            margin-bottom: 25px;
            text-align: center;
            opacity: 0.9;
        }

        .details-card {
            background: rgba(76, 175, 80, 0.05);
            border-radius: 10px;
            padding: 15px 20px;
            margin-bottom: 20px;
            border: 1px solid rgba(76, 175, 80, 0.15);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 0;
        }

        table td {
            border: none;
            padding: 10px 8px;
            font-size: 15px;
            color: #2E4D32;
            border-bottom: 1px solid rgba(76, 175, 80, 0.1);
        }

        table td:last-child {
            border-bottom: none;
        }

        table td:first-child {
            font-weight: 600;
            color: #4A6741;
            width: 40%;
            position: relative;
            padding-left: 15px;
        }

        table td:first-child::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 3px;
            height: 15px;
            background: #4CAF50;
            border-radius: 2px;
        }

        .otp-info {
            text-align: center;
            margin: 20px 0 15px;
            color: #4A6741;
            font-size: 15px;
            background: rgba(76, 175, 80, 0.1);
            padding: 12px 15px;
            border-radius: 8px;
            border-left: 4px solid #4CAF50;
        }

        .otp-info strong {
            color: #2E4D32;
            font-weight: 600;
        }

        button {
            display: block;
            width: 100%;
            background: linear-gradient(to right, #4CAF50 0%, #66BB6A 50%, #388E3C 100%);
            color: white;
            padding: 15px;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
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

        .back-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            margin-top: 15px;
            color: #4CAF50;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            padding: 8px 15px;
            border-radius: 8px;
            transition: all 0.3s ease;
            background: rgba(76, 175, 80, 0.1);
            width: 100%;
        }

        .back-link:hover {
            background: rgba(76, 175, 80, 0.15);
            color: #388E3C;
            transform: translateY(-1px);
        }

        .error-message {
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

        .success-message {
            color: #2E7D32;
            background: linear-gradient(135deg, #E8F5E8 0%, #C8E6C9 100%);
            border: 1px solid #A5D6A7;
            padding: 12px 15px;
            border-radius: 8px;
            margin-top: 15px;
            text-align: center;
            font-weight: 500;
            border-left: 4px solid #4CAF50;
            box-shadow: 0 4px 10px rgba(76, 175, 80, 0.1);
        }

        @media screen and (max-width: 600px) {
            .container {
                width: 95%;
                padding: 20px 25px;
            }

            table td {
                font-size: 14px;
                padding: 8px 6px;
            }

            h2 {
                font-size: 24px;
            }

            h3 {
                font-size: 15px;
            }

            .otp-info {
                font-size: 14px;
                padding: 10px 12px;
            }
        }
    </style>
</head>
<body>

<%
	response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
	response.setHeader("Pragma", "no-cache"); // HTTP 1.0
	response.setDateHeader("Expires", 0); // Proxies

    String name = (String) session.getAttribute("securityName");
    String mobile = (String) session.getAttribute("securityPhone");
    String location = (String) session.getAttribute("securityLocation");
    String userRole = (String) session.getAttribute("userRole");

    if (name == null || mobile == null || location == null) {
        response.sendRedirect("EmployeeLogin.jsp?error=Session+expired+or+invalid+access");
        return;
    }
%>

<!-- Animated Background -->
<div class="bg-animation">
    <!-- Floating Particles -->
    <div class="particle" style="width: 4px; height: 4px; top: 8%; left: 18%; animation-delay: 0s;"></div>
    <div class="particle" style="width: 6px; height: 6px; top: 22%; left: 82%; animation-delay: 1s;"></div>
    <div class="particle" style="width: 5px; height: 5px; top: 38%; left: 15%; animation-delay: 2s;"></div>
    <div class="particle" style="width: 7px; height: 7px; top: 52%; left: 88%; animation-delay: 3s;"></div>
    <div class="particle" style="width: 4px; height: 4px; top: 68%; left: 8%; animation-delay: 4s;"></div>
    <div class="particle" style="width: 6px; height: 6px; top: 82%; left: 78%; animation-delay: 5s;"></div>
    <div class="particle" style="width: 5px; height: 5px; top: 92%; left: 25%; animation-delay: 6s;"></div>
    <div class="particle" style="width: 8px; height: 8px; top: 18%; left: 65%; animation-delay: 7s;"></div>
    <div class="particle" style="width: 4px; height: 4px; top: 42%; left: 35%; animation-delay: 8s;"></div>
    <div class="particle" style="width: 6px; height: 6px; top: 62%; left: 72%; animation-delay: 9s;"></div>
    <div class="particle" style="width: 7px; height: 7px; top: 28%; left: 45%; animation-delay: 10s;"></div>
    <div class="particle" style="width: 5px; height: 5px; top: 78%; left: 38%; animation-delay: 11s;"></div>

    <!-- Security Related Icons -->
    <div class="floating-icon" style="top: 15%; left: 8%; animation-delay: 0s;">🛡️</div>
    <div class="floating-icon" style="top: 25%; left: 92%; animation-delay: 1s;">📱</div>
    <div class="floating-icon" style="top: 35%; left: 5%; animation-delay: 2s;">🔐</div>
    <div class="floating-icon" style="top: 45%; left: 88%; animation-delay: 3s;">👮</div>
    <div class="floating-icon" style="top: 55%; left: 12%; animation-delay: 4s;">📋</div>
    <div class="floating-icon" style="top: 65%; left: 85%; animation-delay: 5s;">🏢</div>
    <div class="floating-icon" style="top: 75%; left: 10%; animation-delay: 6s;">🚨</div>
    <div class="floating-icon" style="top: 85%; left: 90%; animation-delay: 7s;">⏰</div>
    <div class="floating-icon" style="top: 20%; left: 75%; animation-delay: 8s;">🚪</div>
    <div class="floating-icon" style="top: 40%; left: 25%; animation-delay: 9s;">👁️</div>
    <div class="floating-icon" style="top: 60%; left: 70%; animation-delay: 10s;">🎫</div>
    <div class="floating-icon" style="top: 80%; left: 30%; animation-delay: 11s;">📍</div>
    <div class="floating-icon" style="top: 10%; left: 50%; animation-delay: 12s;">✅</div>
    <div class="floating-icon" style="top: 30%; left: 60%; animation-delay: 13s;">🔔</div>
    <div class="floating-icon" style="top: 70%; left: 45%; animation-delay: 14s;">🔑</div>

    <!-- Geometric Shapes -->
    <div class="shape circle" style="width: 20px; height: 20px; top: 12%; left: 40%; animation-delay: 0s;"></div>
    <div class="shape square" style="width: 18px; height: 18px; top: 28%; left: 15%; animation-delay: 3s;"></div>
    <div class="shape circle" style="width: 25px; height: 25px; top: 48%; left: 65%; animation-delay: 6s;"></div>
    <div class="shape square" style="width: 22px; height: 22px; top: 68%; left: 20%; animation-delay: 9s;"></div>
    <div class="shape circle" style="width: 16px; height: 16px; top: 88%; left: 75%; animation-delay: 12s;"></div>
    <div class="shape square" style="width: 20px; height: 20px; top: 18%; left: 80%; animation-delay: 15s;"></div>
    <div class="shape circle" style="width: 24px; height: 24px; top: 58%; left: 35%; animation-delay: 18s;"></div>
    <div class="shape square" style="width: 17px; height: 17px; top: 78%; left: 55%; animation-delay: 21s;"></div>
</div>

<div class="container">
    <h2>Security Personnel Details Verification</h2>
    <h3>Please verify your details before continuing</h3>

    <div class="details-card">
        <table>
            <tr>
                <td>Name</td>
                <td><%= name %></td>
            </tr>
            <tr>
                <td>Mobile Number</td>
                <td><%= mobile %></td>
            </tr>
            <tr>
                <td>Location</td>
                <td><%= location %></td>
            </tr>
            <tr>
                <td>Role</td>
                <td><%= userRole != null ? userRole : "Security" %></td>
            </tr>
        </table>
    </div>

    <div class="otp-info">
        An OTP will be sent to your registered mobile number: <strong><%= mobile %></strong>
    </div>

    <form action="GenerateOTPServlet" method="post">
        <input type="hidden" name="mobileNo" value="<%= mobile %>" />
        <input type="hidden" name="name" value="<%= name %>" />
        <input type="hidden" name="userType" value="security" />
        <button type="submit">Generate OTP</button>
    </form>

    <a class="back-link" href="EmployeeLogin.jsp">← Back to Login</a>

    <% if (request.getParameter("error") != null) { %>
        <div class="error-message">
            <%= request.getParameter("error") %>
        </div>
    <% } %>

    <% if (request.getParameter("message") != null) { %>
        <div class="success-message">
            <%= request.getParameter("message") %>
        </div>
    <% } %>
</div>

<script>
    // Dynamic Background Animation
    function createDynamicParticle() {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.width = Math.random() * 6 + 3 + 'px';
        particle.style.height = particle.style.width;
        particle.style.left = Math.random() * 100 + '%';
        particle.style.top = '100%';
        particle.style.animationDuration = Math.random() * 5 + 8 + 's';
        particle.style.opacity = Math.random() * 0.2 + 0.05;
        
        document.querySelector('.bg-animation').appendChild(particle);
        
        setTimeout(() => {
            particle.remove();
        }, 13000);
    }

    // Create new particles periodically
    setInterval(createDynamicParticle, 4000);
</script>

</body>
</html>
