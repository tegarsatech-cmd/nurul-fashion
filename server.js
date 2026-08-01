const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = 8000;
const mime = {
  ".html": "text/html",
  ".js": "application/javascript",
  ".css": "text/css",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".json": "application/json",
};

http
  .createServer((req, res) => {
    let url = req.url === "/" ? "/index.html" : req.url;
    let fp = path.join(__dirname, url);

    fs.readFile(fp, (err, data) => {
      if (err) {
        res.writeHead(404, { "Content-Type": "text/html" });
        res.end("<h1>404 - File not found</h1>");
        return;
      }
      const ext = path.extname(fp);
      res.writeHead(200, {
        "Content-Type": mime[ext] || "text/plain",
        "Cache-Control": "no-cache",
      });
      res.end(data);
    });
  })
  .listen(PORT, () => {
    console.log("Server berjalan di: http://localhost:" + PORT);
    console.log("Buka admin: http://localhost:" + PORT + "/admin.html");
  });

