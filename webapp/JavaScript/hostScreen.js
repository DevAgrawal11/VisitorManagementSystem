// Enhanced hostScreen.js with improved dashboard loading and DD-MM-YYYY date formatting
const loggedInHostName = window.loggedInHostName || 'Unknown';

document.addEventListener('DOMContentLoaded', function () {
    console.log('DOM loaded, initializing hostScreen...');

    // Set today's date in both from and to date fields
    const today = new Date().toISOString().split('T')[0];
    const fromDate = document.getElementById('fromDate');
    const toDate = document.getElementById('toDate');

    if (fromDate) fromDate.value = today;
    if (toDate) toDate.value = today;

    initializeForm();
    
    // Show registration form by default instead of dashboard
    showRegistrationForm();
    
    // Initialize current time in visitor form
    formatCurrentTimeInput();
});

function initializeForm() {
    const form = document.getElementById('visitorForm');
    if (!form) {
        console.error('Visitor form not found!');
        return;
    }

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        console.log('Form submitted, calling generateAndSendPass...');
        generateAndSendPass();
    });
}

function generateRandomPassId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let result = '';
    for (let i = 0; i < 6; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    console.log('Generated Pass ID:', result);
    return result;
}

function showMessage(message, type = 'success') {
    console.log(`Showing ${type} message:`, message);
    const messageContainer = document.getElementById('messageContainer');
    const messageClass = type === 'success' ? 'result-success' : 
                        type === 'info' ? 'result-warning' : 'result-error';

    messageContainer.innerHTML = `<div class="${messageClass}">${message}</div>`;

    // Auto-hide message after 5 seconds
    setTimeout(() => {
        messageContainer.innerHTML = '';
    }, 5000);
}

