#!/bin/bash
set -e

APP_DIR="/var/www/muro-sinav-sistemi"
PM2_NAME="muro-sinav"

echo "🚀 Deploy başlıyor..."
cd "$APP_DIR"

echo "📥 Git pull..."
git pull

echo "📦 Build alınıyor..."
npm run build

echo "🔧 Server wrapper oluşturuluyor..."
cat > .next/standalone/server-wrapper.js << 'WRAPPER'
// LiteSpeed duplicate Origin header fix
const http = require('http');
const originalCreateServer = http.createServer.bind(http);
http.createServer = function(options, requestListener) {
  let handler = requestListener;
  if (typeof options === 'function') { handler = options; options = {}; }
  const wrappedHandler = function(req, res) {
    if (req.headers['origin'] && req.headers['origin'].includes(','))
      req.headers['origin'] = req.headers['origin'].split(',')[0].trim();
    return handler(req, res);
  };
  if (typeof options === 'object' && options !== null && !(options instanceof http.IncomingMessage))
    return originalCreateServer(options, wrappedHandler);
  return originalCreateServer(wrappedHandler);
};
require('./server.js');
WRAPPER

echo "📂 Static dosyalar kopyalanıyor..."
cp -r .next/static .next/standalone/.next/static
cp -r public/. .next/standalone/public/

echo "♻️  PM2 yeniden başlatılıyor..."
pm2 restart "$PM2_NAME"

echo "✅ Deploy tamamlandı!"
pm2 status
