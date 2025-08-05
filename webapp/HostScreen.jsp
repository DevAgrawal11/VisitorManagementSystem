
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
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
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
	rel="stylesheet">

<!-- DataTables CSS -->
<link rel="stylesheet"
	href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet"
	href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.bootstrap5.min.css">

<!-- Font Awesome for icons -->
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
:root {
	--primary-color: #2e7d32;
	--primary-light: #e8f4fd;
	--secondary-color: #f8f9fa;
}

.header {
	background-color: var(--primary-color);
	color: white;
	padding: 15px 0;
	box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	width: 100%;
	z-index: 1000;
}

html {
	scroll-behavior: smooth;
}
/* Add top margin to body to prevent content from hiding behind fixed header */
body {
	background-color: #f5f5f5;
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	padding-top: 90px; /* Adjust this value based on your header height */
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

.table-responsive {
	border-radius: 8px;
	overflow: hidden;
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

/* Enhanced Export Button Styling - Replace the existing block */
#exportButtonsContainer {
	margin: 15px 0;
	padding: 12px;
	background-color: #f8f9fa;
	border-radius: 6px;
	border: 1px solid #e9ecef;
}

#exportButtonsContainer strong {
	display: block;
	margin-bottom: 8px;
	color: #495057;
	font-size: 14px;
}

#exportButtonsContainer .dt-buttons {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;
	margin: 0;
}

.dt-button {
	display: inline-flex !important;
	align-items: center !important;
	gap: 4px !important;
	padding: 6px 12px !important;
	border-radius: 4px !important;
	border: none !important;
	font-size: 12px !important;
	font-weight: 500 !important;
	text-decoration: none !important;
	transition: all 0.2s ease !important;
	cursor: pointer !important;
	min-width: 80px !important;
	justify-content: center !important;
	white-space: nowrap !important;
}

.dt-button:hover {
	transform: translateY(-1px) !important;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15) !important;
}

.dt-button i {
	font-size: 12px !important;
}

/* Button specific colors - more subtle */
.buttons-csv {
	background-color: #198754 !important;
	color: white !important;
}

.buttons-excel {
	background-color: #0d6efd !important;
	color: white !important;
}

.buttons-pdf {
	background-color: #dc3545 !important;
	color: white !important;
}

.buttons-print {
	background-color: #6c757d !important;
	color: white !important;
}

.refresh-btn {
	background-color: #20c997 !important;
	color: white !important;
}

/* Dashboard Button Styling */
.dashboard-btn {
	background: rgba(255, 255, 255, 0.1);
	color: white;
	padding: 8px 15px;
	border: 1px solid rgba(255, 255, 255, 0.3);
	border-radius: 5px;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	margin-right: 15px;
	text-decoration: none;
	transition: all 0.3s ease;
	font-size: 0.9rem;
}

.dashboard-btn:hover {
	background: rgba(255, 255, 255, 0.2);
	color: white;
	text-decoration: none;
	border-color: rgba(255, 255, 255, 0.5);
}

.user-section {
	display: flex;
	align-items: center;
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

.stats-scanner-row {
	margin-bottom: 1px;
}

.header-controls {
	display: flex;
	align-items: center;
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
		display: none;
	}
	#exportButtonsContainer .dt-buttons {
		justify-content: center;
	}
	.dt-button {
		flex: 1 !important;
		min-width: 70px !important;
		font-size: 11px !important;
		padding: 5px 8px !important;
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
	.dashboard-btn {
		margin-right: 0;
		margin-bottom: 10px;
	}
	.user-section {
		width: 100%;
		justify-content: space-between;
	}
	#exportButtonsContainer .dt-buttons {
		flex-direction: column;
	}
	.dt-button {
		width: 100% !important;
		margin-bottom: 4px !important;
		min-width: unset !important;
	}
}
</style>
</head>

