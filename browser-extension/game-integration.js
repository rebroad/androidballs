// Game Integration Script for 3x2 Window Movement Detector Extension
// Add this to your web game to detect window movement events

(function() {
    'use strict';
    
    // Game Window Movement Detector Integration
    const GameWindowDetector = {
        // Track if window movement detection is available
        available: false,
        isTracking: false,
        
        // Initialize the window movement detector integration
        init() {
            console.log('Game Window Detector: Initializing integration');
            
            // Check for extension availability
            this.checkExtension();
            
            // Set up event listeners for window movement events
            this.setupEventListeners();
            
            // Override SDL window event functions if available
            this.overrideSDLFunctions();
        },
        
        // Check if the extension is available
        checkExtension() {
            // Wait for WindowDetector to be available
            const checkInterval = setInterval(() => {
                if (window.WindowDetector) {
                    clearInterval(checkInterval);
                    this.available = true;
                    console.log('Game Window Detector: Extension detected');
                    
                    // Set up extension event handlers
                    this.setupExtensionHandlers();
                    
                    // Start tracking window movement
                    this.startTracking();
                }
            }, 100);
            
            // Timeout after 5 seconds
            setTimeout(() => {
                clearInterval(checkInterval);
                if (!this.available) {
                    console.log('Game Window Detector: Extension not available, using fallback');
                    this.setupFallback();
                }
            }, 5000);
        },
        
        // Set up event handlers for the extension
        setupExtensionHandlers() {
            if (!window.WindowDetector) return;
            
            // Override extension event handlers
            window.WindowDetector.onReady = () => {
                console.log('Game Window Detector: Extension ready');
                this.available = true;
                this.onExtensionReady();
            };
            
            window.WindowDetector.onTrackingStarted = () => {
                console.log('Game Window Detector: Tracking started');
                this.isTracking = true;
                this.onTrackingStarted();
            };
            
            window.WindowDetector.onTrackingStopped = () => {
                console.log('Game Window Detector: Tracking stopped');
                this.isTracking = false;
                this.onTrackingStopped();
            };
            
            window.WindowDetector.onWindowMoved = (oldX, oldY, newX, newY, deltaX, deltaY) => {
                console.log(`Game Window Detector: Window moved from (${oldX}, ${oldY}) to (${newX}, ${newY})`);
                this.onWindowMoved(oldX, oldY, newX, newY, deltaX, deltaY);
            };
            
            window.WindowDetector.onError = (error) => {
                console.error('Game Window Detector: Error:', error);
                this.onError(error);
            };
        },
        
        // Set up event listeners for window movement events
        setupEventListeners() {
            // Listen for window movement events
            window.addEventListener('windowMoved', (e) => {
                console.log('Game Window Detector: Window moved event received', e.detail);
                this.handleWindowMovedEvent(e.detail);
            });
            
            // Listen for window resize events (fallback)
            window.addEventListener('windowResized', (e) => {
                console.log('Game Window Detector: Window resized event received', e.detail);
                this.handleWindowResizedEvent(e.detail);
            });
            
            // Listen for game events that might require window movement detection
            document.addEventListener('keydown', (e) => {
                // Example: Ctrl+Shift+T to toggle tracking
                if (e.ctrlKey && e.shiftKey && e.key === 'T') {
                    e.preventDefault();
                    this.toggleTracking();
                }
                
                // Example: Ctrl+Shift+P to get current position
                if (e.ctrlKey && e.shiftKey && e.key === 'P') {
                    e.preventDefault();
                    this.getCurrentPosition();
                }
            });
            
            // Listen for game state changes that might require window movement detection
            window.addEventListener('gameStateChanged', (e) => {
                this.handleGameStateChange(e.detail);
            });
        },
        
        // Override SDL functions to use extension when available
        overrideSDLFunctions() {
            // This would be called after SDL is loaded
            const checkSDL = setInterval(() => {
                if (window.SDL) {
                    clearInterval(checkSDL);
                    this.overrideSDLWindowEvents();
                }
            }, 100);
        },
        
        // Override SDL window event functions to use extension
        overrideSDLWindowEvents() {
            // Note: SDL doesn't have built-in window movement detection
            // This is more about integrating with SDL's event system
            console.log('Game Window Detector: SDL window events integration ready');
            
            // You could potentially hook into SDL's event system here
            // to dispatch custom window movement events
        },
        
        // Start tracking window movement
        startTracking() {
            if (window.WindowDetector) {
                return window.WindowDetector.startTracking();
            } else {
                console.warn('Game Window Detector: Extension not available for tracking');
                return false;
            }
        },
        
        // Stop tracking window movement
        stopTracking() {
            if (window.WindowDetector) {
                return window.WindowDetector.stopTracking();
            } else {
                console.warn('Game Window Detector: Extension not available for tracking');
                return false;
            }
        },
        
        // Toggle tracking on/off
        toggleTracking() {
            if (this.isTracking) {
                this.stopTracking();
            } else {
                this.startTracking();
            }
        },
        
        // Get current window position
        getCurrentPosition() {
            if (window.WindowDetector) {
                return window.WindowDetector.getPosition();
            } else {
                console.warn('Game Window Detector: Extension not available for position detection');
                return false;
            }
        },
        
        // Handle window movement events from the extension
        handleWindowMovedEvent(detail) {
            console.log('Game Window Detector: Processing window movement', detail);
            
            // Example: Update game physics based on window movement
            this.updateGamePhysics(detail);
            
            // Example: Adjust game camera or view based on window movement
            this.adjustGameView(detail);
            
            // Example: Trigger game events based on window movement
            this.triggerGameEvents(detail);
        },
        
        // Handle window resize events (fallback)
        handleWindowResizedEvent(detail) {
            console.log('Game Window Detector: Processing window resize', detail);
            
            // Handle window resize as a fallback for movement detection
            this.handleWindowMovedEvent({
                oldX: detail.oldWidth,
                oldY: detail.oldHeight,
                newX: detail.newWidth,
                newY: detail.newHeight,
                deltaX: detail.newWidth - detail.oldWidth,
                deltaY: detail.newHeight - detail.oldHeight,
                timestamp: detail.timestamp
            });
        },
        
        // Update game physics based on window movement
        updateGamePhysics(movement) {
            // Example: Use window movement to affect game physics
            // This could be used for tilt-based controls or other physics effects
            
            const { deltaX, deltaY } = movement;
            
            // Convert window movement to game physics effects
            const physicsEffect = {
                tiltX: deltaX * 0.01, // Scale down the effect
                tiltY: deltaY * 0.01,
                force: Math.sqrt(deltaX * deltaX + deltaY * deltaY) * 0.001
            };
            
            console.log('Game Window Detector: Physics effect from window movement', physicsEffect);
            
            // Dispatch a custom event for the game to handle
            const event = new CustomEvent('windowMovementPhysics', {
                detail: physicsEffect
            });
            window.dispatchEvent(event);
        },
        
        // Adjust game view based on window movement
        adjustGameView(movement) {
            // Example: Adjust camera or view based on window position
            const { newX, newY } = movement;
            
            // Calculate view adjustments based on window position
            const viewAdjustment = {
                offsetX: newX * 0.1, // Scale factor
                offsetY: newY * 0.1,
                zoom: 1.0 + (Math.abs(newX) + Math.abs(newY)) * 0.0001
            };
            
            console.log('Game Window Detector: View adjustment from window movement', viewAdjustment);
            
            // Dispatch a custom event for the game to handle
            const event = new CustomEvent('windowMovementView', {
                detail: viewAdjustment
            });
            window.dispatchEvent(event);
        },
        
        // Trigger game events based on window movement
        triggerGameEvents(movement) {
            const { deltaX, deltaY, timestamp } = movement;
            
            // Example: Trigger different game events based on movement patterns
            if (Math.abs(deltaX) > 50 || Math.abs(deltaY) > 50) {
                // Large movement - trigger dramatic event
                const event = new CustomEvent('windowMovementDramatic', {
                    detail: { deltaX, deltaY, timestamp }
                });
                window.dispatchEvent(event);
            } else if (Math.abs(deltaX) > 10 || Math.abs(deltaY) > 10) {
                // Medium movement - trigger normal event
                const event = new CustomEvent('windowMovementNormal', {
                    detail: { deltaX, deltaY, timestamp }
                });
                window.dispatchEvent(event);
            } else {
                // Small movement - trigger subtle event
                const event = new CustomEvent('windowMovementSubtle', {
                    detail: { deltaX, deltaY, timestamp }
                });
                window.dispatchEvent(event);
            }
        },
        
        // Handle game state changes that might require window movement detection
        handleGameStateChange(state) {
            // Example: Enable/disable tracking based on game state
            switch (state) {
                case 'menu':
                    this.startTracking();
                    break;
                case 'gameplay':
                    this.startTracking();
                    break;
                case 'pause':
                    this.stopTracking();
                    break;
                case 'gameOver':
                    this.stopTracking();
                    break;
            }
        },
        
        // Set up fallback behavior when extension is not available
        setupFallback() {
            console.log('Game Window Detector: Setting up fallback behavior');
            
            // Create a simple fallback API
            window.GameWindowDetector = {
                startTracking: () => {
                    console.log('Game Window Detector: Fallback - tracking not available');
                    return false;
                },
                stopTracking: () => {
                    console.log('Game Window Detector: Fallback - tracking not available');
                    return false;
                },
                getPosition: () => {
                    console.log('Game Window Detector: Fallback - position detection not available');
                    return false;
                },
                isAvailable: () => false,
                isTrackingActive: () => false
            };
        },
        
        // Event handlers (can be overridden by the game)
        onExtensionReady() {
            console.log('Game Window Detector: Extension is ready for use');
            // Game can override this to handle extension ready state
        },
        
        onTrackingStarted() {
            console.log('Game Window Detector: Window movement tracking started');
            // Game can override this to handle tracking start
        },
        
        onTrackingStopped() {
            console.log('Game Window Detector: Window movement tracking stopped');
            // Game can override this to handle tracking stop
        },
        
        onWindowMoved(oldX, oldY, newX, newY, deltaX, deltaY) {
            console.log(`Game Window Detector: Window moved from (${oldX}, ${oldY}) to (${newX}, ${newY})`);
            // Game can override this to handle window movement
        },
        
        onError(error) {
            console.error('Game Window Detector: Error occurred:', error);
            // Game can override this to handle errors
        }
    };
    
    // Initialize the game window detector when the page loads
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            GameWindowDetector.init();
        });
    } else {
        GameWindowDetector.init();
    }
    
    // Expose the GameWindowDetector globally
    window.GameWindowDetector = GameWindowDetector;
    
    console.log('Game Window Detector: Integration script loaded');
})(); 