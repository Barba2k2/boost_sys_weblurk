class WebViewConfig {
  // Desktop User Agent strings for different browsers
  static const String chromeDesktopUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static const String firefoxDesktopUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0';

  static const String edgeDesktopUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0';

  // Default desktop user agent (Chrome)
  static const String defaultDesktopUserAgent = chromeDesktopUserAgent;

  // JavaScript code to force desktop mode
  static const String forceDesktopModeScript = '''
    (function() {
      // Override navigator.userAgent
      Object.defineProperty(navigator, 'userAgent', {
        get: function() {
          return '$defaultDesktopUserAgent';
        },
        configurable: true
      });
      
      // Override navigator.platform
      Object.defineProperty(navigator, 'platform', {
        get: function() {
          return 'Win32';
        },
        configurable: true
      });
      
      // Override screen properties for desktop
      Object.defineProperty(screen, 'width', {
        get: function() {
          return 1920;
        },
        configurable: true
      });
      
      Object.defineProperty(screen, 'height', {
        get: function() {
          return 1080;
        },
        configurable: true
      });
      
      // Override window.innerWidth and innerHeight
      Object.defineProperty(window, 'innerWidth', {
        get: function() {
          return 1920;
        },
        configurable: true
      });
      
      Object.defineProperty(window, 'innerHeight', {
        get: function() {
          return 1080;
        },
        configurable: true
      });
      
      // Force desktop viewport meta tag
      const viewport = document.querySelector('meta[name="viewport"]');
      if (viewport) {
        viewport.setAttribute('content', 'width=1920, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
      } else {
        const meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=1920, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        document.head.appendChild(meta);
      }
      
      // Override touch events to simulate mouse events
      if ('ontouchstart' in window) {
        document.addEventListener('touchstart', function(e) {
          e.preventDefault();
          const mouseEvent = new MouseEvent('mousedown', {
            clientX: e.touches[0].clientX,
            clientY: e.touches[0].clientY,
            button: 0
          });
          e.target.dispatchEvent(mouseEvent);
        }, { passive: false });
        
        document.addEventListener('touchend', function(e) {
          e.preventDefault();
          const mouseEvent = new MouseEvent('mouseup', {
            clientX: e.changedTouches[0].clientX,
            clientY: e.changedTouches[0].clientY,
            button: 0
          });
          e.target.dispatchEvent(mouseEvent);
        }, { passive: false });
      }
      
      // Force desktop CSS media queries
      const style = document.createElement('style');
      style.textContent = \`
        @media (max-width: 768px) {
          body { min-width: 1200px !important; }
          .container { min-width: 1200px !important; }
          .mobile-only { display: none !important; }
          .desktop-only { display: block !important; }
        }
      \`;
      document.head.appendChild(style);
      
      console.log('Desktop mode forced successfully');
    })();
  ''';

  // Additional script to run after page load
  static const String postLoadDesktopScript = '''
    (function() {
      // Remove mobile-specific classes and add desktop classes
      document.body.classList.remove('mobile', 'tablet');
      document.body.classList.add('desktop');
      
      // Force desktop layout
      const body = document.body;
      body.style.minWidth = '1200px';
      body.style.overflowX = 'auto';
      
      // Hide mobile elements
      const mobileElements = document.querySelectorAll('.mobile-only, .mobile, [class*="mobile"]');
      mobileElements.forEach(el => {
        if (el.classList.contains('mobile-only') || el.classList.contains('mobile')) {
          el.style.display = 'none';
        }
      });
      
      // Show desktop elements
      const desktopElements = document.querySelectorAll('.desktop-only, .desktop, [class*="desktop"]');
      desktopElements.forEach(el => {
        if (el.classList.contains('desktop-only') || el.classList.contains('desktop')) {
          el.style.display = 'block';
        }
      });
      
      // Trigger resize event to update layout
      window.dispatchEvent(new Event('resize'));
    })();
  ''';
}