<body>
	<!-- Header with Logo and User Info -->
	<header class="header">
		<div class="container">
			<div class="d-flex justify-content-between align-items-center">
				<div class="logo-container">
					<div class="company-logo">
						<img src="Images/Mahyco Grow Logo.png" height="60"
							class="company-logo" alt="Company Logo">
					</div>
				</div>
				<div>
					<h1 class="page-title">Visitor Management System</h1>
				</div>
				<div class="user-section">
					<a href="#" class="dashboard-btn" onclick="showDashboard()"> 📊
						Dashboard </a>

					<div class="dropdown">
						<a
							class="d-flex align-items-center text-decoration-none dropdown-toggle text-white"
							href="#" id="userDropdown" role="button"
							data-bs-toggle="dropdown" aria-expanded="false"> <img
							src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzNSIgaGVpZ2h0PSIzNSIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJ3aGl0ZSI+PGNpcmNsZSBjeD0iMTIiIGN5PSI4IiByPSI0Ii8+PHBhdGggZD0iTTIwIDE5djFhMSAxIDAgMCAxLTEgMUg1YTEgMSAwIDAgMS0xLTF2LTFhMyAzIDAgMCAxIDMtM2gxMGEzIDMgMCAwIDEgMyAzeiIvPjwvc3ZnPg=="
							alt="User" class="user-img"> <span id="loggedInUser">
								<%=session.getAttribute("empName") != null ? session.getAttribute("empName") : "User"%>
						</span>
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

	<div class="container py-4">
		<!-- Visitor Dashboard -->
		<div class="form-section" id="dashboardSection" style="display: none;">
			<h3>Visitor Dashboard</h3>

			<div class="date-range">
				<div class="row g-3 align-items-center">
					<div class="col-md-4 d-flex align-items-center">
						<label for="fromDate" class="me-2 mb-0">From:</label> <input
							type="date" class="form-control" id="fromDate">
					</div>
					<div class="col-md-4 d-flex align-items-center">
						<label for="toDate" class="me-2 mb-0">To:</label> <input
							type="date" class="form-control" id="toDate">
					</div>
					<div class="col-md-2">
						<button class="btn btn-success" onclick="updateVisitorsTable()">Submit</button>
					</div>
				</div>
			</div>

			<div style="overflow-x: auto;">
				<div id="exportButtonsContainer">
					<strong>Export Options:</strong>
					<div class="dt-buttons"></div>
				</div>

				<table class="table table-striped table-hover display nowrap"
					id="visitorsTable">
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
		<div class="form-section" id="registerVisitorSection"
			style="display: block;">
			<h3>Register New Visitor</h3>

			<form id="visitorForm">
				<div class="row mb-3">
					<label for="name" class="col-md-3 col-form-label">Name:</label>
					<div class="col-md-9">
						<input type="text" class="form-control" id="name"
							placeholder="Visitor Name" required>
					</div>
				</div>

				<div class="row mb-3">
					<label for="mobile" class="col-md-3 col-form-label">Mobile
						No:</label>
					<div class="col-md-9">
						<input type="tel" class="form-control" id="mobile"
							placeholder="Mobile Number" required>
					</div>
				</div>

				<div class="row mb-3">
					<label for="whom" class="col-md-3 col-form-label">Person to
						Meet:</label>
					<div class="col-md-9">
						<input type="text" class="form-control" id="whom"
							placeholder="Person to visit" required>
					</div>
				</div>

				<div class="row mb-3">
					<label for="purpose" class="col-md-3 col-form-label">Purpose:</label>
					<div class="col-md-9">
						<textarea class="form-control" id="purpose" rows="1"
							placeholder="Purpose of visit" required></textarea>
					</div>
				</div>

				<div class="row mb-4">
					<label for="visitDateTime" class="col-md-3 col-form-label">Visit
						Date & Time:</label>
					<div class="col-md-9">
						<input type="datetime-local" class="form-control"
							id="visitDateTime" required>
					</div>
				</div>

				<div id="messageContainer" class="my-3"></div>

				<div class="d-grid">
					<button type="button" class="btn btn-success btn-lg"
						onclick="generateAndSendPass()">Generate & Send Gate Pass
					</button>
				</div>
			</form>
		</div>
	</div>

	<!-- jQuery (required for DataTables) -->
	<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

	<!-- Bootstrap JS Bundle -->
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

	<!-- DataTables JS -->
	<script
		src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
	<script
		src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

	<!-- DataTables Buttons Extensions -->
	<script
		src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
	<script
		src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.bootstrap5.min.js"></script>
	<script
		src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
	<script
		src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.print.min.js"></script>

	<!-- JSZip for Excel export -->
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>

	<!-- pdfMake for PDF export -->
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js"></script>
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.js"></script>

	<!-- Custom JavaScript -->
	<script
		src="${pageContext.request.contextPath}/JavaScript/hostScreen.js"></script>

</body>
</html>
