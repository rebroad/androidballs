// Background service worker for 3x2 Physics Demo Window Manager

console.log('3x2 Window Manager: Background service worker loaded');

// Handle extension installation
chrome.runtime.onInstalled.addListener((details) => {
  console.log('3x2 Window Manager: Extension installed', details);
  
  if (details.reason === 'install') {
    // Show welcome message
    chrome.tabs.create({
      url: 'welcome.html'
    });
  }
});

// Handle messages from content scripts
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  console.log('3x2 Window Manager: Received message', request);
  
  if (request.type === 'GET_TAB_INFO') {
    // Return information about the current tab
    sendResponse({
      tabId: sender.tab.id,
      url: sender.tab.url,
      title: sender.tab.title
    });
  }
  
  return true; // Keep the message channel open for async response
});

// Handle tab updates to inject content script if needed
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete' && tab.url) {
    // Check if this is a supported URL
    const supportedUrls = [
      'http://localhost:8000',
      'https://rebroad.github.io',
      'https://localhost:8000'
    ];
    
    const isSupported = supportedUrls.some(url => tab.url.startsWith(url));
    
    if (isSupported) {
      console.log('3x2 Window Manager: Tab updated, checking for content script');
      
      // Check if content script is already injected
      chrome.scripting.executeScript({
        target: { tabId: tabId },
        func: () => {
          return typeof window.WindowManager !== 'undefined';
        }
      }).then((results) => {
        if (results && results[0] && !results[0].result) {
          console.log('3x2 Window Manager: Content script not found, injecting...');
          // The content script should be automatically injected via manifest
        }
      });
    }
  }
});

// Handle extension icon click
chrome.action.onClicked.addListener((tab) => {
  console.log('3x2 Window Manager: Extension icon clicked');
  
  // Toggle the popup or show status
  chrome.tabs.sendMessage(tab.id, {
    type: 'EXTENSION_ICON_CLICKED'
  }).catch(() => {
    // If content script is not available, show popup
    chrome.action.setPopup({
      tabId: tab.id,
      popup: 'popup.html'
    });
  });
}); 