// tools/generate_assets_manifest.js
// Node script to generate a JSON manifest of files under the 'assets' directory.
// Save and run from the repository root: node tools/generate_assets_manifest.js
// Adjust "assetsDir" if your assets folder is elsewhere.

const fs = require('fs');
const path = require('path');

function walk(dir, cb) {
  fs.readdirSync(dir).forEach(file=>{
    const p = path.join(dir, file);
    if (fs.statSync(p).isDirectory()) walk(p,cb);
    else cb(p);
  });
}

const projectRoot = path.join(__dirname, '..');
const assetsDir = path.join(projectRoot, 'assets'); // adjust if needed
const out = [];
if (fs.existsSync(assetsDir)) {
  walk(assetsDir, p => {
    const rel = path.relative(projectRoot, p).replace(/\\/g, '/');
    out.push(rel);
  });
}
fs.writeFileSync(path.join(projectRoot, 'assets_manifest.json'), JSON.stringify(out, null, 2));
console.log('Wrote assets_manifest.json, entries:', out.length);
