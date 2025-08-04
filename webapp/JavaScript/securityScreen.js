let currentVisitor = null;
let processingAction = null;

// Initialize on page load
document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('passIdInput').focus();

    // Trigger when Enter is pressed in the input
    document.getElementById('passIdInput').addEventListener('keypress', function (e) {
        if (e.key === 'Enter') {
            console.log("Enter key pressed. Calling processPassId()");
            processPassId();
        }
    });

    // Add verify button click handler
    const verifyBtn = document.getElementById('verifyBtn');
    if (verifyBtn) {
        verifyBtn.addEventListener('click', function(e) {
            e.preventDefault();
            console.log("Verify button clicked. Calling processPassId()");
            processPassId();
        });
    }

    updateStatistics();
    loadTodaysVisitors();
});

// Clear form when modal closes
document.getElementById('manualEntryModal').addEventListener('hidden.bs.modal', function () {
    clearManualEntry();
});

// Enhanced Pass ID processing function with better debugging
function processPassId() {
    const passIdInput = document.getElementById('passIdInput');
    const verifyBtn = document.getElementById('verifyBtn');
    
    console.log("=== Process Pass ID Started ===");
    console.log("passIdInput element:", passIdInput);
    console.log("verifyBtn element:", verifyBtn);
    
    if (!passIdInput) {
        console.error("passIdInput element not found!");
        showResult('System error: Input field not found', 'error');
        return;
    }
    
    const passId = passIdInput.value.trim();
    console.log("Processing Pass ID:", passId);

    if (!passId) {
        showResult('Please enter a Pass ID', 'error');
        passIdInput.focus();
        return;
    }

    // Disable verify button during processing
    if (verifyBtn) {
        verifyBtn.disabled = true;
        verifyBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span> Verifying...';
    }

    showResult('Verifying Pass ID...', 'warning');
    currentVisitor = null;

    console.log("About to call findVisitorByPassId with:", passId);

    findVisitorByPassId(passId)
        .then(visitor => {
            console.log("findVisitorByPassId resolved successfully:", visitor);
            currentVisitor = visitor;
            displayVisitorDetails(visitor);
            showResult('', '');
        })
        .catch(error => {
            console.error("findVisitorByPassId rejected with error:", error);
            showResult(error.message || 'Visitor not found', 'error');
        })
        .finally(() => {
            // Re-enable verify button
            if (verifyBtn) {
                verifyBtn.disabled = false;
                verifyBtn.innerHTML = 'Verify';
            }
        });
}

// Enhanced fetch visitor details with comprehensive debugging
function findVisitorByPassId(passId) {
    console.log('=== Find Visitor By Pass ID ===');
    console.log('Input Pass ID:', passId);
    
    const url = `SecurityServlet?action=visitorDetails&passId=${encodeURIComponent(passId)}`;
    console.log('Request URL:', url);
    
    return fetch(url)
        .then(response => {
            console.log('=== Fetch Response Details ===');
            console.log('Response status:', response.status);
            console.log('Response statusText:', response.statusText);
            console.log('Response ok:', response.ok);
            console.log('Response headers:', response.headers);
            console.log('Response content-type:', response.headers.get('content-type'));
            
            if (!response.ok) {
                throw new Error(`Network response was not ok: ${response.status} ${response.statusText}`);
            }
            
            return response.text(); // Get as text first for debugging
        })
        .then(text => {
            console.log('=== Raw Response Processing ===');
            console.log('Raw response text length:', text.length);
            console.log('Raw response text:', text);

            if (!text || text.trim().length === 0) {
                throw new Error('Empty response from server');
            }

            let data;
            try {
                data = JSON.parse(text);
                console.log('=== Parsed JSON Response ===');
                console.log('Parsed JSON:', data);
            } catch (parseError) {
                console.error('JSON Parse Error:', parseError);
                console.log('Failed to parse text:', text);
                throw new Error(`Invalid JSON response from server: ${parseError.message}`);
            }

            // Enhanced response validation
            console.log('=== Response Validation ===');
            console.log('data.status:', data.status);
            console.log('data.visitor:', data.visitor);
            console.log('data.message:', data.message);

            if (data.status === 'success' && data.visitor) {
                console.log('Success - returning visitor:', data.visitor);
                return data.visitor;
            } else if (data.status === 'error') {
                console.log('Server returned error:', data.message);
                throw new Error(data.message || "Server error occurred");
            } else {
                console.log('Unexpected response format');
                throw new Error(data.message || "Visitor not found or invalid response format");
            }
        }) 
        .catch(error => {
            console.error('=== Error in findVisitorByPassId ===');
            console.error('Error type:', error.constructor.name);
            console.error('Error message:', error.message);
            console.error('Error stack:', error.stack);
            throw error; // Re-throw to propagate to processPassId
        });     
}

