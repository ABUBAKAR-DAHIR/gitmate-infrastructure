#!/bin/bash

set -e
echo "===== BACKEND SERVER SETUP STARTED ====="

apt-get update -y

apt-get -y install git curl nodejs npm

npm install -g pnpm@10.20.0
npm install -g pm2

mkdir -p /root/.ssh

cat > /root/.ssh/id_ed25519 <<EOF 
${git_private_key}
EOF

chmod 600 /root/.ssh/id_ed25519

ssh-keyscan github.com >> /root/.ssh/known_hosts

cat > /root/.ssh/config <<EOF
Host            github.com
Hostname        github.com
User            git
IdentityFile    /root/.ssh/id_ed25519
IdentitiesOnly  yes 
EOF

chmod 600 /root/.ssh/config

mkdir -p /var/www
cd /var/www

git clone git@github.com:ABUBAKAR-DAHIR/gitmate-backend.git gitmate


cd /var/www/gitmate

pnpm install --frozen-lockfile --config.minimum-release-age=0

pnpm build

cat > /var/www/gitmate/.env <<'ENV_FILE'
${backend_env}
ENV_FILE

pm2 start dist/src/main.js --name "gitmate"

pm2 save

# Configure PM2 to start after reboot
pm2 startup systemd -u root --hp /root

chown -R ubuntu:ubuntu /var/www/gitmate
echo "===== BACKEND SERVER SETUP COMPLETED ====="