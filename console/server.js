#!/usr/bin/env node
// Local-only console server: serves the frontend and exposes a small API to
// list scenarios (parsed from their README.md), and to run each scenario's
// setup.sh / verify.sh on your real cluster.
//
// SECURITY: this process can execute shell scripts on your machine on
// request from the browser. It binds to 127.0.0.1 only and must never be
// exposed beyond localhost (no port-forwarding, no reverse proxy, no
// "--host 0.0.0.0"). Treat it like you'd treat any local dev server that can
// run shell commands.

const http = require("http");
const fs = require("fs");
const path = require("path");
const { execFile } = require("child_process");

const PORT = process.env.CONSOLE_PORT || 7680;
const HOST = "127.0.0.1";
const LAB_DIR = path.join(__dirname, "..", "lab");
const PUBLIC_DIR = path.join(__dirname, "public");

const DOMAIN_NAMES = {
  "01-core-infra-cni": "Core Infrastructure and CNI",
  "02-service-networking-dns": "Service Networking and DNS",
  "03-advanced-traffic": "Advanced Traffic Management",
  "04-network-security-policy": "Network Security and Policy",
  "05-observability": "Observability",
};

// Parses a scenario README.md into { title, sections: {heading: bodyText} }.
function parseReadme(content) {
  const lines = content.split("\n");
  let title = "";
  const sections = {};
  let current = null;
  let buf = [];

  function flush() {
    if (current) sections[current] = buf.join("\n").trim();
    buf = [];
  }

  for (const line of lines) {
    const h1 = line.match(/^#\s+(.*)/);
    const h2 = line.match(/^##\s+(.*)/);
    if (h1 && !title) {
      title = h1[1].replace(/^Scenario:\s*/i, "").trim();
      continue;
    }
    if (h2) {
      flush();
      current = h2[1].trim();
      continue;
    }
    if (current) buf.push(line);
  }
  flush();
  return { title, sections };
}

function listScenarios() {
  const out = [];
  if (!fs.existsSync(LAB_DIR)) return out;
  for (const domainDir of fs.readdirSync(LAB_DIR).sort()) {
    const domainPath = path.join(LAB_DIR, domainDir);
    if (!fs.statSync(domainPath).isDirectory()) continue;
    const domainName = DOMAIN_NAMES[domainDir] || domainDir;
    for (const scenarioDir of fs.readdirSync(domainPath).sort()) {
      const scenarioPath = path.join(domainPath, scenarioDir);
      const readmePath = path.join(scenarioPath, "README.md");
      if (!fs.existsSync(readmePath)) continue;
      const { title, sections } = parseReadme(fs.readFileSync(readmePath, "utf8"));
      out.push({
        id: `${domainDir}/${scenarioDir}`,
        domain: domainName,
        title: title || scenarioDir,
        context: sections["Context"] || "",
        objective: sections["Objective"] || "",
        definitionOfDone: sections["Definition of done"] || "",
        hasSetup: fs.existsSync(path.join(scenarioPath, "setup.sh")),
        hasVerify: fs.existsSync(path.join(scenarioPath, "verify.sh")),
      });
    }
  }
  return out;
}

function safeScenarioDir(id) {
  // id must be "<domain-dir>/<scenario-dir>", both plain slugs — reject
  // anything with path traversal or unexpected characters before touching
  // the filesystem.
  if (typeof id !== "string" || !/^[a-zA-Z0-9_-]+\/[a-zA-Z0-9_-]+$/.test(id)) {
    return null;
  }
  const dir = path.join(LAB_DIR, id);
  const resolved = path.resolve(dir);
  if (!resolved.startsWith(path.resolve(LAB_DIR) + path.sep)) return null;
  if (!fs.existsSync(resolved)) return null;
  return resolved;
}

function runScript(dir, script, res) {
  const scriptPath = path.join(dir, script);
  if (!fs.existsSync(scriptPath)) {
    res.writeHead(404, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: `${script} not found` }));
    return;
  }
  execFile(scriptPath, [], { cwd: dir, timeout: 120000, maxBuffer: 4 * 1024 * 1024 }, (err, stdout, stderr) => {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({
      ok: !err,
      exitCode: err ? (err.code ?? 1) : 0,
      output: (stdout || "") + (stderr || ""),
    }));
  });
}

function serveStatic(req, res) {
  let urlPath = req.url === "/" ? "/index.html" : req.url;
  urlPath = urlPath.split("?")[0];
  const filePath = path.join(PUBLIC_DIR, urlPath);
  const resolved = path.resolve(filePath);
  if (!resolved.startsWith(path.resolve(PUBLIC_DIR) + path.sep) && resolved !== path.resolve(PUBLIC_DIR, "index.html")) {
    res.writeHead(403); res.end("Forbidden"); return;
  }
  fs.readFile(resolved, (err, data) => {
    if (err) { res.writeHead(404); res.end("Not found"); return; }
    const ext = path.extname(resolved);
    const types = { ".html": "text/html", ".js": "application/javascript", ".css": "text/css" };
    res.writeHead(200, { "Content-Type": types[ext] || "application/octet-stream" });
    res.end(data);
  });
}

const server = http.createServer((req, res) => {
  if (req.url === "/api/scenarios" && req.method === "GET") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(listScenarios()));
    return;
  }

  if ((req.url === "/api/verify" || req.url === "/api/setup") && req.method === "POST") {
    let body = "";
    req.on("data", (c) => (body += c));
    req.on("end", () => {
      let id;
      try { id = JSON.parse(body).id; } catch (e) { id = null; }
      const dir = safeScenarioDir(id);
      if (!dir) {
        res.writeHead(400, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ error: "invalid scenario id" }));
        return;
      }
      runScript(dir, req.url === "/api/verify" ? "verify.sh" : "setup.sh", res);
    });
    return;
  }

  serveStatic(req, res);
});

server.listen(PORT, HOST, () => {
  console.log(`CKNE console running at http://${HOST}:${PORT} (localhost only)`);
});
