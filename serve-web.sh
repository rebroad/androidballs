#!/bin/bash
echo "Starting local web server for 3x2 Physics Demo..."
echo "Open your browser to: http://localhost:8000/3x2-web-debug.html"
echo "For HTTPS (required for sensors): https://localhost:8000/3x2-web-debug.html"
echo ""
echo "Note: Sensors require HTTPS. For mobile testing, use GitHub Pages:"
echo "https://rebroad.github.io/androidballs/"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Check if Python 3 is available
if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server 8000
elif command -v python >/dev/null 2>&1; then
    python -m http.server 8000
else
    echo "Python not found. Please install Python to serve the web files."
    echo "Alternatively, open the HTML file directly in your browser."
fi
