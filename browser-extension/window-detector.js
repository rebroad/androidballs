// Window Detector Script - Injected into the page context
// This provides the API for detecting window movement events

console.log('3x2 Window Detector: Window detector script loaded in page context');

// Create the window detector API that will be available to the game
window.WindowDetector = {
  // Track if the extension is available
  available: false,
  isTracking: false,
  
  // Initialize the window detector
  init() {
    console.log('3x2 Window Detector: Initializing window detector API');
    
    // Listen for messages from the content script
    window.addEventListener('message', this.handleMessage.bind(this));
    
    // Check if the extension is available
    this.checkAvailability();
  },
  
  // Handle messages from the content script
  handleMessage(event) {
    if (event.data.type === 'WINDOW_DETECTOR_READY') {
      this.available = true;
      console.log('3x2 Window Detector: Extension is available');
      this.onReady();
    } else if (event.data.type === 'WINDOW_DETECTOR_RESPONSE') {
      this.handleResponse(event.data);
    }
  },
  
  // Check if the extension is available
  checkAvailability() {
    // Send a test message to see if the extension responds
    this.sendRequest({
      action: 'GET_POSITION'
    });
    
    // If no response within 1 second, assume extension is not available
    setTimeout(() => {
      if (!this.available) {
        console.log('3x2 Window Detector: Extension not available, using fallback');
        this.onFallback();
      }
    }, 1000);
  },
  
  // Send a request to the content script
  sendRequest(data) {
    window.postMessage({
      type: 'WINDOW_DETECTOR_REQUEST',
      ...data
    }, '*');
  },
  
  // Handle responses from the content script
  handleResponse(data) {
    switch (data.action) {
      case 'TRACKING_STARTED':
        this.isTracking = true;
        console.log('3x2 Window Detector: Window movement tracking started');
        this.onTrackingStarted();
        break;
        
      case 'TRACKING_STOPPED':
        this.isTracking = false;
        console.log('3x2 Window Detector: Window movement tracking stopped');
        this.onTrackingStopped();
        break;
        
      case 'WINDOW_MOVED':
        console.log(`3x2 Window Detector: Window moved from (${data.oldX}, ${data.oldY}) to (${data.newX}, ${data.newY})`);
        this.onWindowMoved(data.oldX, data.oldY, data.newX, data.newY, data.deltaX, data.deltaY);
        break;
        
      case 'GET_POSITION':
        console.log(`3x2 Window Detector: Current position (${data.x}, ${data.y})`);
        this.onPositionGet(data.x, data.y);
        break;
        
      case 'PERMISSION_GRANTED':
        console.log('3x2 Window Detector: Permission granted');
        this.onPermissionGranted();
        break;
    }
  },
  
  // API Methods that the game can call
  
  // Start tracking window movement
  startTracking() {
    if (!this.available) {
      console.warn('3x2 Window Detector: Extension not available');
      return false;
    }
    
    this.sendRequest({
      action: 'START_TRACKING'
    });
    return true;
  },
  
  // Stop tracking window movement
  stopTracking() {
    if (!this.available) {
      console.warn('3x2 Window Detector: Extension not available');
      return false;
    }
    
    this.sendRequest({
      action: 'STOP_TRACKING'
    });
    return true;
  },
  
  // Get current window position
  getPosition() {
    if (!this.available) {
      console.warn('3x2 Window Detector: Extension not available');
      return null;
    }
    
    this.sendRequest({
      action: 'GET_POSITION'
    });
    return true;
  },
  
  // Request permission (for consistency)
  requestPermission() {
    if (!this.available) {
      console.warn('3x2 Window Detector: Extension not available');
      return false;
    }
    
    this.sendRequest({
      action: 'REQUEST_PERMISSION'
    });
    return true;
  },
  
  // Check if window movement detection is available
  isAvailable() {
    return this.available;
  },
  
  // Check if tracking is active
  isTrackingActive() {
    return this.isTracking;
  },
  
  // Event handlers (can be overridden by the game)
  onReady() {
    console.log('3x2 Window Detector: Ready for use');
  },
  
  onTrackingStarted() {
    console.log('3x2 Window Detector: Tracking started');
  },
  
  onTrackingStopped() {
    console.log('3x2 Window Detector: Tracking stopped');
  },
  
  onWindowMoved(oldX, oldY, newX, newY, deltaX, deltaY) {
    console.log(`3x2 Window Detector: Window moved from (${oldX}, ${oldY}) to (${newX}, ${newY})`);
    
    // Dispatch a custom event that the game can listen for
    const event = new CustomEvent('windowMoved', {
      detail: {
        oldX: oldX,
        oldY: oldY,
        newX: newX,
        newY: newY,
        deltaX: deltaX,
        deltaY: deltaY,
        timestamp: Date.now()
      }
    });
    window.dispatchEvent(event);
  },
  
  onPositionGet(x, y) {
    console.log(`3x2 Window Detector: Current position is (${x}, ${y})`);
  },
  
  onPermissionGranted() {
    console.log('3x2 Window Detector: Permission granted');
  },
  
  onFallback() {
    console.log('3x2 Window Detector: Using fallback mode (no window movement detection)');
    
    // Set up basic fallback using window resize events
    this.setupFallbackDetection();
  },
  
  // Set up fallback detection using available browser APIs
  setupFallbackDetection() {
    console.log('3x2 Window Detector: Setting up fallback detection');
    
    // Use window resize events as a fallback
    // Note: This is not as reliable as the extension but provides basic functionality
    let lastWidth = window.innerWidth;
    let lastHeight = window.innerHeight;
    
    window.addEventListener('resize', () => {
      const newWidth = window.innerWidth;
      const newHeight = window.innerHeight;
      
      if (newWidth !== lastWidth || newHeight !== lastHeight) {
        console.log('3x2 Window Detector: Window resized (fallback detection)');
        
        // Dispatch a resize event that the game can listen for
        const event = new CustomEvent('windowResized', {
          detail: {
            oldWidth: lastWidth,
            oldHeight: lastHeight,
            newWidth: newWidth,
            newHeight: newHeight,
            timestamp: Date.now()
          }
        });
        window.dispatchEvent(event);
        
        lastWidth = newWidth;
        lastHeight = newHeight;
      }
    });
  }
};

// Initialize the window detector
window.WindowDetector.init();

// Also expose a simpler API for direct use
window.startWindowTracking = () => window.WindowDetector.startTracking();
window.stopWindowTracking = () => window.WindowDetector.stopTracking();
window.getWindowPosition = () => window.WindowDetector.getPosition();
window.isWindowTrackingAvailable = () => window.WindowDetector.isAvailable();
window.isWindowTrackingActive = () => window.WindowDetector.isTrackingActive(); 