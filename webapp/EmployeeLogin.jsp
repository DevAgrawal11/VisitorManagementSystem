<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Visitor Verification System</title>
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-container {
            background: #ffffff;
            padding: 40px 30px;
            border-radius: 12px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
            width: 100%;
            max-width: 400px;
            text-align: center;
            animation: fadeIn 0.8s ease-in;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .login-container h2 {
            margin: 0 0 25px 0;
            color: #333333;
            font-size: 28px;
            font-weight: 600;
            letter-spacing: -0.5px;
        }

        .form-group {
            text-align: left;
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 6px;
            color: #444444;
            font-size: 14px;
        }

        .form-group input {
            width: 100%;
            padding: 12px 14px;
            font-size: 15px;
            border: 1.5px solid #cccccc;
            border-radius: 6px;
            transition: all 0.3s ease;
            background-color: #ffffff;
        }

        .form-group input:focus {
            border-color: #2575fc;
            outline: none;
            box-shadow: 0 0 0 3px rgba(37, 117, 252, 0.1);
        }

        .form-group input::placeholder {
            color: #999999;
            font-size: 14px;
        }

        .login-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(to right, #4facfe 0%, #00f2fe 100%);
            border: none;
            border-radius: 6px;
            color: #ffffff;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 6px 15px rgba(0, 132, 255, 0.3);
            transition: all 0.3s ease;
            margin-top: 10px;
        }

        .login-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(0, 132, 255, 0.35);
        }

        .login-btn:active {
            transform: translateY(0);
            box-shadow: 0 4px 10px rgba(0, 132, 255, 0.25);
        }

        .error-msg {
            color: #e74c3c;
            margin-top: 15px;
            font-size: 14px;
            padding: 10px;
            background-color: #fdf2f2;
            border: 1px solid #f5c6cb;
            border-radius: 6px;
            text-align: left;
        }

        /* Responsive Design */
        @media (max-width: 480px) {
            .login-container {
                margin: 20px;
                padding: 30px 20px;
            }

            .login-container h2 {
                font-size: 24px;
            }
        }
    </style>
</head>

<body>
    <div class="login-container">
        <h2>Login</h2>
        
        <form id="loginForm" method="post">
            <div class="form-group">
                <label for="empId">Employee ID / Security Mobile No:</label>
                <input 
                    type="text" 
                    id="empId" 
                    name="empId" 
                    required 
                    placeholder="Enter ID or Mobile Number"
                    autocomplete="username"
                >
            </div>
            
            <button type="submit" class="login-btn">
                Verify
            </button>
        </form>

        <% if (request.getParameter("error") != null) { %>
            <div class="error-msg">
                <%= request.getParameter("error") %>
            </div>
        <% } %>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const empId = document.getElementById('empId').value.trim();
            const form = document.getElementById('loginForm');
            
            // Validate input is not empty
            if (!empId) {
                alert('Please enter Employee ID or Mobile Number');
                return;
            }
            
            // Check if input is a mobile number (contains only digits and is 10 digits long)
            if (/^\d{10}$/.test(empId)) {
                // It's a mobile number - redirect to security validation
                form.action = 'ValidateSecurity';
            } else {
                // It's an employee ID - redirect to employee validation
                form.action = 'ValidateEmployee';
            }
            
            form.submit();
        });

        // Add some basic input formatting
        document.getElementById('empId').addEventListener('input', function(e) {
            // Remove any non-alphanumeric characters for cleaner input
            const value = e.target.value;
            // Allow alphanumeric characters for employee IDs and numbers for mobile
            e.target.value = value.replace(/[^a-zA-Z0-9]/g, '');
        });
    </script>
</body>
</html>