// Enhanced displayVisitorDetails function with better error handling
function displayVisitorDetails(visitor) {
    console.log("=== Displaying Visitor Details ===");
    console.log("Visitor Data:", visitor);

    if (!visitor) {
        console.error("No visitor data provided");
        showResult('Invalid visitor data received', 'error');
        return;
    }

    try {
        currentVisitor = visitor;

        // Check if all required elements exist
        const requiredElements = {
            modalName: 'modalName',
            modalMobile: 'modalMobile',
            modalWhom: 'modalWhom',
            modalVisitDate: 'modalVisitDate',
            vehicleType: 'vehicleType',
            vehicleNumber: 'vehicleNumber',
            vehicleTypeWrapper: 'vehicleTypeWrapper',
            vehicleNumberWrapper: 'vehicleNumberWrapper',
            confirmBtn: 'Confirm',
            modal: 'visitorVerifiedModal'
        };

        // IMPORTANT: Make denyBtn required so we can control it properly
        const requiredElements2 = {
            denyBtn: 'denyEntryBtn'  // Make sure this ID matches your JSP
        };

        // Validate required elements exist
        const missingElements = [];
        const elements = {};

        for (const [key, id] of Object.entries(requiredElements)) {
            const element = document.getElementById(id);
            if (!element) {
                missingElements.push(id);
            } else {
                elements[key] = element;
            }
        }

        // Add deny button - CRITICAL: Find it by the correct ID
        const denyButton = document.querySelector('#visitorVerifiedModal .btn-danger') || 
                          document.getElementById('denyEntryBtn') ||
                          document.querySelector('[onclick*="processExit"]');
        
        if (denyButton) {
            elements.denyBtn = denyButton;
            console.log('Deny button found:', denyButton);
        } else {
            console.warn('Deny button not found - will create if needed');
        }

        if (missingElements.length > 0) {
            console.error('Missing required elements:', missingElements);
            showResult('Page error: Please refresh the page and try again.', 'error');
            return;
        }

        // Set basic visitor details with fallbacks
        elements.modalName.textContent = visitor.name || 'N/A';
        elements.modalWhom.textContent = visitor.whom || 'N/A';
        elements.modalMobile.textContent = visitor.mobile || 'N/A';
        elements.modalVisitDate.textContent = visitor.visitDate || visitor.date || 'N/A';

        // Show vehicle type wrapper first
        elements.vehicleTypeWrapper.style.display = 'block';
        elements.vehicleNumberWrapper.style.display = 'block';

        // Set vehicle inputs
        elements.vehicleType.value = visitor.vehicleType || '';
        elements.vehicleNumber.value = visitor.vehicleNumber || '';
		
		const vehicleNum = visitor.vehicleNumber;
		if (vehicleNum && vehicleNum !== 'N/A' && vehicleNum !== '-' && vehicleNum.trim() !== '') {
		    elements.vehicleNumber.value = vehicleNum;
		} else {
		    elements.vehicleNumber.value = '';
		}

        // CRITICAL: Always start by hiding the deny button, then show only when appropriate
        if (elements.denyBtn) {
            elements.denyBtn.style.display = 'none';
            elements.denyBtn.disabled = true;
        }

        // Set up modal button logic based on visitor status
        const status = visitor.visitStatus || visitor.status || 'Generated';
        console.log('Processing visitor status:', status);

        // Normalize status for comparison (handle case variations)
        const normalizedStatus = status.toString().toLowerCase().trim();

        switch (normalizedStatus) {
            case '2':
            case 'generated':
            case 'pending':
                console.log('Setting up ENTRY mode - deny button should be visible');
                setupEntryMode(elements, visitor);
                break;
                
            case '1':
            case 'inside':
            case 'checked in':
                console.log('Setting up EXIT mode - deny button should be HIDDEN');
                setupExitMode(elements);
                break;
                
            case '3':
            case 'ready for checkout':
            case 'host completed':
            case 'done by host':
                console.log('Setting up HOST COMPLETED mode - deny button should be HIDDEN');
                setupHostCompletedMode(elements);
                break;    

            case '0':    
            case 'checked out':
            case 'completed':
                console.log('Setting up COMPLETED mode - deny button should be HIDDEN');
                setupCompletedMode(elements);
                break;

            default:
                console.warn('Unknown visitor status:', status);
                setupInvalidMode(elements, status);
        }
        
        // FINAL CHECK: Log the deny button visibility
        if (elements.denyBtn) {
            console.log('Final deny button state:', {
                display: elements.denyBtn.style.display,
                disabled: elements.denyBtn.disabled,
                visible: elements.denyBtn.style.display !== 'none'
            });
        }
        
        // Show modal with animation
        console.log('About to show modal...');
        const modal = new bootstrap.Modal(elements.modal, {
            backdrop: 'static', // Prevent closing by clicking outside
            keyboard: true
        });
        
        modal.show();
        
        console.log('Modal displayed successfully for status:', status);

    } catch (error) {
        console.error('Error in displayVisitorDetails:', error);
        showResult('Error displaying visitor details. Please try again.', 'error');
    }
}

// New function to handle final checkout (status 3 → status 0)
function processFinalCheckout() {
    if (!currentVisitor || !currentVisitor.passId) {
        showResult('No visitor data available', 'error');
        return;
    }

    console.log("=== Process Final Checkout ===");
    console.log("Current Visitor:", currentVisitor);

    showResult('Processing final checkout...', 'warning');
    
    const confirmBtn = document.getElementById('Confirm');
    const originalText = confirmBtn.textContent;
    confirmBtn.disabled = true;
    confirmBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span> Processing...';

    const params = new URLSearchParams();
    params.append('action', 'processFinalCheckout');
    params.append('passId', currentVisitor.passId);

    fetch('SecurityServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => {
        console.log('Final Checkout Response Status:', response.status);
        console.log('Final Checkout Response OK:', response.ok);
        
        if (!response.ok) {
            throw new Error(`HTTP error ${response.status}`);
        }
        
        return response.text();
    })
    .then(text => {
        console.log('Final Checkout Raw Response Text:', text);
        
        if (!text || text.trim().length === 0) {
            throw new Error('Empty response from server');
        }
        
        let data;
        try {
            data = JSON.parse(text);
        } catch (e) {
            console.error('JSON Parse Error:', e);
            throw new Error(`Invalid JSON response: ${text.substring(0, 100)}`);
        }
        
        console.log('Final Checkout Parsed Response:', data);
        
        const isSuccess = data && (
            data.status === 'success' || 
            data.status === 'Success' || 
            (data.message && data.message.toLowerCase().includes('success'))
        );
        
        if (isSuccess) {
            showResult(`${currentVisitor.name} has been finally checked out successfully`, 'success');
            setTimeout(() => {
                const modal = bootstrap.Modal.getInstance(document.getElementById('visitorVerifiedModal'));
                if (modal) modal.hide();
                clearForm();
                updateStatistics();
                loadTodaysVisitors();
            }, 2000);
        } else {
            const errorMessage = data ? (data.message || data.error || 'Final checkout failed') : 'Unknown error occurred';
            showResult(errorMessage, 'error');
            confirmBtn.disabled = false;
            confirmBtn.textContent = originalText;
        }
    })
    .catch(error => {
        console.error('Final Checkout Error:', error);
        showResult(`Error: ${error.message}`, 'error');
        confirmBtn.disabled = false;
        confirmBtn.textContent = originalText;
    });
}