async function generateAndSendPass() {
    try {
        const nameInput = document.getElementById('name');
        const mobileInput = document.getElementById('mobile');
        const whomInput = document.getElementById('whom');
        const purposeInput = document.getElementById('purpose');
        const visitDateTimeInput = document.getElementById('visitDateTime');

        const name = nameInput.value.trim();
        const mobile = mobileInput.value.trim();
        const whomToMeet = whomInput.value.trim();
        const purpose = purposeInput.value.trim();
        const visitDateTime = visitDateTimeInput.value;
        const createdBy = document.getElementById("loggedInUser")?.innerText || "Unknown";

        if (!name || !mobile || !whomToMeet || !purpose || !visitDateTime) {
            showMessage("All fields are required.", "error");
            return;
        }

        if (!/^\d{10}$/.test(mobile)) {
            showMessage("Please enter a valid 10-digit mobile number.", "error");
            return;
        }

        const passId = generateRandomPassId();

        const data = {
            passId,
            name,
            mobile,
            whomToMeet,
            purpose,
            visitDateTime,
            createdBy,
            status: 'Pending'
        };

        const response = await fetch("RegisterVisitor", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(data)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();
        console.log("Server response:", result);

        if (result.status === "success") {
            showMessage(`Gate Pass ID: ${passId} generated successfully.`, "success");

            const confirmSend = confirm(`Gate Pass ID: ${passId} generated successfully.\nDo you want to send it via WhatsApp now?`);
            if (confirmSend) {
                const [date, time] = visitDateTime.split("T");
                const formattedDate = formatDateToDDMMYY(date);
                const formattedTime = formatTimeTo12Hour(time);
                
                const message = `👋 Hello ${name},\n\n🛂 Your Gate Pass Details:\n📌 Pass ID: ${passId}\n👤 To Meet: ${whomToMeet}\n📝 Purpose: ${purpose}\n📅 Date: ${formattedDate}\n⏰ Time: ${formattedTime}\n\nRegards,\nMahyco Security Team`;
                const encodedMessage = encodeURIComponent(message);
                const formattedMobile = `91${mobile}`;
                const whatsappURL = `https://wa.me/${formattedMobile}?text=${encodedMessage}`;

                window.open(whatsappURL, "_blank");
            }
            
            // Clear form after successful submission
            document.getElementById('visitorForm').reset();
            // Reset the visitDateTime field to current time
            formatCurrentTimeInput();
            
        } else {
            showMessage(result.message || "Server error", "error");
        }

    } catch (err) {
        console.error("Error:", err);
        showMessage(`Error: ${err.message}. Please check console for details.`, "error");
    }
}

function showDashboard() {
    document.getElementById("dashboardSection").style.display = "block";
    document.getElementById("registerVisitorSection").style.display = "none";
    
    // Initialize DataTable when dashboard is shown
    setTimeout(() => {
        if (!$.fn.DataTable.isDataTable('#visitorsTable')) {
            initializeDataTableWithExports();
        }
        updateVisitorsTable();
    }, 100);
}

function showRegistrationForm() {
    document.getElementById("dashboardSection").style.display = "none";
    document.getElementById("registerVisitorSection").style.display = "block";
}

// Fixed updateVisitorsTable function
function updateVisitorsTable() {
    const fromDate = document.getElementById('fromDate').value;
    const toDate = document.getElementById('toDate').value;
    
    if (!fromDate || !toDate) {
        showMessage('Please select both from and to dates.', 'error');
        return;
    }

    // Initialize table if not already initialized
    let table;
    if (!$.fn.DataTable.isDataTable('#visitorsTable')) {
        table = initializeDataTableWithExports();
    } else {
        table = $('#visitorsTable').DataTable();
    }
    
    table.clear().draw();
    
    // Show loading message
    showMessage('Loading visitors...', 'info');
    
    fetch(`VisitorDashboard?action=dashboard&fromDate=${fromDate}&toDate=${toDate}`)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            // Clear loading message
            document.getElementById('messageContainer').innerHTML = '';
            
            if (data.status === 'error') {
                showMessage(data.message, 'error');
                return;
            }

            const visitors = Array.isArray(data) ? data : [data];
            if (visitors.length === 0) {
                showMessage('No visitors found for the selected date range.', 'info');
                return;
            }

            // Add rows to DataTable
            visitors.forEach(visitor => {
                const statusBadge = getStatusBadge(visitor.status);
                const actionButton = getActionButton(visitor);
                const formattedVisitDate = formatDateToDDMMYY(visitor.visitDate);
                
                table.row.add([
                    visitor.passId || '',
                    visitor.name || '',
                    visitor.mobile || '',
                    visitor.whomToMeet || '',
                    visitor.purpose || '',
                    statusBadge,
                    formatTimeTo12Hour(visitor.inTime) || 'N/A',
                    formatTimeTo12Hour(visitor.outTime) || 'N/A',
                    formattedVisitDate,
                    actionButton
                ]);
            });
            
            table.draw();
            showMessage(`Loaded ${visitors.length} visitor(s) successfully.`, 'success');
        })
        .catch(error => {
        console.error('Error:', error);
        showMessage(error.message, 'error');
    })
    .finally(() => {
        button.disabled = false;
        button.textContent = originalText;
    });
}

// Enhanced status display function
function getStatusBadge(status) {
    const normalizedStatus = status ? status.toString().toLowerCase().trim() : '';
    
    switch (normalizedStatus) {
        case '0':
        case 'checked out':
        case 'completed':
            return '<span class="badge bg-secondary">Checked Out</span>';
        case '1':
        case 'inside':
        case 'checked in':
            return '<span class="badge bg-success">Inside</span>';
        case '2':
        case 'generated':
        case 'pending':
            return '<span class="badge bg-primary">Generated</span>';
        case '3':
        case 'ready for checkout':
        case 'host completed':
            return '<span class="badge bg-warning text-dark">Ready for Checkout</span>';
        default:
            return '<span class="badge bg-light text-dark">Unknown</span>';
    }
}

