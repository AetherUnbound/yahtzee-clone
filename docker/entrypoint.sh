#!/bin/sh
set -e

# Create runtime config file with environment variable
cat > /usr/share/nginx/html/config.js <<EOF
window.ENV = {
  VITE_API_URL: "${VITE_API_URL}"
};
EOF

echo "Configured API URL: ${VITE_API_URL:-(relative, proxied by nginx)}"

# Start nginx
exec nginx -g 'daemon off;'