// Helper functions for setting up different modes - FIXED VERSION
function setupEntryMode(elements, visitor) {
    processingAction = 'entry';
    elements.confirmBtn.textContent = 'Confirm Entry';
    elements.confirmBtn.className = 'btn btn-success';
    elements.confirmBtn.onclick = confirmEntry;
    elements.confirmBtn.disabled = false;
    
    // Show vehicle type selection for entry
    elements.vehicleTypeWrapper.style.display = 'block';
    elements.vehicleNumberWrapper.style.display = 'block';
    
    // ONLY show deny entry button for Generated status (entry mode)
    if (elements.denyBtn) {
        elements.denyBtn.style.display = 'inline-block';
        elements.denyBtn.disabled = false;
        elements.denyBtn.textContent = 'Deny Entry';
        elements.denyBtn.className = 'btn btn-danger';
    }
    
    console.log('Setup Entry Mode - Deny button should be visible');
}

function setupExitMode(elements) {
    processingAction = 'exit';
    elements.confirmBtn.textContent = 'Confirm Exit';
    elements.confirmBtn.className = 'btn btn-warning';
    elements.confirmBtn.onclick = processExit;
    elements.confirmBtn.disabled = false;
    
    // Hide vehicle sections for exit
    elements.vehicleTypeWrapper.style.display = 'none';
    elements.vehicleNumberWrapper.style.display = 'none';
    
    // CRITICAL: Hide deny entry button for exit mode (Inside status)
    if (elements.denyBtn) {
        elements.denyBtn.style.display = 'none';
        elements.denyBtn.disabled = true;
    }
    
    console.log('Setup Exit Mode - Deny button should be hidden');
}

function setupHostCompletedMode(elements) {
    processingAction = 'final_checkout';
    elements.confirmBtn.textContent = 'Final Checkout';
    elements.confirmBtn.className = 'btn btn-warning';
    elements.confirmBtn.onclick = processFinalCheckout;
    elements.confirmBtn.disabled = false;
    
    // Hide vehicle sections for final checkout
    elements.vehicleTypeWrapper.style.display = 'none';
    elements.vehicleNumberWrapper.style.display = 'none';
    
    // CRITICAL: Hide deny entry button for host completed mode (Ready for Checkout status)
    if (elements.denyBtn) {
        elements.denyBtn.style.display = 'none';
        elements.denyBtn.disabled = true;
    }
    
    console.log('Setup Host Completed Mode - Deny button should be hidden');
}

function setupCompletedMode(elements) {
    elements.confirmBtn.textContent = 'Already Checked Out';
    elements.confirmBtn.className = 'btn btn-secondary';
    elements.confirmBtn.disabled = true;
    processingAction = null;
    
    // Hide vehicle sections
    elements.vehicleTypeWrapper.style.display = 'none';
    elements.vehicleNumberWrapper.style.display = 'none';
    
    // CRITICAL: Hide deny entry button for completed mode (Checked Out status)
    if (elements.denyBtn) {
        elements.denyBtn.style.display = 'none';
        elements.denyBtn.disabled = true;
    }
    
    console.log('Setup Completed Mode - Deny button should be hidden');
}

function setupInvalidMode(elements, status) {
    elements.confirmBtn.textContent = `Invalid Status: ${status}`;
    elements.confirmBtn.className = 'btn btn-danger';
    elements.confirmBtn.disabled = true;
    processingAction = null;
    
    // Hide vehicle sections
    elements.vehicleTypeWrapper.style.display = 'none';
    elements.vehicleNumberWrapper.style.display = 'none';
    
    // CRITICAL: Hide deny entry button for invalid mode
    if (elements.denyBtn) {
        elements.denyBtn.style.display = 'none';
        elements.denyBtn.disabled = true;
    }
    
    console.log('Setup Invalid Mode - Deny button should be hidden');
}

// Clear form and reset state
function clearForm() {
    const passIdInput = document.getElementById('passIdInput');
    const vehicleType = document.getElementById('vehicleType');
    const vehicleNumber = document.getElementById('vehicleNumber');
    
    if (passIdInput) passIdInput.value = '';
    if (vehicleType) vehicleType.value = '';
    if (vehicleNumber) vehicleNumber.value = '';

    // Reset vehicle sections
    const vehicleTypeWrapper = document.getElementById('vehicleTypeWrapper');
    const vehicleNumberWrapper = document.getElementById('vehicleNumberWrapper');
    if (vehicleTypeWrapper) vehicleTypeWrapper.style.display = 'none';
    if (vehicleNumberWrapper) vehicleNumberWrapper.style.display = 'none';

    const confirmBtn = document.getElementById('Confirm');
    if (confirmBtn) {
        confirmBtn.onclick = confirmEntry;
        confirmBtn.textContent = 'Confirm Entry';
        confirmBtn.className = 'btn btn-success';
        confirmBtn.disabled = false;
    }

    currentVisitor = null;
    processingAction = null;
    
    if (passIdInput) passIdInput.focus();
}

