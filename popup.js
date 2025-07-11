// Popup script for 3x2 Window Movement Detector extension

document.addEventListener('DOMContentLoaded', function() {
    const statusIndicator = document.getElementById('statusIndicator');
    const statusText = document.getElementById('statusText');
    const positionDisplay = document.getElementById('positionDisplay');
    const movementLog = document.getElementById('logEntries');
    const getPositionBtn = document.getElementById('getPositionBtn');
    const startTrackingBtn = document.getElementById('startTrackingBtn');
    const stopTrackingBtn = document.getElementById('stopTrackingBtn');
    const clearLogBtn = document.getElementById('clearLogBtn');
    
    let currentTab = null;
    let windowDetectorAvailable = false;
    let isTracking = false;
    
    // Initialize popup
    init();
    
    function init() {
        // Get current tab
        chrome.tabs.query({active: true, currentWindow: true}, function(tabs) {
            currentTab = tabs[0];
            checkStatus();
        });
        
        // Set up event listeners
        getPositionBtn.addEventListener('click', getPosition);
        startTrackingBtn.addEventListener('click', startTracking);
        stopTrackingBtn.addEventListener('click', stopTracking);
        clearLogBtn.addEventListener('click', clearLog);
    }
    
    function checkStatus() {
        if (!currentTab) {
            updateStatus(false, 'No active tab');
            return;
        }
        
        // Check if we're on a supported site
        const supportedUrls = [
            'http://localhost:8000',
            'https://rebroad.github.io',
            'https://localhost:8000'
        ];
        
        const isSupported = supportedUrls.some(url => currentTab.url.startsWith(url));
        
        if (!isSupported) {
            updateStatus(false, 'Not on supported site');
            return;
        }
        
        // Check if window detector is available
        chrome.tabs.sendMessage(currentTab.id, {
            type: 'CHECK_STATUS'
        }, function(response) {
            if (chrome.runtime.lastError) {
                updateStatus(false, 'Extension not active');
            } else if (response && response.available) {
                updateStatus(true, 'Ready');
                windowDetectorAvailable = true;
                checkTrackingStatus();
            } else {
                updateStatus(false, 'Not available');
            }
        });
    }
    
    function checkTrackingStatus() {
        if (!currentTab || !windowDetectorAvailable) return;
        
        chrome.tabs.sendMessage(currentTab.id, {
            type: 'WINDOW_DETECTOR_REQUEST',
            action: 'GET_TRACKING_STATUS'
        }, function(response) {
            if (response && response.isTracking !== undefined) {
                isTracking = response.isTracking;
                updateTrackingButtons();
            }
        });
    }
    
    function updateStatus(available, text) {
        statusIndicator.className = 'status-indicator ' + (available ? 'active' : 'inactive');
        statusText.textContent = text;
        
        // Enable/disable buttons
        const buttons = [getPositionBtn, startTrackingBtn, stopTrackingBtn, clearLogBtn];
        buttons.forEach(btn => {
            btn.disabled = !available;
        });
    }
    
    function updateTrackingButtons() {
        startTrackingBtn.disabled = isTracking;
        stopTrackingBtn.disabled = !isTracking;
        startTrackingBtn.textContent = isTracking ? 'Tracking Active' : 'Start Tracking';
        stopTrackingBtn.textContent = isTracking ? 'Stop Tracking' : 'Not Tracking';
    }
    
    function getPosition() {
        if (!currentTab || !windowDetectorAvailable) return;
        
        chrome.tabs.sendMessage(currentTab.id, {
            type: 'WINDOW_DETECTOR_REQUEST',
            action: 'GET_POSITION'
        }, function(response) {
            if (response && response.x !== undefined && response.y !== undefined) {
                positionDisplay.textContent = `Position: (${response.x}, ${response.y})`;
            } else {
                positionDisplay.textContent = 'Position: Unknown';
            }
        });
    }
    
    function startTracking() {
        if (!currentTab || !windowDetectorAvailable) return;
        
        chrome.tabs.sendMessage(currentTab.id, {
            type: 'WINDOW_DETECTOR_REQUEST',
            action: 'START_TRACKING'
        }, function(response) {
            if (response && response.action === 'TRACKING_STARTED') {
                isTracking = true;
                updateTrackingButtons();
                addLogEntry('Tracking started');
            }
        });
    }
    
    function stopTracking() {
        if (!currentTab || !windowDetectorAvailable) return;
        
        chrome.tabs.sendMessage(currentTab.id, {
            type: 'WINDOW_DETECTOR_REQUEST',
            action: 'STOP_TRACKING'
        }, function(response) {
            if (response && response.action === 'TRACKING_STOPPED') {
                isTracking = false;
                updateTrackingButtons();
                addLogEntry('Tracking stopped');
            }
        });
    }
    
    function clearLog() {
        movementLog.innerHTML = '';
    }
    
    function addLogEntry(message) {
        const timestamp = new Date().toLocaleTimeString();
        const entry = document.createElement('div');
        entry.textContent = `[${timestamp}] ${message}`;
        movementLog.appendChild(entry);
        
        // Keep only last 10 entries
        while (movementLog.children.length > 10) {
            movementLog.removeChild(movementLog.firstChild);
        }
        
        // Scroll to bottom
        movementLog.scrollTop = movementLog.scrollHeight;
    }
    
    // Listen for messages from content script
    chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
        if (request.type === 'WINDOW_DETECTOR_RESPONSE') {
            handleWindowDetectorResponse(request);
        }
    });
    
    function handleWindowDetectorResponse(response) {
        switch (response.action) {
            case 'GET_POSITION':
                if (response.x !== undefined && response.y !== undefined) {
                    positionDisplay.textContent = `Position: (${response.x}, ${response.y})`;
                }
                break;
                
            case 'TRACKING_STARTED':
                isTracking = true;
                updateTrackingButtons();
                addLogEntry('Tracking started');
                break;
                
            case 'TRACKING_STOPPED':
                isTracking = false;
                updateTrackingButtons();
                addLogEntry('Tracking stopped');
                break;
                
            case 'WINDOW_MOVED':
                const { oldX, oldY, newX, newY, deltaX, deltaY } = response;
                addLogEntry(`Moved: (${oldX},${oldY}) → (${newX},${newY}) [Δ${deltaX},Δ${deltaY}]`);
                break;
        }
    }
}); 