# Static site served by nginx. Files are baked into the image.
FROM nginx:alpine

# Container-level nginx config (static serving, real 404, gzip, caching, security headers)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built static site into the web root.
# Deploy-only files are excluded via .dockerignore so the web root stays clean.
COPY . /usr/share/nginx/html

EXPOSE 80
