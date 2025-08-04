<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Security Details Verification</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(to right, #667eea, #764ba2);
            margin: 0;
            padding: 0;
        }

        .container {
            width: 90%;
            max-width: 600px;
            margin: 60px auto;
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
            padding: 30px 35px;
        }

        h2 {
            color: #333;
            font-size: 26px;
            margin-bottom: 10px;
            text-align: center;
        }

        h3 {
            color: #555;
            font-size: 18px;
            margin-bottom: 20px;
            text-align: center;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 0 auto 20px auto;
        }

        table td {
            border-bottom: 1px solid #e0e0e0;
            padding: 12px 10px;
            font-size: 15px;
            color: #333;
        }

        table td:first-child {
            font-weight: bold;
            color: #555;
            width: 40%;
        }

        p {
            text-align: center;
            margin: 25px 0 10px;
            color: #444;
            font-size: 15px;
        }

        strong {
            color: #111;
        }

        button {
            display: block;
            width: 100%;
            background-color: #007bff;
            color: white;
            padding: 14px;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 10px;
            transition: background 0.3s ease;
        }

        button:hover {
            background-color: #0056b3;
        }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #007bff;
            text-decoration: none;
            font-weight: 500;
            font-size: 14px;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .error-message {
            color: #e74c3c;
            background-color: #fcebea;
            border: 1px solid #f5c6cb;
            padding: 12px;
            border-radius: 6px;
            margin-top: 20px;
            text-align: center;
            font-weight: 500;
        }

        .success-message {
            color: #155724;
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            padding: 12px;
            border-radius: 6px;
            margin-top: 20px;
            text-align: center;
            font-weight: 500;
        }

        @media screen and (max-width: 600px) {
            .container {
                padding: 25px 20px;
            }

            table td {
                font-size: 14px;
                padding: 10px 8px;
            }

            h2 {
                font-size: 22px;
            }

            h3 {
                font-size: 16px;
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

<div class="container">
    <h2>Security Personnel Details Verification</h2>
    <h3>Please verify your details before continuing</h3>

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

    <p>An OTP will be sent to your registered mobile number: <strong><%= mobile %></strong></p>

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

</body>
</html>