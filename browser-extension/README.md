# 3x2 Window Manager Browser Extension

This browser extension enables window positioning capabilities for the 3x2 Physics Demo web game, allowing the game to move the browser window for enhanced gameplay interaction.

## Features

- **Window Positioning**: Move browser window to specific coordinates
- **Relative Movement**: Move window by offset amounts
- **Permission-Based Access**: Secure permission system for window control
- **Manual Control**: Extension popup for manual window positioning
- **Automatic Detection**: Works on supported sites automatically

## Installation

### Chrome/Edge/Brave

1. **Download the Extension**
   ```bash
   # Clone or download the extension files
   cd browser-extension
   ```

2. **Load Extension in Chrome**
   - Open Chrome and go to `chrome://extensions/`
   - Enable "Developer mode" (toggle in top right)
   - Click "Load unpacked"
   - Select the `browser-extension` folder

3. **Verify Installation**
   - The extension should appear in your extensions list
   - You should see the "3x2 Window Manager" extension icon

### Firefox

1. **Package the Extension**
   ```bash
   # Create a ZIP file of the extension
   zip -r 3x2-window-manager.zip browser-extension/
   ```

2. **Load in Firefox**
   - Go to `about:debugging`
   - Click "This Firefox"
   - Click "Load Temporary Add-on"
   - Select the ZIP file

## Usage

### For Users

1. **Install the Extension** (see installation instructions above)

2. **Navigate to the Game**
   - Go to `http://localhost:8000/3x2-web-debug.html` (local development)
   - Or go to `https://rebroad.github.io/androidballs/` (live version)

3. **Grant Permission**
   - When prompted, allow the extension to manage window positioning
   - This is required for security reasons

4. **Enjoy Enhanced Gameplay**
   - The game can now position the window for optimal interaction
   - Use the extension popup for manual window control

### For Developers

The extension provides a JavaScript API that can be used in web applications:

```javascript
// Check if window positioning is available
if (window.isWindowPositioningAvailable()) {
    // Move window to specific position
    window.moveWindowTo(100, 100);
    
    // Move window by relative amount
    window.moveWindowBy(50, -25);
    
    // Get current window position
    window.getWindowPosition();
    
    // Request permission
    window.requestWindowPermission();
}
```

Or use the more detailed API:

```javascript
// Check if extension is available
if (window.WindowManager && window.WindowManager.isAvailable()) {
    // Set window position
    window.WindowManager.setPosition(200, 150);
    
    // Move window by offset
    window.WindowManager.moveBy(10, -5);
    
    // Get position
    window.WindowManager.getPosition();
    
    // Request permission
    window.WindowManager.requestPermission();
}
```

## Supported Sites

The extension works on the following URLs:
- `http://localhost:8000/*`
- `https://rebroad.github.io/*`
- `https://localhost:8000/*`

## Security

- **Permission Required**: Window positioning requires explicit user permission
- **Site Restrictions**: Only works on pre-approved domains
- **User Control**: Users can deny permission at any time
- **Transparent Operation**: All window movements are logged and visible

## Technical Details

### How It Works

1. **Content Script Injection**: The extension injects a content script into supported pages
2. **API Injection**: A window management API is made available to the page
3. **Permission System**: User permission is required for window operations
4. **Browser APIs**: Uses `window.moveTo()` and `window.moveBy()` APIs
5. **Message Passing**: Communication between page and extension via `postMessage`

### Browser Compatibility

- **Chrome**: Full support
- **Edge**: Full support (Chromium-based)
- **Brave**: Full support (Chromium-based)
- **Firefox**: Limited support (may require additional permissions)

### Limitations

- **Deprecated APIs**: Uses deprecated but functional browser APIs
- **Browser Restrictions**: Some browsers may block window movement
- **Security Policies**: Modern browsers have strict security policies
- **User Interaction**: May require user interaction before window movement

## Troubleshooting

### Extension Not Working

1. **Check Installation**: Verify the extension is installed and enabled
2. **Check URL**: Ensure you're on a supported site
3. **Grant Permission**: Make sure you've granted permission when prompted
4. **Browser Console**: Check for error messages in the browser console

### Window Movement Blocked

1. **Browser Settings**: Some browsers block window movement by default
2. **Security Software**: Antivirus or security software may block window movement
3. **User Interaction**: Try clicking on the page before moving the window
4. **Alternative**: Use the extension popup for manual control

### Permission Denied

1. **Refresh Page**: Try refreshing the page and granting permission again
2. **Extension Icon**: Click the extension icon and use the popup controls
3. **Browser Settings**: Check if the extension has the necessary permissions

## Development

### Building the Extension

The extension is ready to use as-is. No build process is required.

### Modifying the Extension

1. **Edit Files**: Modify the JavaScript files in the extension directory
2. **Reload Extension**: Go to `chrome://extensions/` and click "Reload"
3. **Test Changes**: Navigate to a supported site to test changes

### Adding New Sites

To add support for new sites, edit `manifest.json`:

```json
{
  "content_scripts": [
    {
      "matches": [
        "http://localhost:8000/*",
        "https://rebroad.github.io/*",
        "https://localhost:8000/*",
        "https://your-new-site.com/*"  // Add new site here
      ],
      "js": ["content-script.js"],
      "run_at": "document_start"
    }
  ]
}
```

## License

This extension is provided as-is for the 3x2 Physics Demo project.

## Support

For issues or questions:
1. Check the browser console for error messages
2. Verify the extension is properly installed
3. Ensure you're on a supported site
4. Try refreshing the page and granting permission again 