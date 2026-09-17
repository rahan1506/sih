const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const ROOT_DIR = __dirname;
const REF_DIR = path.join(ROOT_DIR, 'reference');

const MIME_TYPES = {
    '.html': 'text/html; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.js': 'application/javascript; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.webp': 'image/webp',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.mp4': 'video/mp4',
    '.webm': 'video/webm',
    '.ico': 'image/x-icon',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
    '.ttf': 'font/ttf',
    '.otf': 'font/otf',
    '.sql': 'text/plain; charset=utf-8',
    '.txt': 'text/plain; charset=utf-8'
};

function resolveFilePath(urlPath) {
    // Strip query string and hash
    const cleanUrl = decodeURIComponent(urlPath.split('?')[0].split('#')[0]);

    if (cleanUrl === '/' || cleanUrl === '/index.html') {
        return path.join(REF_DIR, 'ref.html');
    }
    if (cleanUrl === '/reference' || cleanUrl === '/reference/') {
        return path.join(REF_DIR, 'ref.html');
    }

    // Direct path relative to ROOT_DIR
    const targetInRoot = path.join(ROOT_DIR, cleanUrl);
    if (fs.existsSync(targetInRoot) && fs.statSync(targetInRoot).isFile()) {
        return targetInRoot;
    }

    // Direct path relative to REF_DIR (allows /login.html, /worker-login.html, etc.)
    const targetInRef = path.join(REF_DIR, cleanUrl.replace(/^\/reference\//, '/'));
    if (fs.existsSync(targetInRef) && fs.statSync(targetInRef).isFile()) {
        return targetInRef;
    }

    // Also try without leading slash relative to REF_DIR
    const altInRef = path.join(REF_DIR, cleanUrl.replace(/^\//, ''));
    if (fs.existsSync(altInRef) && fs.statSync(altInRef).isFile()) {
        return altInRef;
    }

    return null;
}

const server = http.createServer((req, res) => {
    // Add CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', '*');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    if (req.method !== 'GET' && req.method !== 'HEAD') {
        res.writeHead(405, { 'Content-Type': 'text/plain' });
        res.end('Method Not Allowed');
        return;
    }

    const filePath = resolveFilePath(req.url);

    if (!filePath || !fs.existsSync(filePath)) {
        res.writeHead(404, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(`<!DOCTYPE html><html><head><title>404 Not Found</title></head><body style="font-family:sans-serif;padding:2rem;text-align:center;background:#F4ECDC;color:#221812;"><h1>404 Not Found</h1><p>The requested file <code>${req.url}</code> was not found.</p><p><a href="/" style="color:#C15A2E;font-weight:bold;">Return to UNIVO Home</a></p></body></html>`);
        return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';
    const stat = fs.statSync(filePath);
    const fileSize = stat.size;

    // Support HTTP Range requests for videos
    const range = req.headers.range;
    if (range && (ext === '.mp4' || ext === '.webm')) {
        const parts = range.replace(/bytes=/, "").split("-");
        const start = parseInt(parts[0], 10);
        const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;

        if (start >= fileSize) {
            res.writeHead(416, {
                'Content-Range': `bytes */${fileSize}`
            });
            res.end();
            return;
        }

        const chunksize = (end - start) + 1;
        const fileStream = fs.createReadStream(filePath, { start, end });

        res.writeHead(206, {
            'Content-Range': `bytes ${start}-${end}/${fileSize}`,
            'Accept-Ranges': 'bytes',
            'Content-Length': chunksize,
            'Content-Type': contentType,
            'Cache-Control': 'no-cache'
        });

        fileStream.pipe(res);
    } else {
        res.writeHead(200, {
            'Content-Length': fileSize,
            'Content-Type': contentType,
            'Accept-Ranges': 'bytes',
            'Cache-Control': 'no-cache'
        });

        if (req.method === 'HEAD') {
            res.end();
            return;
        }

        fs.createReadStream(filePath).pipe(res);
    }
});

server.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`  UNIVO Web Application Server is running!`);
    console.log(`  Local URL: http://localhost:${PORT}`);
    console.log(`  Reference Root: ${REF_DIR}`);
    console.log(`====================================================`);
});
