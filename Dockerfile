# Static site served by nginx. Files are baked into the image.
FROM nginx:alpine

# Copy the whole build context into the web root...
COPY . /usr/share/nginx/html

# ...then move the container nginx config into place and remove deploy-only files
# so the web root contains only the actual site.
RUN cp /usr/share/nginx/html/nginx.conf /etc/nginx/conf.d/default.conf \
 && rm -f /usr/share/nginx/html/nginx.conf \
          /usr/share/nginx/html/Dockerfile \
          /usr/share/nginx/html/.dockerignore \
          /usr/share/nginx/html/docker-compose.yml \
          /usr/share/nginx/html/README.md \
 && rm -rf /usr/share/nginx/html/deploy

EXPOSE 80