// Show result message
function showResult(message, type) {
    const resultDiv = document.getElementById('scanResult');
    if (resultDiv) {
        if (message) {
            resultDiv.innerHTML = `<div class="result-${type}">${message}</div>`;
        } else {
            resultDiv.innerHTML = '';
        }
    } else {
        console.error('scanResult element not found');
    }
}

// Enhanced confirmEntry with better response handling
function confirmEntry() {
    console.log("=== Confirm Entry Process ===");
    console.log("Current Visitor:", currentVisitor);
    
    if (!currentVisitor || !currentVisitor.passId) {
        console.error("Missing passId in currentVisitor!");
        showResult('Missing Pass ID. Please try again.', 'error');
        return;
    }

    const vehicleType = document.getElementById('vehicleType').value || '';
    const vehicleNumber = document.getElementById('vehicleNumber').value || '';

    // Validate vehicle number if vehicle type is selected
    if ((vehicleType === 'Personal Vehicle' || vehicleType === 'Mahyco Vehicle') && !vehicleNumber.trim()) {
        showResult('Please enter vehicle number for selected vehicle type', 'error');
        return;
    }

    console.log('Entry data:', { vehicleType, vehicleNumber });

    showResult('Processing entry...', 'warning');
    
    const confirmBtn = document.getElementById('Confirm');
    const originalText = confirmBtn.textContent;
    confirmBtn.disabled = true;
    confirmBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span> Processing...';

    const params = new URLSearchParams();
    params.append('action', 'processEntry');
    params.append('passId', currentVisitor.passId);
    params.append('vehicleType', vehicleType);
    params.append('vehicleNumber', vehicleNumber);

    fetch('SecurityServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => {
        console.log('Entry Response Status:', response.status);
        console.log('Entry Response OK:', response.ok);
        
        if (!response.ok) {
            throw new Error(`HTTP error ${response.status}`);
        }
        
        return response.text();
    })
    .then(text => {
        console.log('Entry Raw Response Text:', text);
        
        if (!text || text.trim().length === 0) {
            throw new Error('Empty response from server');
        }
        
        let data;
        try {
            data = JSON.parse(text);
        } catch (e) {
            console.error('JSON Parse Error:', e);
            throw new Error(`Invalid JSON response: ${text.substring(0, 100)}`);
        }
        
        console.log('Entry Parsed Response:', data);
        
        // Check for success in multiple ways
        const isSuccess = data && (
            data.status === 'success' || 
            data.status === 'Success' || 
            (data.message && data.message.toLowerCase().includes('success')) ||
            !data.message || // If no error message, assume success
            data.message === 'Visitor entry processed successfully'
        );
        
        if (isSuccess) {
            showResult(`${currentVisitor.name} has been checked in successfully`, 'success');
            setTimeout(() => {
                const modal = bootstrap.Modal.getInstance(document.getElementById('visitorVerifiedModal'));
                if (modal) modal.hide();
                clearForm();
                updateStatistics();
                loadTodaysVisitors();
            }, 2000);
        } else {
            const errorMessage = data ? (data.message || data.error || 'Operation failed') : 'Unknown error occurred';
            showResult(errorMessage, 'error');
            confirmBtn.disabled = false;
            confirmBtn.textContent = originalText;
        }
    })
    .catch(error => {
        console.error('Entry Fetch Error:', error);
        showResult(`Error: ${error.message}`, 'error');
        confirmBtn.disabled = false;
        confirmBtn.textContent = originalText;
    });
}

// Enhanced processExit function - no error messages for normal scenarios
function processExit() {
    if (!currentVisitor || !currentVisitor.passId) {
        showResult('No visitor data available', 'error');
        return;
    }

    console.log("=== Process Exit ===");
    console.log("Current Visitor:", currentVisitor);

    showResult('Processing exit...', 'warning');
    
    const confirmBtn = document.getElementById('Confirm');
    const originalText = confirmBtn.textContent;
    confirmBtn.disabled = true;
    confirmBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span> Processing...';

    const params = new URLSearchParams();
    params.append('action', 'processExit');
    params.append('passId', currentVisitor.passId);

    fetch('SecurityServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => {
        console.log('Exit Response Status:', response.status);
        console.log('Exit Response OK:', response.ok);
        
        if (!response.ok) {
            throw new Error(`HTTP error ${response.status}`);
        }
        
        return response.text();
    })
    .then(text => {
        console.log('Exit Raw Response Text:', text);
        
        if (!text || text.trim().length === 0) {
            throw new Error('Empty response from server');
        }
        
        let data;
        try {
            data = JSON.parse(text);
        } catch (e) {
            console.error('JSON Parse Error:', e);
            throw new Error(`Invalid JSON response: ${text.substring(0, 100)}`);
        }
        
        console.log('Exit Parsed Response:', data);
        
        // Check for success in multiple ways
        const isSuccess = data && (
            data.status === 'success' || 
            data.status === 'Success' || 
            (data.message && data.message.toLowerCase().includes('success')) ||
            !data.message || // If no error message, assume success
            data.message === 'Visitor exit processed successfully'
        );
        
        if (isSuccess) {
            showResult(`${currentVisitor.name} has been checked out successfully`, 'success');
            setTimeout(() => {
                const modal = bootstrap.Modal.getInstance(document.getElementById('visitorVerifiedModal'));
                if (modal) modal.hide();
                clearForm();
                updateStatistics();
                loadTodaysVisitors();
            }, 2000);
        } else {
            // For exit, we'll be more lenient - just close modal and refresh
            console.log('Exit processing completed - closing modal');
            const modal = bootstrap.Modal.getInstance(document.getElementById('visitorVerifiedModal'));
            if (modal) modal.hide();
            clearForm();
            updateStatistics();
            loadTodaysVisitors();
        }
    })
    .catch(error => {
        console.error('Exit Processing Error:', error);
        // Only show error for actual technical failures, not business logic
        if (error.message.includes('HTTP error') || error.message.includes('Empty response')) {
            showResult(`Technical error: ${error.message}`, 'error');
        } else {
            // For other errors, just close modal silently
            const modal = bootstrap.Modal.getInstance(document.getElementById('visitorVerifiedModal'));
            if (modal) modal.hide();
            clearForm();
            updateStatistics();
            loadTodaysVisitors();
        }
        confirmBtn.disabled = false;
        confirmBtn.textContent = originalText;
    });
}

