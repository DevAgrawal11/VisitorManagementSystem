<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // Session check
    String hostName = (String) session.getAttribute("empName");
    if (hostName == null) {
        response.sendRedirect("EmployeeLogin.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Host Screen - Visitor Management</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
<style>
:root {
    --primary-color: #2e7d32;
    --primary-light: #e8f4fd;
    --secondary-color: #f8f9fa;
}

/* Creative Animated Background */
body {
    background: linear-gradient(135deg, #f8fffe 0%, #f0f9f0 50%, #fafafa 100%);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    padding-top: 70px;
    position: relative;
    overflow-x: hidden;
}

/* Floating Background Icons */
.bg-decoration {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    pointer-events: none;
    z-index: -1;
    overflow: hidden;
}

.floating-icon {
    position: absolute;
    opacity: 0.15;
    animation: float 15s infinite linear;
    font-size: 24px;
    color: var(--primary-color);
}

.floating-icon:nth-child(odd) {
    animation-direction: reverse;
    animation-duration: 20s;
}

.floating-icon:nth-child(1) { top: 10%; left: 10%; animation-delay: 0s; }
.floating-icon:nth-child(2) { top: 20%; left: 80%; animation-delay: 2s; }
.floating-icon:nth-child(3) { top: 60%; left: 5%; animation-delay: 4s; }
.floating-icon:nth-child(4) { top: 40%; left: 90%; animation-delay: 6s; }
.floating-icon:nth-child(5) { top: 80%; left: 15%; animation-delay: 8s; }
.floating-icon:nth-child(6) { top: 70%; left: 85%; animation-delay: 10s; }
.floating-icon:nth-child(7) { top: 30%; left: 60%; animation-delay: 12s; }
.floating-icon:nth-child(8) { top: 90%; left: 70%; animation-delay: 14s; }
.floating-icon:nth-child(9) { top: 15%; left: 40%; animation-delay: 16s; }
.floating-icon:nth-child(10) { top: 55%; left: 75%; animation-delay: 18s; }

@keyframes float {
    0% {
        transform: translateY(0px) rotate(0deg);
        opacity: 0.15;
    }
    50% {
        transform: translateY(-20px) rotate(180deg);
        opacity: 0.10;
    }
    100% {
        transform: translateY(0px) rotate(360deg);
        opacity: 0.15;
    }
}

/* Subtle pattern overlay */
body::before {
    content: '';
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-image: 
        radial-gradient(circle at 25% 25%, rgba(46, 125, 50, 0.03) 0%, transparent 50%),
        radial-gradient(circle at 75% 75%, rgba(46, 125, 50, 0.02) 0%, transparent 50%);
    z-index: -1;
    pointer-events: none;
}

/* Header Styles */
.header {
    background-color: var(--primary-color);
    color: white;
    padding: 15px 0;
    box-shadow: 0 2px 10px rgba(0,0,0,0.2);
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    width: 100%;
    z-index: 1000;
}

.header-layout {
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
}

.left-section {
    flex: 0 0 auto;
}

.center-section {
    flex: 1;
    text-align: center;
    margin: 0 1rem;
}

.right-section {
    flex: 0 0 auto;
    display: flex;
    align-items: center;
    gap: 1rem;
}

.logo-img {
    height: 50px;
    background-color: none;
}

.page-title {
    color: white;
    margin: 0;
    font-weight: 500;
    font-size: 1.5rem;
}

.dashboard-btn {
    background: rgba(255, 255, 255, 0.1);
    color: white;
    padding: 8px 15px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 5px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    text-decoration: none;
    transition: all 0.3s ease;
    font-size: 0.9rem;
    gap: 0.5rem;
}

.dashboard-btn:hover {
    background: rgba(255, 255, 255, 0.2);
    color: white;
    text-decoration: none;
    border-color: rgba(255, 255, 255, 0.5);
}

.user-img {
    width: 35px;
    height: 35px;
    border-radius: 50%;
    object-fit: cover;
}

/* Export Container - Fixed positioning for dropdown */
#exportButtonsContainer {
    margin: 15px 0;
    padding: 12px;
    background-color: rgba(248, 249, 250, 0.9);
    border-radius: 6px;
    border: 1px solid #e9ecef;
    backdrop-filter: blur(5px);
    position: relative;
    z-index: 100;
}

.export-controls .btn {
    font-size: 0.875rem;
}

.export-controls .dropdown-menu {
    z-index: 1050 !important;
    position: absolute !important;
}

.export-controls .dropdown-item {
    font-size: 0.875rem;
    padding: 0.5rem 1rem;
}

.export-controls .dropdown-item:hover {
    background-color: #f8f9fa;
}

/* Hide DataTables default buttons container */
.dt-buttons {
    display: none !important;
}

/* Form and Content Styles */
.form-section {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 12px;
    box-shadow: 0 8px 25px rgba(0,0,0,0.08);
    padding: 25px;
    margin-bottom: 25px;
    border-top: 3px solid var(--primary-color);
    backdrop-filter: blur(10px);
    position: relative;
}

.form-section h3 {
    color: var(--primary-color);
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #eee;
}

.table-responsive {
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.table thead th {
    background-color: var(--primary-color);
    color: white;
    font-size: 0.9rem;
}

.table tbody td {
    font-size: 0.85rem;
    padding: 8px;
}

.action-cell button {
    font-size: 0.75rem;
    padding: 4px 8px;
}

.stats {
    display: flex;
    gap: 15px;
    margin-bottom: 0;
}

.stat-box {
    background: rgba(255, 255, 255, 0.9);
    padding: 15px;
    border-radius: 8px;
    text-align: center;
    min-width: 80px;
    border: 1px solid #ddd;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    flex: 1;
    backdrop-filter: blur(5px);
}

.stat-box strong {
    font-size: 1.5rem;
    color: var(--primary-color);
}

.stat-box small {
    color: #666;
    font-size: 0.9rem;
}

.status-in { 
    background-color: #d4edda !important; 
}

.status-out { 
    background-color: #f8d7da !important; 
}

.status-pending { 
    background-color: #cce5ff !important; 
}

/* Button Styles */
.btn-confirm {
    background: var(--primary-color);
    border: none;
    color: white;
    padding: 8px 15px;
    border-radius: 5px;
    margin-right: 10px;
}

.btn-confirm:hover {
    background: #1e5c22;
}

.btn-deny {
    background: #dc3545;
    border: none;
    color: white;
    padding: 8px 15px;
    border-radius: 5px;
}

.btn-deny:hover {
    background: #c82333;
}

/* Message Styles */
.result-success {
    color: #155724;
    background-color: #d4edda;
    border: 1px solid #c3e6cb;
    padding: 10px;
    border-radius: 5px;
    margin: 10px 0;
}

.result-warning {
    color: #856404;
    background-color: #fff3cd;
    border: 1px solid #ffeaa7;
    padding: 10px;
    border-radius: 5px;
    margin: 10px 0;
}

.result-error {
    color: #721c24;
    background-color: #f8d7da;
    border: 1px solid #f5c6cb;
    padding: 10px;
    border-radius: 5px;
    margin: 10px 0;
}

.stats-scanner-row {
    margin-bottom: 1px;
}

/* Responsive adjustments */
@media (max-width: 768px) {
    .header {
        padding: 8px 0;
    }
    
    .page-title {
        font-size: 1.3rem;
    }
    
    .logo-img {
        height: 40px;
    }
    
    .right-section {
        gap: 0.5rem;
    }
    
    .dashboard-btn {
        font-size: 0.8rem;
        padding: 6px 12px;
    }
    
    .center-section {
        margin: 0 0.5rem;
    }
    
    body {
        padding-top: 70px;
    }

    .table thead {
        font-size: 0.75rem;
    }

    .table td, .table th {
        white-space: nowrap;
    }

    .date-range .col-md-4,
    .date-range .col-md-2 {
        margin-bottom: 10px;
    }

    .dropdown-toggle span {
        display: none;
    }

    .floating-icon {
        font-size: 20px;
    }
}

@media (max-width: 576px) {
    .page-title {
        font-size: 1.1rem;
    }
    
    .dashboard-btn span {
        display: none;
    }
    
    .dropdown-toggle span {
        display: none;
    }
    
    body {
        padding-top: 65px;
    }

    .stats-scanner-row {
        flex-direction: column;
    }

    .stats-scanner-row > .col-md-6 {
        width: 100%;
        margin-bottom: 15px;
    }

    .stats {
        flex-direction: column;
        gap: 10px;
    }
    
    .stat-box {
        min-width: unset;
        width: 100%;
    }

    .floating-icon {
        font-size: 18px;
    }
}
</style>
</head>

<body>
    <!-- Creative Background Decoration -->
    <div class="bg-decoration">
        <div class="floating-icon"><i class="fas fa-user-friends"></i></div>
        <div class="floating-icon"><i class="fas fa-id-card"></i></div>
        <div class="floating-icon"><i class="fas fa-building"></i></div>
        <div class="floating-icon"><i class="fas fa-handshake"></i></div>
        <div class="floating-icon"><i class="fas fa-calendar-check"></i></div>
        <div class="floating-icon"><i class="fas fa-door-open"></i></div>
        <div class="floating-icon"><i class="fas fa-user-check"></i></div>
        <div class="floating-icon"><i class="fas fa-clipboard-list"></i></div>
        <div class="floating-icon"><i class="fas fa-users"></i></div>
        <div class="floating-icon"><i class="fas fa-shield-alt"></i></div>
    </div>

    <!-- Header with Logo and User Info -->
<header class="header">
    <div class="container">
        <div class="header-layout">
            <!-- Left section: Logo only -->
            <div class="left-section">
                <img src="Images/Mahyco Grow Logo.png" 
                     alt="Logo" 
                     class="logo-img">
            </div>
            
            <!-- Center section: Title -->
            <div class="center-section">
                <h1 class="page-title mb-0">Visitor Management System</h1>
            </div>
            
            <!-- Right section: Dashboard button and User Dropdown -->
            <div class="right-section">
                <a href="#" class="dashboard-btn" onclick="showDashboard()">
                    📊 <span>Dashboard</span>
                </a>
                
                <div class="dropdown">
                    <a class="d-flex align-items-center text-decoration-none dropdown-toggle text-white" 
                       href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzNSIgaGVpZ2h0PSIzNSIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJ3aGl0ZSI+PGNpcmNsZSBjeD0iMTIiIGN5PSI4IiByPSI0Ii8+PHBhdGggZD0iTTIwIDE5djFhMSAxIDAgMCAxLTEgMUg1YTEgMSAwIDAgMS0xLTF2LTFhMyAzIDAgMCAxIDMtM2gxMGEzIDMgMCAwIDEgMyAzeiIvPjwvc3ZnPg==" 
                             alt="User" class="user-img me-2">
                        <span>
                            <%= session.getAttribute("empName") != null ? session.getAttribute("empName") : "User" %>
                        </span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                        <li><a class="dropdown-item" href="Logout">Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</header>

    <div class="container py-4">
        <!-- Visitor Dashboard -->
        <div class="form-section" id="dashboardSection" style="display: none;">
            <h3>Visitor Dashboard</h3>
            
            <div class="date-range">
                <div class="row g-3 align-items-center">
                    <div class="col-md-4 d-flex align-items-center">
                        <label for="fromDate" class="me-2 mb-0">From:</label>
                        <input type="date" class="form-control" id="fromDate">
                    </div>
                    <div class="col-md-4 d-flex align-items-center">
                        <label for="toDate" class="me-2 mb-0">To:</label>
                        <input type="date" class="form-control" id="toDate">
                    </div>
                    <div class="col-md-2">
                        <button class="btn btn-success" onclick="updateVisitorsTable()">Submit</button>
                    </div>
                </div>
            </div>
            
            <div style="overflow-x: auto;">
               <div id="exportButtonsContainer">
                    <div class="d-flex align-items-center justify-content-between">
                        <strong>Export Options:</strong>
                        <div class="export-controls d-flex align-items-center gap-2">
                            <!-- Export Dropdown -->
                            <div class="dropdown">
                                <button class="btn btn-outline-secondary btn-sm dropdown-toggle" 
                                        type="button" 
                                        id="exportDropdown" 
                                        data-bs-toggle="dropdown" 
                                        aria-expanded="false">
                                    <i class="fas fa-download me-1"></i> Export
                                </button>
                                <ul class="dropdown-menu" aria-labelledby="exportDropdown">
                                    <li>
                                        <a class="dropdown-item" href="#" onclick="exportTable('csv')">
                                            <i class="fas fa-file-csv text-success me-2"></i> CSV
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="#" onclick="exportTable('excel')">
                                            <i class="fas fa-file-excel text-primary me-2"></i> Excel
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="#" onclick="exportTable('pdf')">
                                            <i class="fas fa-file-pdf text-danger me-2"></i> PDF
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="#" onclick="exportTable('print')">
                                            <i class="fas fa-print text-secondary me-2"></i> Print
                                        </a>
                                    </li>
                                </ul>
                            </div>
                            
                            <!-- Refresh Button -->
                            <button class="btn btn-outline-success btn-sm" onclick="updateVisitorsTable()">
                                <i class="fas fa-sync-alt me-1"></i> Refresh
                            </button>
                        </div>
                    </div>
                </div>
                <table class="table table-striped table-hover display nowrap" id="visitorsTable">
                    <thead>
                        <tr>
                            <th>Pass ID</th>
                            <th>Name</th>
                            <th>Mobile</th>
                            <th>Person to Meet</th>
                            <th>Purpose</th>
                            <th>Status</th>
                            <th>In Time</th>
                            <th>Out Time</th>
                            <th>Visit Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="visitorsBody">
                        <!-- Visitor data will be populated here -->
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Register New Visitor Form -->
        <div class="form-section" id="registerVisitorSection" style="display: block;">
            <h3>Register New Visitor</h3>
            
            <form id="visitorForm">
                <div class="row mb-3">
                    <label for="name" class="col-md-3 col-form-label">Name:</label>
                    <div class="col-md-9">
                        <input type="text" class="form-control" id="name" placeholder="Visitor Name" required>
                    </div>
                </div>
                
                <div class="row mb-3">
                    <label for="mobile" class="col-md-3 col-form-label">Mobile No:</label>
                    <div class="col-md-9">
                        <input type="tel" class="form-control" id="mobile" placeholder="Mobile Number" required>
                    </div>
                </div>
                
                <div class="row mb-3">
                    <label for="whom" class="col-md-3 col-form-label">Person to Meet:</label>
                    <div class="col-md-9">
                        <input type="text" class="form-control" id="whom" placeholder="Person to visit" required>
                    </div>
                </div>
                
                <div class="row mb-3">
                    <label for="purpose" class="col-md-3 col-form-label">Purpose:</label>
                    <div class="col-md-9">
                        <textarea class="form-control" id="purpose" rows="1" placeholder="Purpose of visit" required></textarea>
                    </div>
                </div>
                
                <div class="row mb-4">
                    <label for="visitDateTime" class="col-md-3 col-form-label">Visit Date & Time:</label>
                    <div class="col-md-9">
                        <input type="datetime-local" class="form-control" id="visitDateTime" required>
                    </div>
                </div>
                
                <div id="messageContainer" class="my-3"></div>
                
                <div class="d-grid">
                    <button type="button" class="btn btn-success btn-lg" onclick="generateAndSendPass()">
                        Generate & Send Gate Pass
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- jQuery (required for DataTables) -->
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    
    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
    
    <!-- DataTables Buttons Extensions -->
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.print.min.js"></script>
    
    <!-- JSZip for Excel export -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
    
    <!-- pdfMake for PDF export -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.js"></script>
    
    <!-- Custom JavaScript -->
    <script src="${pageContext.request.contextPath}/JavaScript/hostScreen.js"></script>
    
</body>
</html>
