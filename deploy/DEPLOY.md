# Amaan Academy — VPS deploy (static site, follows the Scalaro playbook)

VPS: `root@209.145.55.76` · key `~/.ssh/orion_vps` · shared nginx at `/opt/scalaro/`

This is a **static site**, so the container is just nginx serving the files. The shared
Scalaro nginx reverse-proxies `amaanacademy.com` → `amaanacademy-app:80`.

## First-time setup

```bash
# 1. SSH in
ssh -i ~/.ssh/orion_vps root@209.145.55.76

# 2. Get the code (repo already on GitHub)
mkdir -p /opt/amaanacademy && cd /opt/amaanacademy
git clone https://github.com/yaseenishfaqjan/amaanacademy.git .

# 3. Build the image ON the VPS (no Docker Hub needed)
docker build -t amaanacademy:latest .
#    (edit docker-compose.yml image: to  amaanacademy:latest  if building locally)

# 4. Confirm the scalaro network name
docker network ls | grep scalaro     # expect: scalaro-net

# 5. Start the container
docker compose up -d
docker compose ps

# 6. TEST the container before touching DNS/nginx:
docker run --rm --network scalaro-net curlimages/curl -s -o /dev/null -w "%{http_code}\n" http://amaanacademy-app:80/
#    -> 200 means the site serves correctly inside the network
```

## Go live (cutover from cPanel)

```bash
# 7. Point DNS A records @ and www -> 209.145.55.76, then verify:
nslookup amaanacademy.com     # must return 209.145.55.76

# 8. Issue SSL (webroot; needs DNS already pointing here)
mkdir -p /var/www/certbot
certbot certonly --webroot -w /var/www/certbot \
  -d amaanacademy.com -d www.amaanacademy.com \
  --email yasinishfaq5@gmail.com --agree-tos --non-interactive

# 9. Add deploy/scalaro-amaanacademy.conf into /opt/scalaro/nginx.conf, then:
cd /opt/scalaro && docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload

# 10. Verify
curl -I https://amaanacademy.com     # HTTP/2 200
```

## Updates (next time)

```bash
ssh -i ~/.ssh/orion_vps root@209.145.55.76 \
  "cd /opt/amaanacademy && git pull origin main && docker build -t amaanacademy:latest . && docker compose up -d"
```
