// Content script for 3x2 Physics Demo Window Movement Detector
// This script detects when the user moves the browser window

console.log('3x2 Window Detector: Content script loaded');

// Create a window movement detector that will be injected into the page
const windowMovementDetector = {
  // Track window position
  currentX: 0,
  currentY: 0,
  isTracking: false,
  
  // Initialize window movement detector
  init() {
    console.log('3x2 Window Detector: Initializing window movement detector');
    
    // Inject the window detector script into the page
    this.injectWindowDetector();
    
    // Set up message listener for communication with the page
    window.addEventListener('message', this.handleMessage.bind(this));
    
    // Start tracking window position
    this.startTracking();
    
    // Notify the page that window detector is ready
    this.notifyPageReady();
  },
  
  // Inject the window detector script into the page context
  injectWindowDetector() {
    const script = document.createElement('script');
    script.src = chrome.runtime.getURL('window-detector.js');
    script.onload = () => {
      console.log('3x2 Window Detector: Window detector script injected');
    };
    (document.head || document.documentElement).appendChild(script);
  },
  
  // Handle messages from the page
  handleMessage(event) {
    if (event.source !== window) return;
    
    if (event.data.type === 'WINDOW_DETECTOR_REQUEST') {
      this.handleWindowRequest(event.data);
    }
  },
  
  // Handle window detection requests from the page
  handleWindowRequest(data) {
    switch (data.action) {
      case 'START_TRACKING':
        this.startTracking();
        break;
      case 'STOP_TRACKING':
        this.stopTracking();
        break;
      case 'GET_POSITION':
        this.getCurrentPosition();
        break;
      case 'REQUEST_PERMISSION':
        this.requestPermission();
        break;
    }
  },
  
  // Start tracking window position changes
  startTracking() {
    if (this.isTracking) return;
    
    console.log('3x2 Window Detector: Starting window position tracking');
    this.isTracking = true;
    
    // Get initial position
    this.updateCurrentPosition();
    
    // Set up periodic position checking
    this.trackingInterval = setInterval(() => {
      this.checkPositionChange();
    }, 100); // Check every 100ms
    
    // Also listen for window resize events
    window.addEventListener('resize', this.handleWindowEvent.bind(this));
    window.addEventListener('move', this.handleWindowEvent.bind(this));
    
    this.notifyPage({
      type: 'WINDOW_DETECTOR_RESPONSE',
      action: 'TRACKING_STARTED'
    });
  },
  
  // Stop tracking window position changes
  stopTracking() {
    if (!this.isTracking) return;
    
    console.log('3x2 Window Detector: Stopping window position tracking');
    this.isTracking = false;
    
    if (this.trackingInterval) {
      clearInterval(this.trackingInterval);
      this.trackingInterval = null;
    }
    
    window.removeEventListener('resize', this.handleWindowEvent.bind(this));
    window.removeEventListener('move', this.handleWindowEvent.bind(this));
    
    this.notifyPage({
      type: 'WINDOW_DETECTOR_RESPONSE',
      action: 'TRACKING_STOPPED'
    });
  },
  
  // Handle window events (resize, move)
  handleWindowEvent(event) {
    console.log('3x2 Window Detector: Window event detected:', event.type);
    this.checkPositionChange();
  },
  
  // Check if window position has changed
  checkPositionChange() {
    const newX = window.screenX || window.screenLeft;
    const newY = window.screenY || window.screenTop;
    
    if (newX !== this.currentX || newY !== this.currentY) {
      const oldX = this.currentX;
      const oldY = this.currentY;
      
      this.currentX = newX;
      this.currentY = newY;
      
      console.log(`3x2 Window Detector: Window moved from (${oldX}, ${oldY}) to (${newX}, ${newY})`);
      
      // Notify the page of the movement
      this.notifyPage({
        type: 'WINDOW_DETECTOR_RESPONSE',
        action: 'WINDOW_MOVED',
        oldX: oldX,
        oldY: oldY,
        newX: newX,
        newY: newY,
        deltaX: newX - oldX,
        deltaY: newY - oldY
      });
    }
  },
  
  // Update current position
  updateCurrentPosition() {
    this.currentX = window.screenX || window.screenLeft;
    this.currentY = window.screenY || window.screenTop;
    console.log(`3x2 Window Detector: Current position (${this.currentX}, ${this.currentY})`);
  },
  
  // Get current window position
  getCurrentPosition() {
    this.updateCurrentPosition();
    this.notifyPage({
      type: 'WINDOW_DETECTOR_RESPONSE',
      action: 'GET_POSITION',
      x: this.currentX,
      y: this.currentY
    });
  },
  
  // Check if we have permission to track window position
  hasPermission() {
    // For window movement detection, we don't need special permissions
    // as we're only reading window position, not controlling it
    return true;
  },
  
  // Request permission (for consistency with the API)
  requestPermission() {
    console.log('3x2 Window Detector: Permission not required for window movement detection');
    this.notifyPage({
      type: 'WINDOW_DETECTOR_RESPONSE',
      action: 'PERMISSION_GRANTED'
    });
  },
  
  // Notify the page that window detector is ready
  notifyPageReady() {
    this.notifyPage({
      type: 'WINDOW_DETECTOR_READY'
    });
  },
  
  // Send message to the page
  notifyPage(data) {
    window.postMessage(data, '*');
  }
};

// Initialize the window movement detector when the content script loads
windowMovementDetector.init(); 