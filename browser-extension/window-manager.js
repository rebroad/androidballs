// Window Manager Script - Injected into the page context
// This provides the API for window positioning that the game can use

console.log('3x2 Window Manager: Window manager script loaded in page context');

// Create the window manager API that will be available to the game
window.WindowManager = {
  // Track if the extension is available
  available: false,
  permissionGranted: false,
  
  // Initialize the window manager
  init() {
    console.log('3x2 Window Manager: Initializing window manager API');
    
    // Listen for messages from the content script
    window.addEventListener('message', this.handleMessage.bind(this));
    
    // Check if the extension is available
    this.checkAvailability();
  },
  
  // Handle messages from the content script
  handleMessage(event) {
    if (event.data.type === 'WINDOW_MANAGER_READY') {
      this.available = true;
      console.log('3x2 Window Manager: Extension is available');
      this.onReady();
    } else if (event.data.type === 'WINDOW_MANAGER_RESPONSE') {
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
        console.log('3x2 Window Manager: Extension not available, using fallback');
        this.onFallback();
      }
    }, 1000);
  },
  
  // Send a request to the content script
  sendRequest(data) {
    window.postMessage({
      type: 'WINDOW_MANAGER_REQUEST',
      ...data
    }, '*');
  },
  
  // Handle responses from the content script
  handleResponse(data) {
    switch (data.action) {
      case 'SET_POSITION':
        if (data.success) {
          console.log(`3x2 Window Manager: Window moved to (${data.x}, ${data.y})`);
          this.onPositionSet(data.x, data.y);
        } else {
          console.error('3x2 Window Manager: Failed to set window position:', data.error);
          this.onError(data.error);
        }
        break;
        
      case 'GET_POSITION':
        console.log(`3x2 Window Manager: Current position (${data.x}, ${data.y})`);
        this.onPositionGet(data.x, data.y);
        break;
        
      case 'PERMISSION_GRANTED':
        this.permissionGranted = true;
        console.log('3x2 Window Manager: Permission granted');
        this.onPermissionGranted();
        break;
        
      case 'PERMISSION_DENIED':
        this.permissionGranted = false;
        console.log('3x2 Window Manager: Permission denied');
        this.onPermissionDenied();
        break;
    }
  },
  
  // API Methods that the game can call
  
  // Set window position
  setPosition(x, y) {
    if (!this.available) {
      console.warn('3x2 Window Manager: Extension not available');
      return false;
    }
    
    this.sendRequest({
      action: 'SET_POSITION',
      x: x,
      y: y
    });
    return true;
  },
  
  // Move window by relative amount
  moveBy(dx, dy) {
    if (!this.available) {
      console.warn('3x2 Window Manager: Extension not available');
      return false;
    }
    
    this.sendRequest({
      action: 'MOVE_BY',
      dx: dx,
      dy: dy
    });
    return true;
  },
  
  // Get current window position
  getPosition() {
    if (!this.available) {
      console.warn('3x2 Window Manager: Extension not available');
      return null;
    }
    
    this.sendRequest({
      action: 'GET_POSITION'
    });
    return true;
  },
  
  // Request permission
  requestPermission() {
    if (!this.available) {
      console.warn('3x2 Window Manager: Extension not available');
      return false;
    }
    
    this.sendRequest({
      action: 'REQUEST_PERMISSION'
    });
    return true;
  },
  
  // Check if window positioning is available
  isAvailable() {
    return this.available && this.permissionGranted;
  },
  
  // Event handlers (can be overridden by the game)
  onReady() {
    console.log('3x2 Window Manager: Ready for use');
  },
  
  onPositionSet(x, y) {
    console.log(`3x2 Window Manager: Position set to (${x}, ${y})`);
  },
  
  onPositionGet(x, y) {
    console.log(`3x2 Window Manager: Current position is (${x}, ${y})`);
  },
  
  onPermissionGranted() {
    console.log('3x2 Window Manager: Permission granted');
  },
  
  onPermissionDenied() {
    console.log('3x2 Window Manager: Permission denied');
  },
  
  onError(error) {
    console.error('3x2 Window Manager: Error:', error);
  },
  
  onFallback() {
    console.log('3x2 Window Manager: Using fallback mode (no window positioning)');
  }
};

// Initialize the window manager
window.WindowManager.init();

// Also expose a simpler API for direct use
window.moveWindowTo = (x, y) => window.WindowManager.setPosition(x, y);
window.moveWindowBy = (dx, dy) => window.WindowManager.moveBy(dx, dy);
window.getWindowPosition = () => window.WindowManager.getPosition();
window.requestWindowPermission = () => window.WindowManager.requestPermission();
window.isWindowPositioningAvailable = () => window.WindowManager.isAvailable(); 