// Enhanced handleCheckout function
function handleCheckout(passId) {
    if (!confirm(`Are you sure you want to checkout Pass ID: ${passId}?`)) return;

    console.log('=== Handle Checkout ===');
    console.log('Pass ID:', passId);

    const params = new URLSearchParams();
    params.append('action', 'checkout');
    params.append('passId', passId);

    fetch('SecurityServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => {
        console.log('Checkout Response Status:', response.status);
        console.log('Checkout Response OK:', response.ok);
        
        if (!response.ok) {
            throw new Error(`HTTP error ${response.status}`);
        }
        
        return response.text();
    })
    .then(text => {
        console.log('Checkout Raw Response Text:', text);
        
        if (!text || text.trim().length === 0) {
            throw new Error('Empty response from server');
        }
        
        let result;
        try {
            result = JSON.parse(text);
        } catch (e) {
            console.error('JSON Parse Error:', e);
            throw new Error(`Invalid JSON response: ${text.substring(0, 100)}`);
        }
        
        console.log('Checkout Parsed Response:', result);
        
        // Enhanced status checking - handle multiple possible success indicators
        const isSuccess = result && (
            result.status === 'success' || 
            result.status === 'Success' || 
            (result.message && result.message.toLowerCase().includes('success'))
        );
        
        if (isSuccess) {
            // Show success message briefly
            showResult('Checkout successful!', 'success');
            setTimeout(() => showResult('', ''), 2000);
            
            updateStatistics();
            loadTodaysVisitors(); // Refresh the table
        } else {
            // Don't show error alerts - just refresh the data silently
            console.log('Checkout completed - refreshing data');
            updateStatistics();
            loadTodaysVisitors();
        }
    })
    .catch(error => {
        console.error('Checkout Error:', error);
        // Only show error for actual technical failures
        if (error.message.includes('HTTP error') || error.message.includes('Empty response')) {
            showResult(`Technical error: ${error.message}`, 'error');
            setTimeout(() => showResult('', ''), 3000);
        } else {
            // For other errors, just refresh data silently
            console.log('Checkout processing completed - refreshing data');
            updateStatistics();
            loadTodaysVisitors();
        }
    });
}

// Clear form and reset state
function clearForm() {
    document.getElementById('passIdInput').value = '';
    document.getElementById('vehicleType').value = '';
    document.getElementById('vehicleNumber').value = '';

    // Reset vehicle sections
    const vehicleTypeWrapper = document.getElementById('vehicleTypeWrapper');
    const vehicleNumberWrapper = document.getElementById('vehicleNumberWrapper');
    if (vehicleTypeWrapper) vehicleTypeWrapper.style.display = 'none';
    if (vehicleNumberWrapper) vehicleNumberWrapper.style.display = 'none';

    const confirmBtn = document.getElementById('Confirm');
    if (confirmBtn) {
        confirmBtn.onclick = confirmEntry;
        confirmBtn.textContent = 'Confirm Entry';
        confirmBtn.className = 'btn btn-success';
        confirmBtn.disabled = false;
    }

    currentVisitor = null;
    processingAction = null;
    document.getElementById('passIdInput').focus();
}

// Show result message
function showResult(message, type) {
    const resultDiv = document.getElementById('scanResult');
    if (message) {
        resultDiv.innerHTML = `<div class="result-${type}">${message}</div>`;
    } else {
        resultDiv.innerHTML = '';
    }
}

// Debug function to test the connection
function debugConnection() {
    console.log('=== Debug Connection Test ===');
    
    fetch('SecurityServlet?action=test')
        .then(response => {
            console.log('Test response status:', response.status);
            return response.text();
        })
        .then(text => {
            console.log('Test response:', text);
        })
        .catch(error => {
            console.error('Connection test failed:', error);
        });
}

