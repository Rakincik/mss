// server.js — Production Server
const { createServer } = require('http')
const { parse } = require('url')
const next = require('next')

const dev = process.env.NODE_ENV !== 'production'
const port = process.env.PORT || 3000
const app = next({ dev })
const handle = app.getRequestHandler()

app.prepare().then(() => {
  createServer((req, res) => {
    const parsedUrl = parse(req.url, true)
    handle(req, res, parsedUrl)
  }).listen(port, (err) => {
    if (err) throw err
    const memMB = Math.round(process.memoryUsage().heapTotal / 1024 / 1024)
    const siteName = process.env.NEXT_PUBLIC_SITE_NAME || 'Muro Sınav Sistemi';
    console.log(`> ✅ ${siteName} hazır`)
    console.log(`> 🌐 http://localhost:${port}`)
    console.log(`> 📦 Mod: ${dev ? 'DEVELOPMENT' : 'PRODUCTION'}`)
    console.log(`> 💾 Heap: ${memMB}MB | Max: ${Math.round((require('v8').getHeapStatistics().heap_size_limit) / 1024 / 1024)}MB`)
  })
})

