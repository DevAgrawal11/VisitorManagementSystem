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
            background: linear-gradient(135deg, #8BC34A 0%, #689F38 30%, #4A6741 70%, #2E4D32 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
            position: relative;
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
            animation: float 6s ease-in-out infinite;
        }

        .particle:nth-child(odd) {
            animation-direction: reverse;
            animation-duration: 8s;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(180deg); }
        }

        /* Floating Icons */
        .floating-icon {
            position: absolute;
            font-size: 24px;
            color: rgba(255, 255, 255, 0.15);
            animation: floatIcon 10s ease-in-out infinite;
            pointer-events: none;
        }

        .floating-icon:nth-child(even) {
            animation-direction: reverse;
            animation-duration: 12s;
        }

        @keyframes floatIcon {
            0%, 100% { 
                transform: translateY(0px) rotate(0deg) scale(1); 
                opacity: 0.15;
            }
            25% { 
                transform: translateY(-30px) rotate(90deg) scale(1.1); 
                opacity: 0.25;
            }
            50% { 
                transform: translateY(-15px) rotate(180deg) scale(0.9); 
                opacity: 0.2;
            }
            75% { 
                transform: translateY(-25px) rotate(270deg) scale(1.05); 
                opacity: 0.18;
            }
        }

        /* Geometric Shapes */
        .shape {
            position: absolute;
            opacity: 0.1;
            animation: shapeFloat 15s linear infinite;
        }

        .shape.circle {
            border-radius: 50%;
            background: linear-gradient(45deg, #66BB6A, #4CAF50);
        }

        .shape.square {
            background: linear-gradient(45deg, #81C784, #A5D6A7);
            transform: rotate(45deg);
        }

        .shape.triangle {
            width: 0;
            height: 0;
            border-left: 15px solid transparent;
            border-right: 15px solid transparent;
            border-bottom: 25px solid rgba(255, 255, 255, 0.1);
        }

        @keyframes shapeFloat {
            0% { transform: translateY(100vh) rotate(0deg); }
            100% { transform: translateY(-100px) rotate(360deg); }
        }

        /* Pulsing Rings */
        .ring {
            position: absolute;
            border: 2px solid rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            animation: pulse 4s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { 
                transform: scale(1); 
                opacity: 0.1; 
            }
            50% { 
                transform: scale(1.2); 
                opacity: 0.2; 
            }
        }

        /* Wave Animation */
        .wave {
            position: absolute;
            bottom: -50px;
            left: 0;
            width: 100%;
            height: 100px;
            background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 120' preserveAspectRatio='none'%3E%3Cpath d='M0,0V46.29c47.79,22.2,103.59,32.17,158,28,70.36-5.37,136.33-33.31,206.8-37.5C438.64,32.43,512.34,53.67,583,72.05c69.27,18,138.3,24.88,209.4,13.08,36.15-6,69.85-17.84,104.45-29.34C989.49,25,1113-14.29,1200,52.47V0Z' opacity='.25' fill='%23ffffff'%3E%3C/path%3E%3Cpath d='M0,0V15.81C13,36.92,27.64,56.86,47.69,72.05,99.41,111.27,165,111,224.58,91.58c31.15-10.15,60.09-26.07,89.67-39.8,40.92-19,84.73-46,130.83-49.67,36.26-2.85,70.9,9.42,98.6,31.56,31.77,25.39,62.32,62,103.63,73,40.44,10.79,81.35-6.69,119.13-24.28s75.16-39,116.92-43.05c59.73-5.85,113.28,22.88,168.9,38.84,30.2,8.66,59,6.17,87.09-7.5,22.43-10.89,48-26.93,60.65-49.24V0Z' opacity='.5' fill='%23ffffff'%3E%3C/path%3E%3Cpath d='M0,0V5.63C149.93,59,314.09,71.32,475.83,42.57c43-7.64,84.23-20.12,127.61-26.46,59-8.63,112.48,12.24,165.56,35.4C827.93,77.22,886,95.24,951.2,90c86.53-7,172.46-45.71,248.8-84.81V0Z' fill='%23ffffff'%3E%3C/path%3E%3C/svg%3E") repeat-x;
            animation: wave 10s linear infinite;
            opacity: 0.1;
        }

        @keyframes wave {
            0% { background-position-x: 0; }
            100% { background-position-x: 1200px; }
        }

        .login-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(15px);
            padding: 45px 35px;
            border-radius: 20px;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.2);
            width: 100%;
            max-width: 420px;
            text-align: center;
            animation: fadeIn 0.8s ease-in;
            position: relative;
            z-index: 10;
            border: 1px solid rgba(255, 255, 255, 0.3);
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
            margin: 0 0 30px 0;
            color: #2E4D32;
            font-size: 32px;
            font-weight: 700;
            letter-spacing: -0.5px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .form-group {
            text-align: left;
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #2E4D32;
            font-size: 15px;
        }

        .form-group input {
            width: 100%;
            padding: 15px 18px;
            font-size: 16px;
            border: 2px solid #E8F5E8;
            border-radius: 12px;
            transition: all 0.3s ease;
            background-color: rgba(255, 255, 255, 0.9);
            font-weight: 500;
        }

        .form-group input:focus {
            border-color: #4CAF50;
            outline: none;
            box-shadow: 0 0 0 4px rgba(76, 175, 80, 0.1);
            background-color: #ffffff;
            transform: translateY(-1px);
        }

        .form-group input::placeholder {
            color: #999999;
            font-size: 14px;
        }

        .login-btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(to right, #4CAF50 0%, #66BB6A 50%, #388E3C 100%);
            border: none;
            border-radius: 12px;
            color: #ffffff;
            font-size: 17px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 8px 20px rgba(76, 175, 80, 0.3);
            transition: all 0.3s ease;
            margin-top: 15px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .login-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 25px rgba(76, 175, 80, 0.4);
            background: linear-gradient(to right, #388E3C 0%, #4CAF50 50%, #66BB6A 100%);
        }

        .login-btn:active {
            transform: translateY(-1px);
            box-shadow: 0 6px 15px rgba(76, 175, 80, 0.35);
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
    <!-- Animated Background -->
    <div class="bg-animation">
        <!-- Floating Particles -->
        <div class="particle" style="width: 6px; height: 6px; top: 20%; left: 10%; animation-delay: 0s;"></div>
        <div class="particle" style="width: 8px; height: 8px; top: 60%; left: 20%; animation-delay: 1s;"></div>
        <div class="particle" style="width: 4px; height: 4px; top: 40%; left: 80%; animation-delay: 2s;"></div>
        <div class="particle" style="width: 10px; height: 10px; top: 80%; left: 70%; animation-delay: 3s;"></div>
        <div class="particle" style="width: 5px; height: 5px; top: 30%; left: 90%; animation-delay: 4s;"></div>
        <div class="particle" style="width: 7px; height: 7px; top: 70%; left: 5%; animation-delay: 5s;"></div>

        <!-- Visitor Management Related Icons -->
        <div class="floating-icon" style="top: 15%; left: 15%; animation-delay: 0s;">👥</div>
        <div class="floating-icon" style="top: 25%; left: 85%; animation-delay: 2s;">🏢</div>
        <div class="floating-icon" style="top: 45%; left: 10%; animation-delay: 4s;">🔐</div>
        <div class="floating-icon" style="top: 65%; left: 90%; animation-delay: 6s;">📋</div>
        <div class="floating-icon" style="top: 80%; left: 20%; animation-delay: 8s;">🚪</div>
        <div class="floating-icon" style="top: 35%; left: 75%; animation-delay: 1s;">👤</div>
        <div class="floating-icon" style="top: 55%; left: 25%; animation-delay: 3s;">📱</div>
        <div class="floating-icon" style="top: 75%; left: 80%; animation-delay: 5s;">🎫</div>
        <div class="floating-icon" style="top: 20%; left: 60%; animation-delay: 7s;">🔍</div>
        <div class="floating-icon" style="top: 85%; left: 40%; animation-delay: 9s;">⏰</div>

        <!-- Geometric Shapes -->
        <div class="shape circle" style="width: 30px; height: 30px; top: 10%; left: 50%; animation-delay: 0s;"></div>
        <div class="shape square" style="width: 25px; height: 25px; top: 70%; left: 60%; animation-delay: 3s;"></div>
        <div class="shape triangle" style="top: 40%; left: 45%; animation-delay: 6s;"></div>
        <div class="shape circle" style="width: 20px; height: 20px; top: 90%; left: 10%; animation-delay: 9s;"></div>
        <div class="shape square" style="width: 35px; height: 35px; top: 5%; left: 25%; animation-delay: 12s;"></div>

        <!-- Pulsing Rings -->
        <div class="ring" style="width: 100px; height: 100px; top: 20%; left: 70%; animation-delay: 0s;"></div>
        <div class="ring" style="width: 150px; height: 150px; top: 60%; left: 15%; animation-delay: 2s;"></div>
        <div class="ring" style="width: 80px; height: 80px; top: 80%; left: 85%; animation-delay: 4s;"></div>

        <!-- Wave Animation -->
        <div class="wave"></div>
    </div>

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

        // Dynamic Background Animation
        function createDynamicParticle() {
            const particle = document.createElement('div');
            particle.className = 'particle';
            particle.style.width = Math.random() * 8 + 4 + 'px';
            particle.style.height = particle.style.width;
            particle.style.left = Math.random() * 100 + '%';
            particle.style.top = '100%';
            particle.style.animationDuration = Math.random() * 4 + 6 + 's';
            particle.style.opacity = Math.random() * 0.3 + 0.1;
            
            document.querySelector('.bg-animation').appendChild(particle);
            
            setTimeout(() => {
                particle.remove();
            }, 10000);
        }

        // Create new particles periodically
        setInterval(createDynamicParticle, 3000);
    </script>
</body>
</html>