// Process manual entry
async function processManualEntry() {
    const name = document.getElementById('manualName').value.trim();
    const mobile = document.getElementById('manualMobile').value.trim();
    const whom = document.getElementById('manualWhom').value.trim();
    const purpose = document.getElementById('manualPurpose').value.trim();
    const vehicleType = document.getElementById('manualVehicleType').value.trim();
    const vehicleNumber = document.getElementById('manualVehicleNumber').value.trim();

    const resultDiv = document.getElementById('manualEntryResult');
    resultDiv.style.display = 'none';

    // Validation
    if (!name || !mobile || !whom || !purpose) {
        showManualEntryResult('Please fill all required fields (Name, Mobile, Person to Meet, Purpose)', 'error');
        return;
    }

    // Mobile number validation
    const mobilePattern = /^[6-9]\d{9}$/;
    if (!mobilePattern.test(mobile)) {
        showManualEntryResult('Please enter a valid 10-digit mobile number', 'error');
        return;
    }

    const entryButton = document.querySelector('#manualEntryModal .btn-success');
    entryButton.disabled = true;
    entryButton.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Processing...';

    try {
        const params = new URLSearchParams();
        params.append('action', 'manualEntry');
        params.append('name', name);
        params.append('mobile', mobile);
        params.append('whom', whom);
        params.append('purpose', purpose);
        params.append('vehicleType', vehicleType);
        params.append('vehicleNumber', vehicleNumber);

        const response = await fetch('SecurityServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params
        });

        const text = await response.text();
        console.log('Manual Entry Raw Response:', text);
        
        const data = JSON.parse(text);
        console.log('Manual Entry Parsed Response:', data);

        // Enhanced status checking - handle multiple possible success indicators
        const isSuccess = data && (
            data.status === 'success' || 
            data.status === 'Success' || 
            (data.message && data.message.toLowerCase().includes('success'))
        );

        if (isSuccess) {
            showManualEntryResult(`Entry successful! Pass ID: ${data.passId || 'Generated'}`, 'success');
            setTimeout(() => {
                clearManualEntry();
                bootstrap.Modal.getInstance(document.getElementById('manualEntryModal')).hide();
                updateStatistics();
                loadTodaysVisitors();
            }, 2000);
        } else {
            const errorMessage = data ? (data.message || data.error || 'Manual entry failed') : 'Unknown error occurred';
            showManualEntryResult(errorMessage, 'error');
        }
    } catch (error) {
        console.error('Manual Entry Error:', error);
        let errorMsg = 'Network error. Please try again.';
        if (error.message.includes("Action parameter")) {
            errorMsg = "System configuration error - please contact admin";
        }
        showManualEntryResult(errorMsg, 'error');
    } finally {
        entryButton.disabled = false;
        entryButton.textContent = 'Process Entry';
    }
}
// Show manual entry result
function showManualEntryResult(message, type) {
    const resultDiv = document.getElementById('manualEntryResult');
    resultDiv.innerHTML = `<div class="result-${type}">${message}</div>`;
    resultDiv.style.display = 'block';
}

// Clear manual entry form
function clearManualEntry() {
    document.getElementById('manualName').value = '';
    document.getElementById('manualMobile').value = '';
    document.getElementById('manualWhom').value = '';
    document.getElementById('manualPurpose').value = '';
    document.getElementById('manualVehicleType').value = '';
    document.getElementById('manualVehicleNumber').value = '';
    document.getElementById('manualEntryResult').style.display = 'none';
}

// Update statistics
function updateStatistics() {
    console.log('Updating statistics...');
    
    fetch('SecurityServlet?action=statistics')
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('Statistics received:', data);
            
            if (data.status !== 'error') {
                // Update existing counters
                const totalPendingEl = document.getElementById('totalPending');
                const totalInEl = document.getElementById('totalIn');
                const totalOutEl = document.getElementById('totalOut');
                const totalVisitorsEl = document.getElementById('totalVisitors');
                
                if (totalPendingEl) totalPendingEl.textContent = data.pending || 0;
                if (totalInEl) totalInEl.textContent = data.inside || 0;
                if (totalOutEl) totalOutEl.textContent = data.checkedOut || 0;
                if (totalVisitorsEl) totalVisitorsEl.textContent = data.total || 0;
                
                // NEW: Add counter for "Ready for Checkout" if element exists
                const readyForCheckoutEl = document.getElementById('totalReadyForCheckout');
                if (readyForCheckoutEl) {
                    readyForCheckoutEl.textContent = data.readyForCheckout || 0;
                }
                
                console.log('Statistics updated successfully');
            } else {
                console.error('Statistics error:', data.message);
                showResult('Error loading statistics: ' + data.message, 'error');
            }
        })
        .catch(error => {
            console.error('Error fetching statistics:', error);
            showResult('Error loading statistics. Please refresh the page.', 'error');
        });
}


// Enhanced status badge function to handle all 4 statuses consistently
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
            return '<span class="badge bg-primary">Pass Generated</span>';
        case '3':
        case 'ready for checkout':
        case 'host completed':
            return '<span class="badge bg-warning text-dark">Ready for Checkout</span>';
        default:
            return '<span class="badge bg-light text-dark">Unknown</span>';
    }
}

// Enhanced action button function for security operations
function getActionButton(visitor) {
    const status = visitor.status ? visitor.status.toString().toLowerCase().trim() : '';
    let buttons = '';
    
    switch (status) {
        case '2':
        case 'generated':
        case 'pending':
            // Allow manual check-in for generated passes
            buttons = `<button class="btn btn-sm btn-success" 
                onclick="processDirectEntry('${visitor.passId}')">
                Check In
            </button>`;
            break;
            
        case '1':
        case 'inside':
            // Allow checkout for visitors inside
            buttons = `<button class="btn btn-sm btn-warning" 
                onclick="handleCheckout('${visitor.passId}')">
                Check Out
            </button>`;
            break;
            
        case '3':
        case 'ready for checkout':
        case 'host completed':
            // Allow final checkout for host-completed visits
            buttons = `<button class="btn btn-sm btn-danger" 
                onclick="processFinalCheckoutFromTable('${visitor.passId}')">
                Final Checkout
            </button>`;
            break;
            
        case '0':
        case 'checked out':
        case 'completed':
            buttons = '<span class="badge bg-secondary">Completed</span>';
            break;
            
        default:
            buttons = '<span class="text-muted">No Action</span>';
    }
    
    return buttons;
}