// Mark visit complete function - Add this block to your hostScreen.js
async function markVisitComplete(passId) {
    if (!confirm('Are you sure you want to mark this visit as complete?')) {
        return;
    }

    try {
        // Send as form data to match servlet parameter reading
        const formData = new URLSearchParams();
        formData.append('action', 'update');
        formData.append('updateAction', 'markDone');
        formData.append('passId', passId);

        const response = await fetch('VisitorDashboard', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();

        if (result.status === 'success') {
            showMessage('Visit marked as complete successfully!', 'success');
            // Refresh the table to show updated status
            updateVisitorsTable();
        } else {
            showMessage(result.message || 'Failed to mark visit as complete', 'error');
        }

    } catch (error) {
        console.error('Error marking visit complete:', error);
        showMessage('Error marking visit complete. Please try again.', 'error');
    }
}
// Enhanced action button function
function getActionButton(visitor) {
    const status = visitor.status ? visitor.status.toString().toLowerCase().trim() : '';
    
    let buttons = `<button class="btn btn-sm btn-outline-primary me-1" 
        onclick="resendGatePass('${visitor.passId}', '${escapeQuotes(visitor.name)}', '${visitor.mobile}', 
        '${escapeQuotes(visitor.whomToMeet)}', '${escapeQuotes(visitor.purpose)}', '${visitor.visitDate}')">
        Resend Pass
    </button>`;
    
    if (status.includes('inside') || status === '1') {
        buttons += `<button class="btn btn-sm btn-outline-warning" 
            onclick="markVisitComplete('${visitor.passId}')">
            Mark Complete
        </button>`;
    }
    else if (status.includes('ready') || status === '3') {
        buttons += `<span class="badge bg-warning text-dark">Pending Security Checkout</span>`;
    }
    
    return buttons;
}

// Helper function to escape quotes in strings
function escapeQuotes(str) {
    if (!str) return '';
    return str.replace(/'/g, "\\'").replace(/"/g, '\\"');
}

// Enhanced resend gate pass function
function resendGatePass(passId, name, mobile, whomToMeet, purpose, visitDate) {
    if (!confirm('Are you sure you want to resend the gate pass?')) {
        return;
    }

    try {
        console.log('Resending pass for:', { passId, name, mobile, whomToMeet, purpose, visitDate });

        if (!name || !mobile) {
            showMessage('Invalid visitor data. Missing name or mobile number.', 'error');
            return;
        }

        // Format the date and time for WhatsApp message
        let formattedDate = '';
        let formattedTime = '';
        
        if (visitDate) {
            if (visitDate.includes('T')) {
                const [date, time] = visitDate.split('T');
                formattedDate = formatDateToDDMMYY(date);
                formattedTime = formatTimeTo12Hour(time.substring(0, 5));
            } else {
                formattedDate = formatDateToDDMMYY(visitDate);
                formattedTime = 'N/A';
            }
        }

        const message = `👋 Hello ${name},\n\n🛂 Your Gate Pass Details:\n📌 Pass ID: ${passId}\n👤 To Meet: ${whomToMeet}\n📝 Purpose: ${purpose}\n📅 Date: ${formattedDate}\n⏰ Time: ${formattedTime}\n\nRegards,\nMahyco Security Team`;

        let cleanMobile = mobile.toString().replace(/\D/g, '');
        const formattedMobile = cleanMobile.startsWith("91") ? cleanMobile : `91${cleanMobile}`;

        const whatsappURL = `https://wa.me/${formattedMobile}?text=${encodeURIComponent(message)}`;
        console.log('WhatsApp URL:', whatsappURL);

        const newWindow = window.open(whatsappURL, '_blank', 'noopener,noreferrer');

        if (newWindow && !newWindow.closed) {
            showMessage('Gate pass resent successfully!', 'success');
        } else {
            const link = document.createElement('a');
            link.href = whatsappURL;
            link.target = '_blank';
            link.rel = 'noopener noreferrer';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            showMessage('Gate pass resent successfully!', 'success');
        }

    } catch (err) {
        console.error('Error resending gate pass:', err);
        showMessage('Failed to resend gate pass. Please try again.', 'error');
    }
}

// Enhanced time formatting functions
function formatTimeTo12Hour(timeString) {
    if (!timeString || timeString === 'N/A') return 'N/A';
    
    try {
        let time;
        if (timeString.includes('T')) {
            time = new Date(timeString);
        } else if (timeString.includes(':')) {
            const [hours, minutes, seconds] = timeString.split(':');
            time = new Date();
            time.setHours(parseInt(hours), parseInt(minutes), parseInt(seconds || 0));
        } else {
            return timeString;
        }
        
        let hours = time.getHours();
        let minutes = time.getMinutes();
        
        const ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12;
        minutes = minutes < 10 ? '0' + minutes : minutes;
        
        return hours + ':' + minutes + ' ' + ampm;
    } catch (error) {
        console.error('Error formatting time:', error);
        return timeString;
    }
}

// Date formatting function to convert to DD-MM-YYYY format
function formatDateToDDMMYY(dateString) {
    if (!dateString) return 'N/A';
    
    try {
        let date;
        
        // Handle different date formats
        if (dateString.includes('T')) {
            // ISO format with time
            date = new Date(dateString);
        } else if (dateString.includes('-')) {
            // Check if it's already in YYYY-MM-DD format
            const parts = dateString.split('-');
            if (parts.length === 3) {
                if (parts[0].length === 4) {
                    // YYYY-MM-DD format
                    date = new Date(dateString);
                } else if (parts[2].length === 4) {
                    // DD-MM-YYYY format (already correct)
                    return dateString;
                } else {
                    // MM-DD-YYYY format, need to convert
                    date = new Date(`${parts[2]}-${parts[0]}-${parts[1]}`);
                }
            } else {
                date = new Date(dateString);
            }
        } else {
            date = new Date(dateString);
        }
        
        // Validate date
        if (isNaN(date.getTime())) {
            console.warn('Invalid date:', dateString);
            return dateString;
        }
        
        const day = date.getDate().toString().padStart(2, '0');
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
        const year = date.getFullYear();
        
        return `${day}-${month}-${year}`;
    } catch (error) {
        console.error('Error formatting date:', error, 'Input:', dateString);
        return dateString;
    }
}

// Auto-fill current date/time when form loads
function formatCurrentTimeInput() {
    const visitDateTime = document.getElementById('visitDateTime');
    if (visitDateTime && !visitDateTime.value) {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        
        visitDateTime.value = `${year}-${month}-${day}T${hours}:${minutes}`;
    }
}

// Enhanced DataTables initialization with export functionality
function initializeDataTableWithExports() {
    // Destroy existing DataTable if it exists
    if ($.fn.DataTable.isDataTable('#visitorsTable')) {
        $('#visitorsTable').DataTable().destroy();
    }
    
    // Initialize DataTable with export buttons
    const table = $('#visitorsTable').DataTable({
        responsive: true,
        pageLength: 10,
        lengthMenu: [5, 10, 25, 50, 100],
        order: [[8, 'desc']], // Sort by visit date descending
        dom: 'Bfrtip', // B = Buttons, f = filter, r = processing, t = table, i = info, p = pagination
        buttons: [
            {
                extend: 'csvHtml5',
                text: '<i class="fas fa-file-csv"></i> CSV',
                className: 'dt-button buttons-csv',
                title: function() {
                    const fromDate = document.getElementById('fromDate')?.value || 'All';
                    const toDate = document.getElementById('toDate')?.value || 'All';
                    return `Visitor_Report_${fromDate}_to_${toDate}`;
                },
                exportOptions: {
                    columns: [0, 1, 2, 3, 4, 5, 6, 7, 8], // Exclude Actions column
                    modifier: {
                        page: 'all'
                    },
                    format: {
                        body: function(data, row, column, node) {
                            // Remove HTML tags from exported data
                            return data.replace(/<[^>]*>/g, '');
                        }
                    }
                }
            },
            {
                extend: 'excelHtml5',
                text: '<i class="fas fa-file-excel"></i> Excel',
                className: 'dt-button buttons-excel',
                title: function() {
                    const fromDate = document.getElementById('fromDate')?.value || 'All';
                    const toDate = document.getElementById('toDate')?.value || 'All';
                    return `Visitor_Report_${fromDate}_to_${toDate}`;
                },
                exportOptions: {
                    columns: [0, 1, 2, 3, 4, 5, 6, 7, 8], // Exclude Actions column
                    modifier: {
                        page: 'all'
                    },
                    format: {
                        body: function(data, row, column, node) {
                            // Remove HTML tags from exported data
                            return data.replace(/<[^>]*>/g, '');
                        }
                    }
                }
            },
            {
                extend: 'pdfHtml5',
                text: '<i class="fas fa-file-pdf"></i> PDF',
                className: 'dt-button buttons-pdf',
                orientation: 'landscape',
                pageSize: 'A4',
                title: function() {
                    const fromDate = document.getElementById('fromDate')?.value || 'All';
                    const toDate = document.getElementById('toDate')?.value || 'All';
                    return `Visitor Report (${fromDate} to ${toDate})`;
                },
                exportOptions: {
                    columns: [0, 1, 2, 3, 4, 5, 6, 7, 8], // Exclude Actions column
                    modifier: {
                        page: 'all'
                    },
                    format: {
                        body: function(data, row, column, node) {
                            // Remove HTML tags from exported data
                            return data.replace(/<[^>]*>/g, '');
                        }
                    }
                },
                customize: function(doc) {
                    // Add custom styling to PDF
                    doc.content[1].table.widths = ['8%', '15%', '12%', '15%', '20%', '10%', '8%', '8%', '10%'];
                    
                    // Style the header
                    doc.content[0].fontSize = 16;
                    doc.content[0].alignment = 'center';
                    doc.content[0].margin = [0, 0, 0, 12];
                    
                    // Add footer with timestamp
                    doc.footer = function(currentPage, pageCount) {
                        return {
                            text: `Generated on: ${new Date().toLocaleString()} | Page ${currentPage} of ${pageCount}`,
                            alignment: 'center',
                            fontSize: 8,
                            margin: [0, 10, 0, 0]
                        };
                    };
                }
            },
            {
                extend: 'print',
                text: '<i class="fas fa-print"></i> Print',
                className: 'dt-button buttons-print',
                title: function() {
                    const fromDate = document.getElementById('fromDate')?.value || 'All';
                    const toDate = document.getElementById('toDate')?.value || 'All';
                    return `Visitor Report (${fromDate} to ${toDate})`;
                },
                exportOptions: {
                    columns: [0, 1, 2, 3, 4, 5, 6, 7, 8], // Exclude Actions column
                    modifier: {
                        page: 'all'
                    },
                    format: {
                        body: function(data, row, column, node) {
                            // Remove HTML tags from exported data
                            return data.replace(/<[^>]*>/g, '');
                        }
                    }
                },
                customize: function(win) {
                    // Add custom CSS for print
                    $(win.document.body)
                        .css('font-size', '12px')
                        .prepend('<div style="text-align:center; margin-bottom: 20px;"><h2>Mahyco Visitor Management System</h2></div>');
                    
                    $(win.document.body).find('table')
                        .addClass('compact')
                        .css('font-size', '11px');
                }
            },
            {
                text: '<i class="fas fa-sync-alt"></i> Refresh',
                className: 'dt-button refresh-btn',
                action: function(e, dt, node, config) {
                    updateVisitorsTable();
                }
            }
        ],
        columnDefs: [
            { targets: -1, orderable: false }, // Disable sorting on "Actions" column
            { targets: [6, 7], orderable: false } // Disable sorting on time columns
        ],
        language: {
            emptyTable: "No visitors found for the selected date range",
            processing: "Loading visitor data...",
            search: "Search visitors:",
            lengthMenu: "Show _MENU_ visitors per page",
            info: "Showing _START_ to _END_ of _TOTAL_ visitors",
            paginate: {
                first: "First",
                last: "Last",
                next: "Next",
                previous: "Previous"
            }
        }
    });
    
    // Move buttons to the designated container
    table.buttons().container().appendTo('#exportButtonsContainer .dt-buttons');
    
    return table;
}
