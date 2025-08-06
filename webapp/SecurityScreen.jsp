<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%
// Prevent browser from caching the page
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
response.setHeader("Pragma", "no-cache"); // HTTP 1.0
response.setDateHeader("Expires", 0); // Proxies

// Session and role validation
String empId = (String) session.getAttribute("empId");
String empName = (String) session.getAttribute("empName");
String empRole = (String) session.getAttribute("userRole");

if (empId == null || empRole == null || !empRole.equals("security")) {
	response.sendRedirect("EmployeeLogin.jsp");
	return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Security Screen - Mahyco Visitor Management</title>

<!-- Bootstrap 5 CSS -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
	rel="stylesheet">

<!-- DataTables CSS (single version) -->
<link rel="stylesheet"
	href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">

<!-- Bootstrap Icons -->
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">

<!-- SweetAlert2 CSS -->
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/sweetalert2/11.7.0/sweetalert2.min.css">

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

.header {
	background-color: var(--primary-color);
	color: white;
	padding: 15px 0;
	box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}
.header {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
    padding: 0.8rem 0;
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

body {
    margin-top: 80px; /* Adjust based on your header height */
}
.logo-container {
	display: flex;
	align-items: center;
}

.logo-img {
	height: 50px;
	margin-right: 10px;
	background-color: none;
}

.form-section {
	background: rgba(255, 255, 255, 0.95);
	border-radius: 12px;
	box-shadow: 0 8px 25px rgba(0,0,0,0.08);
	padding: 20px;
	margin-bottom: 25px;
	border-top: 3px solid var(--primary-color);
	backdrop-filter: blur(10px);
}

.form-section h3 {
	color: var(--primary-color);
	margin-bottom: 20px;
	padding-bottom: 10px;
	border-bottom: 1px solid #eee;
}

.user-img {
	width: 35px;
	height: 35px;
	border-radius: 50%;
	object-fit: cover;
	margin-right: 8px;
}

.page-title {
	color: white;
	margin: 0;
	font-weight: 500;
	font-size: 1.4rem;
}

.security-screen-title {
	color: white;
	margin: 5px 0 0 0;
	font-weight: 400;
	font-size: 1.1rem;
}

.host-link {
	color: var(--primary-color);
	font-weight: 500;
	text-decoration: none;
	display: inline-block;
	margin-top: 15px;
}

.host-link:hover {
	text-decoration: underline;
}

.table-responsive {
	border-radius: 8px;
	overflow: hidden;
	overflow-x: auto;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
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
	background: rgba(255, 255, 255, 0.95);
	padding: 15px;
	border-radius: 8px;
	text-align: center;
	min-width: 80px;
	border: 1px solid #ddd;
	box-shadow: 0 4px 8px rgba(0,0,0,0.08);
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

.scanner-section {
	background: rgba(255, 255, 255, 0.9);
	padding: 15px;
	border-radius: 8px;
	margin-bottom: 0;
	backdrop-filter: blur(5px);
	box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.scanner-section h4 {
	margin-bottom: 5px;
}

.manual-entry {
	background: rgba(255, 255, 255, 0.95);
	padding: 20px;
	border-radius: 8px;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
	display: none;
	backdrop-filter: blur(10px);
}

.manual-entry-btn {
	background: var(--primary-color);
	color: white;
	padding: 8px 15px;
	border: none;
	border-radius: 6px;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	margin-left: 15px;
	transition: all 0.3s ease;
	font-weight: 500;
}

.manual-entry-btn:hover {
	background: #1e5c22;
	transform: translateY(-1px);
	box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

.manual-entry-btn i {
	margin-left: 8px;
}

#vehicleSection {
	display: block !important;
	background: rgba(255, 243, 205, 0.9);
	padding: 15px;
	margin: 15px 0;
	border-radius: 8px;
	border: 1px solid #ffeaa7;
	backdrop-filter: blur(5px);
}

.vehicle-section {
	background: rgba(255, 243, 205, 0.9);
	padding: 15px;
	margin: 15px 0;
	border-radius: 8px;
	border: 1px solid #ffeaa7;
	backdrop-filter: blur(5px);
}

.vehicle-section h5 {
	color: #856404;
	margin-bottom: 10px;
}

.btn-confirm {
	background: var(--primary-color);
	border: none;
	color: white;
	padding: 8px 15px;
	border-radius: 5px;
	margin-right: 10px;
	transition: all 0.3s ease;
}

.btn-confirm:hover {
	background: #1e5c22;
	transform: translateY(-1px);
}

.btn-deny {
	background: #dc3545;
	border: none;
	color: white;
	padding: 8px 15px;
	border-radius: 5px;
	transition: all 0.3s ease;
}

.btn-deny:hover {
	background: #c82333;
	transform: translateY(-1px);
}

.result-success {
	color: #155724;
	background-color: rgba(212, 237, 218, 0.9);
	border: 1px solid #c3e6cb;
	padding: 10px;
	border-radius: 5px;
	margin: 10px 0;
	backdrop-filter: blur(5px);
}

.result-warning {
	color: #856404;
	background-color: rgba(255, 243, 205, 0.9);
	border: 1px solid #ffeaa7;
	padding: 10px;
	border-radius: 5px;
	margin: 10px 0;
	backdrop-filter: blur(5px);
}

.result-error {
	color: #721c24;
	background-color: rgba(248, 215, 218, 0.9);
	border: 1px solid #f5c6cb;
	padding: 10px;
	border-radius: 5px;
	margin: 10px 0;
	backdrop-filter: blur(5px);
}

.notifications-badge {
	position: absolute;
	top: -5px;
	right: -5px;
	background-color: #dc3545;
	color: white;
	border-radius: 50%;
	width: 20px;
	height: 20px;
	font-size: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.stats-scanner-row {
	margin-bottom: 1px;
}

.header-controls {
	display: flex;
	align-items: center;
}

/* Modal styles for manual entry */
.manual-entry-modal .modal-content {
	border-radius: 12px;
	border: none;
	box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
	backdrop-filter: blur(10px);
	background: rgba(255, 255, 255, 0.98);
}

.manual-entry-modal .modal-header {
	background-color: var(--primary-color);
	color: white;
	border-bottom: none;
	border-radius: 12px 12px 0 0;
	padding: 15px 20px;
}

.manual-entry-modal .modal-title {
	font-weight: 500;
}

.manual-entry-modal .modal-body {
	padding: 20px;
}

.manual-entry-modal .modal-footer {
	border-top: none;
	padding: 15px 20px;
	background-color: rgba(248, 249, 250, 0.9);
	border-radius: 0 0 12px 12px;
	backdrop-filter: blur(5px);
}

.manual-entry-modal .btn-close {
	filter: invert(1);
}

/* Enhanced form controls */
.form-control, .form-select {
	background: rgba(255, 255, 255, 0.9);
	border: 1px solid #dee2e6;
	border-radius: 6px;
	transition: all 0.3s ease;
}

.form-control:focus, .form-select:focus {
	background: rgba(255, 255, 255, 1);
	border-color: var(--primary-color);
	box-shadow: 0 0 0 0.2rem rgba(46, 125, 50, 0.25);
}

/* Enhanced buttons */
.btn {
	border-radius: 6px;
	font-weight: 500;
	transition: all 0.3s ease;
}

.btn:hover {
	transform: translateY(-1px);
}

.btn-success {
	background: var(--primary-color);
	border-color: var(--primary-color);
}

.btn-success:hover {
	background: #1e5c22;
	border-color: #1e5c22;
}

@media (max-width: 768px) {
	.table thead {
		font-size: 0.75rem;
	}
	.table td, .table th {
		white-space: nowrap;
	}
	.date-range .col-md-4, .date-range .col-md-2 {
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
	.logo-container {
		flex-direction: column;
		align-items: flex-start;
	}
	.header .container>.d-flex {
		flex-direction: column;
		align-items: flex-start;
	}
	.header-controls, .dropdown {
		margin-top: 10px;
		width: 100%;
		display: flex;
		justify-content: space-between;
		flex-wrap: wrap;
	}
	.manual-entry-btn {
		margin-left: 0 !important;
		margin-top: 10px;
	}
	.dropdown-toggle span {
		display: none;
	}
	.logo-img, .company-logo {
		height: 40px !important;
	}
	.page-title {
		font-size: 1.1rem !important;
	}
	.stats-scanner-row {
		flex-direction: column;
	}
	.stats-scanner-row>.col-md-6 {
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
		<div class="floating-icon"><i class="fas fa-shield-alt"></i></div>
		<div class="floating-icon"><i class="fas fa-id-card-alt"></i></div>
		<div class="floating-icon"><i class="fas fa-user-shield"></i></div>
		<div class="floating-icon"><i class="fas fa-car"></i></div>
		<div class="floating-icon"><i class="fas fa-clipboard-check"></i></div>
		<div class="floating-icon"><i class="fas fa-door-open"></i></div>
		<div class="floating-icon"><i class="fas fa-users-cog"></i></div>
		<div class="floating-icon"><i class="fas fa-qrcode"></i></div>
		<div class="floating-icon"><i class="fas fa-building"></i></div>
		<div class="floating-icon"><i class="fas fa-hand-paper"></i></div>
	</div>

	<!-- Header with Logo and User Info -->
<header class="header">
    <div class="container">
        <div class="header-layout">
            <!-- Left section: Logo -->
            <div class="left-section">
                <img src="Images/Mahyco Grow Logo.png" 
                     alt="Logo" 
                     class="logo-img">
            </div>
            
            <!-- Center section: Title -->
            <div class="center-section">
                <h1 class="page-title mb-0">Visitor Management System</h1>
            </div>
            
            <!-- Right section: Manual Entry Button and User Dropdown -->
            <div class="right-section">
                <button class="manual-entry-btn btn" 
                        data-bs-toggle="modal" 
                        data-bs-target="#manualEntryModal">
                    Manual Entry <i class="bi bi-shield-check"></i>
                </button>
                
                <div class="dropdown">
                    <a class="d-flex align-items-center text-decoration-none dropdown-toggle text-white" 
                       href="#" 
                       id="userDropdown" 
                       role="button" 
                       data-bs-toggle="dropdown" 
                       aria-expanded="false">
                        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzNSIgaGVpZ2h0PSIzNSIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJ3aGl0ZSI+PGNpcmNsZSBjeD0iMTIiIGN5PSI4IiByPSI0Ii8+PHBhdGggZD0iTTIwIDE5djFhMSAxIDAgMCAxLTEgMUg1YTEgMSAwIDAgMS0xLTF2LTFhMyAzIDAgMCExIDMtM2gxMGEzIDMgMCAwIDEgMyAzeiIvPjwvc3ZnPg==" 
                             alt="User" 
                             class="user-img me-2">
                        <span id="loggedInUser">Security Officer</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end" 
                        aria-labelledby="userDropdown">
                        <li>
                            <a class="dropdown-item" href="Logout">Logout</a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</header>

	<div class="container mt-4">
		<div class="row stats-scanner-row">
			<!-- Today's Statistics Column -->
			<div class="col-12 col-md-6 mb-3">
				<div class="form-section">
					<h3>Today's Statistics</h3>
					<div class="stats">
						<div class="stat-box">
							<strong id="totalPending">0</strong><br> <small>Pending</small>
						</div>
						<div class="stat-box">
							<strong id="totalIn">0</strong><br> <small>Checked In</small>
						</div>
						<div class="stat-box warning">
							<strong id="totalReadyForCheckout">0</strong><br> <small><i
								class="fas fa-clock"></i> GatePass Check </small>
						</div>
						<div class="stat-box">
							<strong id="totalOut">0</strong><br> <small>Checked Out</small>
						</div>
						<div class="stat-box">
							<strong id="totalVisitors">0</strong><br> <small>Today's Count</small>
						</div>
					</div>
				</div>
			</div>

			<!-- Enter Pass ID Column -->
			<div class="col-12 col-md-6 mb-3">
				<div class="form-section">
					<h3>Enter Pass ID</h3>
					<div class="scanner-section">
						<div class="row mb-3">
							<div class="col-12 col-md-8 mb-2 mb-md-0">
								<input type="text" id="passIdInput" class="form-control"
									placeholder="Enter Pass ID">

							</div>
							<div class="col-12 col-md-4">
								<button class="btn btn-success w-100" onclick="processPassId()">Verify</button>
							</div>
						</div>
						<div id="scanResult"></div>
					</div>
				</div>
			</div>
		</div>

		<!-- Visitor Verified Modal -->
		<div class="modal fade" id="visitorVerifiedModal" tabindex="-1"
			aria-labelledby="visitorVerifiedModalLabel" aria-hidden="true">
			<div class="modal-dialog modal-lg">
				<div class="modal-content">
					<!-- Modal Header -->
					<div class="modal-header bg-success text-white">
						<h5 class="modal-title" id="visitorVerifiedModalLabel">Visitor
							Verified ✓</h5>
						<button type="button" class="btn-close" data-bs-dismiss="modal"
							aria-label="Close"></button>
					</div>

					<!-- Modal Body -->
					<div class="modal-body">
						<div class="row">
							<!-- Left Column -->
							<div class="col-md-6">
								<div class="form-group row mb-2">
									<label class="col-sm-4 col-form-label"><strong>Name:</strong></label>
									<div class="col-sm-8">
										<p id="modalName" class="form-control-plaintext mb-0"></p>
									</div>
								</div>

								<div class="form-group row mb-2">
									<label class="col-sm-4 col-form-label"><strong>Visiting
											To:</strong></label>
									<div class="col-sm-8">
										<p id="modalWhom" class="form-control-plaintext mb-0"></p>
									</div>
								</div>

								<div id="vehicleTypeWrapper" style="display: none;">
									<label class="mt-2"><strong>Vehicle Type:</strong></label> <select
										class="form-control" id="vehicleType">
										<option value="Personal Vehicle">Personal Vehicle</option>
										<option value="Mahyco Vehicle">Mahyco Vehicle</option>
									</select>
								</div>
							</div>

							<!-- Right Column -->
							<div class="col-md-6">
								<div class="form-group row mb-2">
									<label class="col-sm-4 col-form-label"><strong>Mobile:</strong></label>
									<div class="col-sm-8">
										<p id="modalMobile" class="form-control-plaintext mb-0"></p>
									</div>
								</div>

								<div class="form-group row mb-2">
									<label class="col-sm-4 col-form-label"><strong>Visit Date:</strong></label>
									<div class="col-sm-8">
										<p id="modalVisitDate" class="form-control-plaintext mb-0"></p>
									</div>
								</div>

								<div id="vehicleNumberWrapper" style="display: block;">
									<label class="mt-2"><strong>Vehicle Number:</strong></label> <input
										type="text" class="form-control" id="vehicleNumber"
										placeholder="Enter vehicle number">
								</div>
							</div>
						</div>
					</div>

					<!-- Modal Footer -->
					<div class="modal-footer justify-content-center">
						<button id="Confirm" class="btn btn-success"
							onclick="confirmEntry()">Confirm Entry</button>
						<button id="denyEntryBtn" class="btn btn-danger"
							onclick="processExit()" style="display: none;">Deny Entry</button>
					</div>
				</div>
			</div>
		</div>

		<!-- Manual Entry Modal -->
		<div class="modal fade manual-entry-modal" id="manualEntryModal"
			tabindex="-1" aria-labelledby="manualEntryModalLabel"
			aria-hidden="true">
			<div class="modal-dialog modal-lg">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" id="manualEntryModalLabel">Manual
							Visitor Entry</h5>
						<button type="button" class="btn-close" data-bs-dismiss="modal"
							aria-label="Close"></button>
					</div>
					<div class="modal-body">
						<div class="row">
							<div class="col-12 col-md-6 mb-3">
								<label for="manualName" class="form-label">Name:</label> <input
									type="text" class="form-control" id="manualName">
							</div>
							<div class="col-12 col-md-6 mb-3">
								<label for="manualMobile" class="form-label">Mobile:</label> <input
									type="tel" class="form-control" id="manualMobile">
							</div>
						</div>
						<div class="row">
							<div class="col-12 col-md-6 mb-3">
								<label for="manualWhom" class="form-label">Person to
									Meet:</label> <input type="text" class="form-control" id="manualWhom">
							</div>
							<div class="col-12 col-md-6 mb-3">
								<label for="manualPurpose" class="form-label">Purpose:</label> <input
									type="text" class="form-control" id="manualPurpose">
							</div>
						</div>
						<div class="row">
							<div class="col-12 col-md-6 mb-3">
								<label for="manualVehicleType" class="form-label">Vehicle
									Type:</label> <select class="form-select" id="manualVehicleType">
									<option value="">No Vehicle</option>
									<option value="Personal">Personal</option>
									<option value="Mahyco">Mahyco</option>
								</select>
							</div>
							<div class="col-12 col-md-6 mb-3">
								<label for="manualVehicleNumber" class="form-label">Vehicle
									Number:</label> <input type="text" class="form-control"
									id="manualVehicleNumber">
							</div>
						</div>
						<div id="manualEntryResult" class="mt-3" style="display: none;"></div>
					</div>
					<div class="modal-footer justify-content-center">
						<button type="button" class="btn btn-success"
							onclick="processManualEntry()">Process Entry</button>
					</div>
				</div>
			</div>
		</div>

<!-- Visitors Table with DataTables -->
<div class="form-section">
	<div class="d-flex justify-content-between align-items-center mb-3">
		<h3 class="mb-0">Today's Visitors</h3>
		<button class="btn btn-outline-primary btn-sm" onclick="refreshVisitorsTable()" title="Refresh Visitors">
			<i class="bi bi-arrow-clockwise"></i> Refresh
		</button>
	</div>
	<div style="overflow-x: auto;" class="table-responsive">
		<table class="table table-striped table-hover" id="securityTable">
			<thead>
				<tr>
					<th>Pass ID</th>
					<th>Name</th>
					<th>Mobile</th>
					<th>Person to Meet</th>
					<th>Purpose</th>
					<th>Vehicle Type</th>
					<th>Vehicle Number</th>
					<th>In Time</th>
					<th>Out Time</th>
					<th>Status</th>
				</tr>
			</thead>
			<tbody id="securityTableBody">
			</tbody>
		</table>
	</div>
</div>
	</div>

	<!-- jQuery (required for DataTables) -->
	<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

	<!-- DataTables JS (matching version with CSS) -->
	<script
		src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
	<script
		src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

	<!-- Bootstrap JS Bundle -->
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

	<!-- SweetAlert2 for better alerts -->
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/sweetalert2/11.7.0/sweetalert2.min.js"></script>

	<script
		src="${pageContext.request.contextPath}/JavaScript/securityScreen.js"></script>
</body>
</html>