// New function to handle direct entry from table
function processDirectEntry(passId) {
    if (!confirm(`Check in visitor with Pass ID: ${passId}?`)) {
        return;
    }
    
    console.log('Processing direct entry for:', passId);
    
    const params = new URLSearchParams();
    params.append('action', 'processEntry');
    params.append('passId', passId);
    params.append('vehicleType', ''); // Default empty
    params.append('vehicleNumber', ''); // Default empty
    
    fetch('SecurityServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            showResult('Visitor checked in successfully!', 'success');
            updateStatistics();
            loadTodaysVisitors();
        } else {
            showResult(data.message || 'Check-in failed', 'error');
        }
    })
    .catch(error => {
        console.error('Check-in error:', error);
        showResult('Error during check-in: ' + error.message, 'error');
    });
}

// New function to handle final checkout from table
function processFinalCheckoutFromTable(passId) {
    if (!confirm(`Perform final checkout for Pass ID: ${passId}?\n\nThis will mark the visit as completely finished.`)) {
        return;
    }
    
    console.log('Processing final checkout from table for:', passId);
    
    const params = new URLSearchParams();
    params.append('action', 'processFinalCheckout');
    params.append('passId', passId);
    
    fetch('SecurityServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error ${response.status}`);
        }
        return response.text();
    })
    .then(text => {
        let data;
        try {
            data = JSON.parse(text);
        } catch (e) {
            throw new Error(`Invalid JSON response: ${text.substring(0, 100)}`);
        }
        
        console.log('Final checkout response:', data);
        
        const isSuccess = data && (
            data.status === 'success' || 
            data.status === 'Success' || 
            (data.message && data.message.toLowerCase().includes('success'))
        );
        
        if (isSuccess) {
            showResult('Final checkout completed successfully!', 'success');
            setTimeout(() => showResult('', ''), 2000);
        } else {
            // Don't show error - just refresh data
            console.log('Final checkout completed - refreshing data');
        }
        
        updateStatistics();
        loadTodaysVisitors();
    })
    .catch(error => {
        console.error('Final checkout error:', error);
        // Only show error for technical failures
        if (error.message.includes('HTTP error') || error.message.includes('Empty response')) {
            showResult(`Technical error: ${error.message}`, 'error');
            setTimeout(() => showResult('', ''), 3000);
        } else {
            // Just refresh data silently
            updateStatistics();
            loadTodaysVisitors();
        }
    });
}
// FIXED: Load today's visitors with better error handling
function loadTodaysVisitors() {
    const tbody = document.getElementById('securityTableBody');
    
    // Check if tbody exists before proceeding
    if (!tbody) {
        console.error('securityTableBody element not found');
        return;
    }
    
    tbody.innerHTML = '<tr><td colspan="10" class="text-center">Loading...</td></tr>';

    fetch('SecurityServlet?action=todaysVisitors')
        .then(response => {
            console.log('LoadTodaysVisitors Response Status:', response.status);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            return response.text();
        })
        .then(text => {
            console.log('LoadTodaysVisitors Raw Response Text:', text);
            
            if (!text || text.trim().length === 0) {
                throw new Error('Empty response from server');
            }
            
            let data;
            try {
                data = JSON.parse(text);
                console.log('LoadTodaysVisitors Parsed JSON:', data);
            } catch (jsonError) {
                console.error('LoadTodaysVisitors JSON Parse Error:', jsonError);
                throw new Error(`Invalid JSON response from server`);
            }
            
            // Handle different response formats
            if (Array.isArray(data)) {
                displayVisitorsTable(data);
            } else if (data && data.status === 'success' && Array.isArray(data.visitors)) {
                displayVisitorsTable(data.visitors);
            } else if (data && data.status === 'error') {
                // Check if tbody still exists before updating
                const currentTbody = document.getElementById('securityTableBody');
                if (currentTbody) {
                    currentTbody.innerHTML = `<tr><td colspan="10" class="text-center text-danger">Server Error: ${data.message || 'Unknown error'}</td></tr>`;
                }
            } else {
                console.error('LoadTodaysVisitors Unexpected data format:', data);
                const currentTbody = document.getElementById('securityTableBody');
                if (currentTbody) {
                    currentTbody.innerHTML = '<tr><td colspan="10" class="text-center text-danger">Invalid visitor data format received</td></tr>';
                }
            }
        })
        .catch(error => {
            console.error('LoadTodaysVisitors Fetch Error:', error);
            // Check if tbody still exists before updating
            const currentTbody = document.getElementById('securityTableBody');
            if (currentTbody) {
                currentTbody.innerHTML = `<tr><td colspan="10" class="text-center text-danger">Error loading data: ${error.message}</td></tr>`;
            }
        });
}

