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


</head>
<style>
:root {
	--primary-color: #2e7d32;
	--primary-light: #e8f4fd;
	--secondary-color: #f8f9fa;
}

body {
	background-color: #f5f5f5;
	overflow-x: hidden;
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.header {
	background-color: var(--primary-color);
	color: white;
	padding: 15px 0;
	box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
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
	background: white;
	border-radius: 8px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
	padding: 20px;
	margin-bottom: 25px;
	border-top: 3px solid var(--primary-color);
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
	background: white;
	padding: 15px;
	border-radius: 8px;
	text-align: center;
	min-width: 80px;
	border: 1px solid #ddd;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
	flex: 1;
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
	background: white;
	padding: 5px;
	border-radius: 8px;
	margin-bottom: 0;
}

.scanner-section h4 {
	margin-bottom: 5px;
}

.manual-entry {
	background: white;
	padding: 20px;
	border-radius: 8px;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
	display: none;
}

.manual-entry-btn {
	background: var(--primary-color);
	color: white;
	padding: 8px 15px;
	border: white;
	border-radius: 5px;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	margin-left: 15px;
}

.manual-entry-btn:hover {
	background: #1e5c22;
	border: white;
}

.manual-entry-btn i {
	margin-left: 8px;
}

#vehicleSection {
	display: block !important;
	background: #fff3cd;
	padding: 15px;
	margin: 15px 0;
	border-radius: 5px;
	border: 1px solid #ffeaa7;
}

.vehicle-section {
	background: #fff3cd;
	padding: 15px;
	margin: 15px 0;
	border-radius: 5px;
	border: 1px solid #ffeaa7;
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
	border-radius: 10px;
	border: none;
	box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.manual-entry-modal .modal-header {
	background-color: var(--primary-color);
	color: white;
	border-bottom: none;
	border-radius: 10px 10px 0 0;
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
	background-color: #f8f9fa;
	border-radius: 0 0 10px 10px;
}

.manual-entry-modal .btn-close {
	filter: invert(1);
}

@media ( max-width : 768px) {
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
		display: none; /* hides name text beside profile pic */
	}
}

@media ( max-width : 576px) {
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
}
</style>
<body>
	<!-- Header with Logo and User Info -->
	<header class="header">
		<div class="container">
			<div
				class="d-flex flex-wrap justify-content-between align-items-center">
				<div class="d-flex align-items-center flex-wrap">
					<img src="Images/Mahyco Grow Logo.png" alt="Logo"
						class="logo-img me-4"
						style="height: 50px; background-color: none;">
					<h1 class="page-title mb-0">Visitor Management System</h1>
				</div>
				<div class="d-flex align-items-center gap-3 mt-2 mt-md-0">
					<button class="manual-entry-btn btn" data-bs-toggle="modal"
						data-bs-target="#manualEntryModal">
						Manual Entry <i class="bi bi-shield-check"></i>
					</button>
					<div class="dropdown">
						<a
							class="d-flex align-items-center text-decoration-none dropdown-toggle text-white"
							href="#" id="userDropdown" role="button"
							data-bs-toggle="dropdown" aria-expanded="false"> <img
							src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzNSIgaGVpZ2h0PSIzNSIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJ3aGl0ZSI+PGNpcmNsZSBjeD0iMTIiIGN5PSI4IiByPSI0Ii8+PHBhdGggZD0iTTIwIDE5djFhMSAxIDAgMCAxLTEgMUg1YTEgMSAwIDAgMS0xLTF2LTFhMyAzIDAgMCAxIDMtM2gxMGEzIDMgMCAwIDEgMyAzeiIvPjwvc3ZnPg=="
							alt="User" class="user-img"> <span id="loggedInUser">Security
								Officer</span>
						</a>
						<ul class="dropdown-menu dropdown-menu-end"
							aria-labelledby="userDropdown">
							<li><a class="dropdown-item" href="Logout">Logout</a></li>
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
										<!-- <option value="" disabled selected hidden>-- Select Vehicle Type --</option>
 -->
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