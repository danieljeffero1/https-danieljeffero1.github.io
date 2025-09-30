<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Instant Website Generator</title>
  <style>
    body{font-family:system-ui,Segoe UI,Roboto,Helvetica,Arial;max-width:980px;margin:28px auto;padding:18px;color:#0f172a}
    header{display:flex;align-items:center;gap:12px}
    .card{border:1px solid #e6e9ef;padding:14px;border-radius:12px;margin-top:12px}
    label{display:block;margin:10px 0 6px;font-weight:600}
    input,select,textarea{width:100%;padding:10px;border-radius:8px;border:1px solid #d6d9e3}
    button{padding:10px 14px;border-radius:10px;border:0;background:#0b67ff;color:white;font-weight:700;cursor:pointer}
    pre{background:#0b1220;color:#dbeafe;padding:12px;border-radius:8px;white-space:pre-wrap}
  </style>
</head>
<body>
  <header>
    <h1>Instant Website Creator — single file</h1>
  </header>

  <div class="card">
    <label>Project name</label>
    <input id="projectName" placeholder="My Awesome Site" />

    <label>Website type</label>
    <select id="siteType">
      <option value="landing">Landing page</option>
      <option value="portfolio">Portfolio</option>
      <option value="blog">Blog (static)</option>
      <option value="store">Simple store (catalog only)</option>
    </select>

    <label>Short description / prompt for the site (one sentence)</label>
    <input id="prompt" placeholder="A premium minimalist portfolio for an industrial designer" />

    <label>Optional: OpenAI API Key (leave empty to use built-in templates)</label>
    <input id="apiKey" placeholder="sk-... (optional)" />

    <div style="display:flex;gap:8px;margin-top:12px">
      <button id="generateBtn">Generate & Download ZIP</button>
      <button id="previewBtn">Preview Generated index.html</button>
    </div>

    <p style="margin-top:12px;color:#334155">How it works: if you paste an OpenAI API key the generator will ask the model to create personalized copy, structure and metadata for your chosen site type. If you leave it blank it uses built-in templates for immediate offline use.</p>
  </div>

  <div id="previewArea" class="card" style="display:none">
    <h3>Generated index.html (preview)</h3>
    <pre id="previewCode"></pre>
  </div>

  <script>
    // Minimal templates and builder logic. Uses JSZip via CDN when needed.

    const templates = {
      landing: (name, desc) => ({
        'index.html': `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escapeHtml(name)}</title><link rel="stylesheet" href="style.css"></head><body><header class="hero"><div class="wrap"><h1>${escapeHtml(name)}</h1><p>${escapeHtml(desc)}</p><a class="cta" href="#">Get started</a></div></header><main class="content"><section><h2>Features</h2><p>Beautifully simple, fast-loading landing page.</p></section></main><footer>&copy; ${new Date().getFullYear()} ${escapeHtml(name)}</footer><script src="script.js"></script></body></html>`,
        'style.css': `:root{--bg:#f8fafc;--fg:#0f172a;--accent:#0b67ff}body{font-family:system-ui,Segoe UI,Roboto,Helvetica,Arial;margin:0;background:var(--bg);color:var(--fg)}.hero{background:white;padding:96px 16px;text-align:center;box-shadow:0 6px 24px rgba(12,17,24,.06)}.wrap{max-width:900px;margin:0 auto}.cta{display:inline-block;margin-top:12px;padding:12px 18px;border-radius:10px;background:var(--accent);color:white;text-decoration:none;font-weight:700}footer{padding:18px;text-align:center;color:#64748b}`,
        'script.js': `console.log('Welcome to ${escapeJs(name)}');`
      }),

      portfolio: (name, desc) => ({
        'index.html': `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escapeHtml(name)}</title><link rel="stylesheet" href="style.css"></head><body><nav><div class="wrap"><strong>${escapeHtml(name)}</strong></div></nav><header class="hero"><div class="wrap"><h1>${escapeHtml(name)}</h1><p>${escapeHtml(desc)}</p></div></header><main class="grid wrap"><article class="card">Project 1</article><article class="card">Project 2</article></main><footer>&copy; ${new Date().getFullYear()} ${escapeHtml(name)}</footer><script src="script.js"></script></body></html>`,
        'style.css': `body{font-family:system-ui;margin:0;padding:0;background:#fff;color:#0b1220}.wrap{max-width:1000px;margin:0 auto;padding:24px}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:16px}.card{border:1px solid #e6e9ef;padding:18px;border-radius:12px}`,
        'script.js': `console.log('Portfolio ${escapeJs(name)} loaded');`
      }),

      blog: (name, desc) => ({
        'index.html': `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escapeHtml(name)}</title><link rel="stylesheet" href="style.css"></head><body><header class="wrap"><h1>${escapeHtml(name)}</h1><p>${escapeHtml(desc)}</p></header><main class="wrap"><article><h2>First post</h2><p>This is a starter blog post. Replace with your content.</p></article></main><footer class="wrap">&copy; ${new Date().getFullYear()}</footer><script src="script.js"></script></body></html>`,
        'style.css': `.wrap{max-width:760px;margin:0 auto;padding:24px;font-family:system-ui}`,
        'script.js': `console.log('Blog ready')`
      }),

      store: (name, desc) => ({
        'index.html': `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escapeHtml(name)}</title><link rel="stylesheet" href="style.css"></head><body><header class="wrap"><h1>${escapeHtml(name)}</h1><p>${escapeHtml(desc)}</p></header><main class="wrap grid"><div class="product"><h3>Sample product</h3><p>$19.99</p><button>Add</button></div></main><footer class="wrap">&copy; ${new Date().getFullYear()}</footer><script src="script.js"></script></body></html>`,
        'style.css': `.wrap{max-width:900px;margin:0 auto;padding:24px}.grid{display:grid}`,
        'script.js': `console.log('Store demo')`
      })
    };

    function escapeHtml(s){ return (s||'').replace(/[&<>\"]/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
    function escapeJs(s){ return (s||'').replace(/'/g, "\\'").replace(/"/g, '\\"'); }

    async function callOpenAI(prompt, key){
      // Uses OpenAI chat completions (you must supply your own key). This is optional.
      const url = 'https://api.openai.com/v1/chat/completions';
      const body = {
        model: 'gpt-4o-mini',
        messages:[{role:'system',content:'You are a website assistant that returns JSON with short site sections.'},{role:'user',content:prompt}],
        temperature:0.6
      };
      const resp = await fetch(url,{method:'POST',headers:{'Content-Type':'application/json','Authorization':'Bearer '+key},body:JSON.stringify(body)});
      if(!resp.ok) throw new Error('OpenAI error: '+resp.status);
      const data = await resp.json();
      const text = (data.choices && data.choices[0] && data.choices[0].message && data.choices[0].message.content) || '';
      return text;
    }

    document.getElementById('generateBtn').addEventListener('click', async ()=>{
      const name = document.getElementById('projectName').value || 'My Site';
      const type = document.getElementById('siteType').value;
      const prompt = document.getElementById('prompt').value || '';
      const apiKey = document.getElementById('apiKey').value.trim();

      let generated = templates[type](name, prompt || `A ${type} website for ${name}`);

      if(apiKey){
        try{
          const aiPrompt = `Create a short home page headline (one line), a 2-sentence description, and 3 feature bullet points for a ${type} site named "${name}". Keep it concise. Return only JSON: {\"headline\":...,\"description\":...,\"features\":[...]} `;
          const aiText = await callOpenAI(aiPrompt, apiKey);
          // Try to parse JSON from the model output
          const json = JSON.parse(aiText.replace(/^[^\{]*/,'').replace(/\n+$/,''));
          // Inject into the landing template where appropriate
          const idx = generated['index.html'];
          const injected = idx.replace('<p>',`<h2>${escapeHtml(json.headline||'')}</h2><p>${escapeHtml(json.description||prompt)}</p><ul>${(json.features||[]).map(f=>'<li>'+escapeHtml(f)+'</li>').join('')}</ul>`);
          generated['index.html'] = injected;
        }catch(e){
          console.warn('AI step failed, using default templates', e);
        }
      }

      // Build ZIP client-side using JSZip CDN
      try{
        const jszipUrl = 'https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js';
        await loadScript(jszipUrl);
        const zip = new JSZip();
        for(const [nameFile, content] of Object.entries(generated)) zip.file(nameFile, content);
        const blob = await zip.generateAsync({type:'blob'});
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = (document.getElementById('projectName').value || 'site') + '.zip';
        a.click();
      }catch(e){
        // Fallback: offer individual files as data URLs
        for(const [nameFile, content] of Object.entries(generated)){
          const blob = new Blob([content],{type:'text/plain'});
          const link = document.createElement('a');
          link.href = URL.createObjectURL(blob);
          link.download = nameFile;
          link.style.display='none';
          document.body.appendChild(link);
          link.click();
          link.remove();
        }
      }
    });

    document.getElementById('previewBtn').addEventListener('click', ()=>{
      const name = document.getElementById('projectName').value || 'My Site';
      const type = document.getElementById('siteType').value;
      const prompt = document.getElementById('prompt').value || '';
      const generated = templates[type](name, prompt || `A ${type} website for ${name}`);
      document.getElementById('previewCode').textContent = generated['index.html'];
      document.getElementById('previewArea').style.display='block';
    });

    function loadScript(src){
      return new Promise((res,rej)=>{
        if(document.querySelector(`script[src="${src}"]`)) return res();
        const s=document.createElement('script');s.src=src;s.onload=res;s.onerror=rej;document.head.appendChild(s);
      });
    }

  </script>
</body>
</html>