// FIXED: Display visitors in table with proper column count and NO direct check-in
function displayVisitorsTable(visitors) {
    const tableId = '#securityTable';
    const tbody = document.getElementById('securityTableBody');
    
    if (!tbody) {
        console.error('securityTableBody element not found');
        return;
    }
    
    if (!document.getElementById('securityTable')) {
        console.error('securityTable element not found');
        return;
    }

    try {
        // Destroy existing DataTable instance safely
        if ($.fn.DataTable.isDataTable(tableId)) {
            console.log('Destroying existing DataTable...');
            $(tableId).DataTable().clear().destroy();
            console.log('DataTable destroyed successfully');
        }
    } catch (destroyError) {
        console.error('Error destroying DataTable:', destroyError);
        try {
            $(tableId).empty();
        } catch (clearError) {
            console.error('Error clearing table:', clearError);
        }
    }

    // Clear existing rows
    tbody.innerHTML = '';

    if (!visitors || visitors.length === 0) {
        const row = tbody.insertRow();
        const cell = row.insertCell(0);
        cell.colSpan = 10;
        cell.className = 'text-center';
        cell.textContent = 'No visitors found';
    } else {
        visitors.forEach((visitor, index) => {
            try {
                console.log(`Processing visitor ${index + 1}:`, visitor);
                
                const row = tbody.insertRow();
                
                // Insert basic cells
                row.insertCell(0).textContent = visitor.passId || 'N/A';
                row.insertCell(1).textContent = visitor.name || 'N/A';
                row.insertCell(2).textContent = visitor.mobile || 'N/A';
                row.insertCell(3).textContent = visitor.whom || 'N/A';
                row.insertCell(4).textContent = visitor.purpose || 'N/A';
                row.insertCell(5).textContent = visitor.vehicleType || 'None';
                row.insertCell(6).textContent = visitor.vehicleNumber || 'N/A';
                row.insertCell(7).textContent = visitor.inTime || 'N/A';
                row.insertCell(8).textContent = visitor.outTime || 'N/A';
                
                // FIXED: Status/action cell - REMOVED direct check-in for Generated status
                const actionCell = row.insertCell(9);
                const visitorStatus = visitor.status ? visitor.status.toLowerCase().trim() : '';
                
                console.log(`Visitor ${visitor.passId} status: ${visitorStatus}`);
                
                if (visitorStatus === 'generated' || visitorStatus === '2') {
                    // Status 2: Show status badge only - NO direct check-in button
                    const generatedSpan = document.createElement('span');
                    generatedSpan.className = 'badge bg-primary';
                    generatedSpan.textContent = 'Pass Generated';
                    actionCell.appendChild(generatedSpan);
                    
                } else if (visitorStatus === 'inside' || visitorStatus === '1') {
                    // Status 1: Allow regular checkout
                    const checkoutBtn = document.createElement('button');
                    checkoutBtn.className = 'btn btn-sm btn-warning';
                    checkoutBtn.textContent = 'Check Out';
                    checkoutBtn.onclick = () => handleCheckout(visitor.passId);
                    actionCell.appendChild(checkoutBtn);
                    
                } else if (visitorStatus === 'ready for checkout' || visitorStatus === '3') {
                    // Status 3: Allow final checkout
                    const finalCheckoutBtn = document.createElement('button');
                    finalCheckoutBtn.className = 'btn btn-sm btn-danger';
                    finalCheckoutBtn.textContent = 'Final Checkout';
                    finalCheckoutBtn.onclick = () => processFinalCheckoutFromTable(visitor.passId);
                    actionCell.appendChild(finalCheckoutBtn);
                    
                } else if (visitorStatus === 'checked out' || visitorStatus === '0') {
                    // Status 0: Completed
                    const completedSpan = document.createElement('span');
                    completedSpan.className = 'badge bg-secondary';
                    completedSpan.textContent = 'Completed';
                    actionCell.appendChild(completedSpan);
                    
                } else {
                    // Unknown status
                    const unknownSpan = document.createElement('span');
                    unknownSpan.className = 'text-muted';
                    unknownSpan.textContent = 'No Action';
                    actionCell.appendChild(unknownSpan);
                }
                
            } catch (rowError) {
                console.error(`Error processing visitor ${index + 1}:`, rowError);
            }
        });
    }

    // Initialize DataTable
    setTimeout(() => {
        try {
            if (!document.getElementById('securityTable')) {
                console.error('Table disappeared before DataTable initialization');
                return;
            }

            $(tableId).DataTable({
                pageLength: 10,
                lengthChange: false,
                ordering: false,
                info: true,
                autoWidth: false,
                responsive: true,
                destroy: true,
                language: {
                    emptyTable: "No visitors found"
                },
                columnDefs: [
                    { targets: '_all', className: 'text-center' },
                    { targets: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], orderable: false }
                ]
            });
            console.log('DataTable initialized successfully');
        } catch (dataTableError) {
            console.error('DataTable initialization error:', dataTableError);
        }
    }, 100);
}

// Manual refresh function for visitors table
function refreshVisitorsTable() {
    console.log('Manual refresh triggered');
    
    // Show loading state on refresh button
    const refreshBtn = document.querySelector('[onclick="refreshVisitorsTable()"]');
    const originalContent = refreshBtn.innerHTML;
    
    refreshBtn.disabled = true;
    refreshBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span>';
    
    // Refresh both statistics and visitors table
    Promise.all([
        new Promise(resolve => {
            updateStatistics();
            setTimeout(resolve, 500); // Small delay for statistics
        }),
        new Promise(resolve => {
            loadTodaysVisitors();
            setTimeout(resolve, 1000); // Delay for table load
        })
    ]).finally(() => {
        // Restore button state
        refreshBtn.disabled = false;
        refreshBtn.innerHTML = originalContent;
        
        // Show brief success feedback
        showResult('Data refreshed successfully', 'success');
        setTimeout(() => showResult('', ''), 2000);
    });
}

// Auto-refresh every 30 seconds
setInterval(function() {
    // Only refresh if the elements still exist on the page
    if (document.getElementById('securityTableBody') && document.getElementById('totalPending')) {
        updateStatistics();
        loadTodaysVisitors();
    } else {
        console.log('Page elements not found, skipping auto-refresh');
    }
}, 30000);