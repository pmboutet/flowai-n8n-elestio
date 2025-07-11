const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const app = express();
const port = 3000;

// Setup multer for file uploads
const upload = multer({ dest: '/tmp/uploads/' });

app.use(express.json());
app.use(express.static('/app/shared'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'md2slides' });
});

// Convert markdown to Google Slides
app.post('/convert', upload.single('file'), async (req, res) => {
  try {
    const { title, presentationId, erase } = req.body;
    
    if (!req.file) {
      return res.status(400).json({ error: 'No markdown file provided' });
    }

    // Build command
    let cmd = `md2gslides "${req.file.path}"`;
    
    if (title) {
      cmd += ` --title "${title}"`;
    }
    
    if (presentationId) {
      cmd += ` --append "${presentationId}"`;
    }
    
    if (erase === 'true') {
      cmd += ` --erase`;
    }

    // Set Google credentials from environment
    const credentials = process.env.GOOGLE_CREDENTIALS_JSON;
    if (credentials) {
      const credPath = '/tmp/google_credentials.json';
      fs.writeFileSync(credPath, credentials);
      process.env.GOOGLE_APPLICATION_CREDENTIALS = credPath;
    }

    // Execute command
    const output = execSync(cmd, { 
      encoding: 'utf8',
      cwd: '/app',
      timeout: 60000 // 1 minute timeout
    });

    // Clean up uploaded file
    fs.unlinkSync(req.file.path);

    // Extract presentation ID from output
    const idMatch = output.match(/https:\/\/docs\.google\.com\/presentation\/d\/([a-zA-Z0-9-_]+)/);
    const slideId = idMatch ? idMatch[1] : null;

    res.json({
      success: true,
      output: output.trim(),
      presentationId: slideId,
      url: idMatch ? idMatch[0] : null
    });

  } catch (error) {
    console.error('Error converting markdown:', error);
    
    // Clean up uploaded file if it exists
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }

    res.status(500).json({
      success: false,
      error: error.message,
      details: error.toString()
    });
  }
});

// Convert markdown from text (POST body)
app.post('/convert-text', async (req, res) => {
  try {
    const { markdown, title, presentationId, erase } = req.body;
    
    if (!markdown) {
      return res.status(400).json({ error: 'No markdown content provided' });
    }

    // Write markdown to temp file
    const tempFile = `/tmp/markdown_${Date.now()}.md`;
    fs.writeFileSync(tempFile, markdown);

    // Build command
    let cmd = `md2gslides "${tempFile}"`;
    
    if (title) {
      cmd += ` --title "${title}"`;
    }
    
    if (presentationId) {
      cmd += ` --append "${presentationId}"`;
    }
    
    if (erase === 'true') {
      cmd += ` --erase`;
    }

    // Set Google credentials from environment
    const credentials = process.env.GOOGLE_CREDENTIALS_JSON;
    if (credentials) {
      const credPath = '/tmp/google_credentials.json';
      fs.writeFileSync(credPath, credentials);
      process.env.GOOGLE_APPLICATION_CREDENTIALS = credPath;
    }

    // Execute command
    const output = execSync(cmd, { 
      encoding: 'utf8',
      cwd: '/app',
      timeout: 60000 // 1 minute timeout
    });

    // Clean up temp file
    fs.unlinkSync(tempFile);

    // Extract presentation ID from output
    const idMatch = output.match(/https:\/\/docs\.google\.com\/presentation\/d\/([a-zA-Z0-9-_]+)/);
    const slideId = idMatch ? idMatch[1] : null;

    res.json({
      success: true,
      output: output.trim(),
      presentationId: slideId,
      url: idMatch ? idMatch[0] : null
    });

  } catch (error) {
    console.error('Error converting markdown:', error);
    
    res.status(500).json({
      success: false,
      error: error.message,
      details: error.toString()
    });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`md2slides service listening on port ${port}`);
});
