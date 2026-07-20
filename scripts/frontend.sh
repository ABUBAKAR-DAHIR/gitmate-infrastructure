#!/bin/bash

set -euxo pipefail

echo "===== FRONTEND SERVER SETUP STARTED ====="

echo "Update machine"
apt-get update -y
# echo "Upgrade machine"
# apt upgrade -y

echo "Installing git curl nginx nodejs and npm"
apt-get -y install git curl nginx nodejs npm

echo "Installing pm2"
npm -y install -g pm2

echo "Installing pnpm"
npm -y install -g pnpm@10.20.0


echo "creating root ssh"
mkdir -p /root/.ssh

echo "creating id_ed25519 file"
cat > /root/.ssh/id_ed25519 << 'EOF' 
${git_private_key}
EOF

chmod 600 /root/.ssh/id_ed25519

echo "adding github to known hosts"
ssh-keyscan github.com >> /root/.ssh/known_hosts

echo "adding github to config"
cat > /root/.ssh/config <<EOF
Host            github.com
Hostname        github.com
User            git
IdentityFile    /root/.ssh/id_ed25519
IdentitiesOnly  yes 
EOF

chmod 600 /root/.ssh/config

echo "Navigating to /var/www"
mkdir -p /var/www
cd /var/www

echo "Cloning the repo"
git clone git@github.com:ABUBAKAR-DAHIR/gitmate.git gitmate

cd /var/www/gitmate

echo "===== PNPM DEBUG ============================="
pnpm --version
pnpm config list
cat pnpm-workspace.yaml
echo "=============================================="

echo "Installing dependencies"
pnpm install --frozen-lockfile --config.minimum-release-age=0


# echo "approve builds"
# pnpm approve-builds

echo "Running the build"
pnpm run build

echo "Starting the app with pm2"
pm2 start pnpm --name "gitmate" -- run start

echo "adding pm2 to startup"
pm2 startup systemd -u root  --hp /root

echo "Saving the app with pm2"
pm2 save

echo "Creating the nginx config file for gitmate"
# Configure Nginx
cat > /etc/nginx/sites-available/gitmate <<'EOF'
server {
    listen 80;
    listen [::]:80;

    server_name _;

    location /api/ {
        proxy_pass http://10.0.2.10:5000;

        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        proxy_pass http://127.0.0.1:4173;

        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

echo "Enable nginx"
# Enable Nginx
rm -f /etc/nginx/sites-enabled/default

echo "Create nginx hard link"
ln -s /etc/nginx/sites-available/gitmate \
      /etc/nginx/sites-enabled/gitmate

# Test Nginx
nginx -t

echo "Enable and restart nginx"
# Enable and restart Nginx
systemctl enable nginx
systemctl restart nginx

mkdir -p /home/ubuntu/.ssh

cat > /home/ubuntu/.ssh/gitmate.pem << 'EOF'
${backend_ssh_key}
EOF

chmod 600 /home/ubuntu/.ssh/gitmate.pem

echo "adding backend ip to known hosts"
ssh-keyscan -H 10.0.2.10 >> /home/ubuntu/.ssh/known_hosts

chown ubuntu:ubuntu /home/ubuntu/.ssh/gitmate.pem

echo "adding backend ip to config"
cat > /home/ubuntu/.ssh/config <<EOF
Host            10.0.2.10
Hostname        10.0.2.10
User            ubuntu
IdentityFile    /home/ubuntu/.ssh/gitmate.pem
IdentitiesOnly  yes 
EOF

chmod 600 /home/ubuntu/.ssh/config
chown ubuntu:ubuntu /home/ubuntu/.ssh/config


echo "===== FRONTEND SERVER SETUP COMPLETED ====="