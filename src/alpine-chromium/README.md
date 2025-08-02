# Chromium on Alpine (alpine-chromium)

Installs minimal Chromium browser and ChromeDriver optimized for automated testing and web development on Alpine Linux. Designed for CI/CD, automated testing, and web scraping scenarios with testing frameworks like Puppeteer, Playwright, and Selenium.

## Example Usage

```json
"features": {
    "ghcr.io/ausginer/alpine-features/alpine-chromium:1": {}
}
```

## Options

This feature currently has no configurable options.

## What's Installed

This feature installs:
- **Chromium browser** - Latest stable Chromium for testing and automation
- **ChromeDriver** - WebDriver for automated testing with Selenium

Add this to your `devcontainer.json`:
```json
"features": {
    "ghcr.io/devcontainers/features/common-utils": {},
    "ghcr.io/ausginer/alpine-features/alpine-chromium:1": {}
}
```

## Use Cases

### Automated Testing
- Selenium WebDriver tests
- Puppeteer automation  
- Playwright end-to-end testing
- Jest browser testing

### CI/CD Pipelines
- Automated screenshot generation
- Visual regression testing
- Performance testing
- Accessibility testing

### Web Scraping & Automation
- Automated data collection
- Content extraction
- API testing with browser context

## Examples

### Basic Installation
```json
"features": {
    "ghcr.io/devcontainers/features/common-utils": {},
    "ghcr.io/ausginer/alpine-features/alpine-chromium:1": {}
}
```

### With Node.js for Testing
```json
"features": {
    "ghcr.io/devcontainers/features/common-utils": {},
    "ghcr.io/ausginer/alpine-features/alpine-node:1": {
        "nodeVersion": "18"
    },
    "ghcr.io/ausginer/alpine-features/alpine-chromium:1": {}
}
```

## Running Chromium

### With Testing Frameworks
Testing frameworks like Puppeteer and Playwright will handle headless mode automatically:

```javascript
// Puppeteer - handles headless automatically
const browser = await puppeteer.launch({
  executablePath: process.env.CHROME_BIN
});

// Playwright - explicit headless control
const browser = await chromium.launch({ 
  headless: true,
  executablePath: process.env.CHROME_BIN 
});
```

### Manual Testing
```bash
# For debugging with visible browser (requires X11)
chromium-browser --no-sandbox

# For headless automation
chromium-browser --headless --no-sandbox --dump-dom https://example.com
```

### With ChromeDriver
```bash
# Start ChromeDriver for WebDriver automation
chromedriver --port=9515 &

# Use with testing frameworks
CHROME_BIN=/usr/bin/chromium-browser npm test
```

## Environment Variables

The following environment variables are automatically configured:
- `CHROME_BIN=/usr/bin/chromium-browser` - For testing frameworks
- `CHROME_PATH=/usr/lib/chromium/` - Chromium installation path
- `CHROMIUM_FLAGS` - Optimized flags for testing environments:
  - `--no-sandbox` - Required for containerized environments
  - `--disable-gpu` - Disable GPU acceleration for headless testing
  - `--disable-dev-shm-usage` - Use `/tmp` instead of `/dev/shm` for shared memory
  - `--disable-extensions` - Disable browser extensions
  - `--disable-background-timer-throttling` - Prevent background tab throttling
  - `--disable-backgrounding-occluded-windows` - Prevent occluded window backgrounding
  - `--disable-renderer-backgrounding` - Prevent renderer backgrounding
  - `--remote-debugging-port=9222` - Enable remote debugging on port 9222

## Implementation Details

This feature:
- Installs minimal Chromium without GUI dependencies
- Includes ChromeDriver matching the Chromium version
- Provides optimized configuration for testing frameworks
- Sets environment variables for testing frameworks
- Uses official Alpine Linux packages only
- Lets testing frameworks (Puppeteer, Playwright) control headless mode

## Testing Framework Integration

### Puppeteer
```javascript
const puppeteer = require('puppeteer');

// Puppeteer handles headless mode automatically
const browser = await puppeteer.launch({
  executablePath: process.env.CHROME_BIN,
  args: ['--no-sandbox', '--disable-dev-shm-usage']
});
```

### Playwright
```javascript
const { chromium } = require('playwright');

// Explicit headless control with Playwright
const browser = await chromium.launch({
  headless: true, // or false for debugging
  executablePath: process.env.CHROME_BIN,
  args: ['--no-sandbox', '--disable-dev-shm-usage']
});
```

### Selenium WebDriver
```javascript
const { Builder } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');

const options = new chrome.Options();
options.addArguments('--headless'); // Explicit headless control
options.addArguments('--no-sandbox', '--disable-dev-shm-usage');
options.setChromeBinaryPath(process.env.CHROME_BIN);

const driver = await new Builder()
  .forBrowser('chrome')
  .setChromeOptions(options)
  .build();
```

## Security Considerations

- Chromium requires `--no-sandbox` flag in containerized environments
- All packages are from official Alpine repositories
- No unnecessary GUI or font dependencies installed
- Minimal attack surface with headless-only configuration

## Limitations

- Requires `--no-sandbox` flag when running in containers
- Audio/video playback not supported
- No font rendering for complex scripts (by design for minimal footprint)
- GUI mode requires X11 forwarding (testing frameworks handle headless automatically)

## Notes

- Compatible with Alpine Linux 3.14+
- Minimal installation focused on testing and automation
- ChromeDriver version automatically matches Chromium version
- Optimized for CI/CD environments
- Testing frameworks control headless/GUI mode as needed
