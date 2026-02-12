# QCAR Deployment Guide

Complete guide for deploying the Qcar system in production environments.

## Table of Contents
1. [Server Requirements](#server-requirements)
2. [Installation Steps](#installation-steps)
3. [Configuration](#configuration)
4. [Security Hardening](#security-hardening)
5. [Monitoring & Maintenance](#monitoring--maintenance)

## Server Requirements

### Minimum Specifications
- **CPU**: 2 cores
- **RAM**: 4 GB
- **Storage**: 20 GB SSD
- **OS**: Ubuntu 20.04+ / CentOS 8+ / Windows Server 2019+

### Software Requirements
- Java JDK 17 or higher
- MySQL 8.0 or higher
- Nginx or Apache (for reverse proxy)
- SSL Certificate (Let's Encrypt recommended)

## Installation Steps

### 1. Prepare Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Java 17
sudo apt install openjdk-17-jdk -y
java -version

# Install MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation
```

### 2. Setup MySQL Database

```bash
# Login to MySQL
sudo mysql -u root -p

# Create database and user
CREATE DATABASE qcar_db;
CREATE USER 'qcaruser'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT ALL PRIVILEGES ON qcar_db.* TO 'qcaruser'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Import schema
mysql -u qcaruser -p qcar_db < database/schema.sql
```

### 3. Configure Application

Edit `application.properties`:

```properties
# Production Database
spring.datasource.url=jdbc:mysql://localhost:3306/qcar_db
spring.datasource.username=qcaruser
spring.datasource.password=strong_password_here

# Production Port
server.port=8080

# Production URL
app.base.url=https://yourdomain.com

# JPA Settings
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false

# Session Settings
server.servlet.session.timeout=60m
server.servlet.session.cookie.secure=true
server.servlet.session.cookie.http-only=true
```

### 4. Build Application

```bash
# Build JAR
mvn clean package -DskipTests

# Copy JAR to deployment directory
sudo mkdir -p /opt/qcar
sudo cp target/qcar-system-1.0.0.jar /opt/qcar/
```

### 5. Create Systemd Service

Create `/etc/systemd/system/qcar.service`:

```ini
[Unit]
Description=Qcar Application
After=mysql.service

[Service]
Type=simple
User=qcar
ExecStart=/usr/bin/java -jar /opt/qcar/qcar-system-1.0.0.jar
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
# Create service user
sudo useradd -r -s /bin/false qcar
sudo chown -R qcar:qcar /opt/qcar

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable qcar
sudo systemctl start qcar
sudo systemctl status qcar
```

### 6. Setup Nginx Reverse Proxy

Install Nginx:
```bash
sudo apt install nginx -y
```

Create `/etc/nginx/sites-available/qcar`:

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Proxy to Spring Boot
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support (if needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        proxy_pass http://localhost:8080;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/qcar /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 7. Setup SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal is set up automatically
sudo certbot renew --dry-run
```

## Configuration

### Environment-Specific Settings

**Development:**
```properties
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
app.base.url=http://localhost:8080
```

**Production:**
```properties
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
app.base.url=https://yourdomain.com
server.servlet.session.cookie.secure=true
```

### Update Frontend URLs

Edit `login.html` and `dashboard.html`:
```javascript
const API_BASE = 'https://yourdomain.com/api';
```

## Security Hardening

### 1. Password Encryption

Update `AuthController.java` to use BCrypt:

```java
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

// During login
if (passwordEncoder.matches(loginRequest.getPassword(), admin.get().getPassword())) {
    // Login successful
}
```

### 2. Database Security

```sql
-- Create read-only user for reporting
CREATE USER 'qcar_readonly'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON qcar_db.* TO 'qcar_readonly'@'localhost';

-- Restrict remote access
UPDATE mysql.user SET Host='localhost' WHERE User='qcaruser';
FLUSH PRIVILEGES;
```

### 3. Firewall Configuration

```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable

# Block MySQL from outside
sudo ufw deny 3306/tcp
```

### 4. Application Security

Add to `application.properties`:
```properties
# Security headers
server.error.include-message=never
server.error.include-stacktrace=never
server.error.include-exception=false

# Session security
server.servlet.session.cookie.http-only=true
server.servlet.session.cookie.secure=true
server.servlet.session.cookie.same-site=strict
```

### 5. Regular Updates

```bash
# Create update script
cat > /opt/qcar/update.sh << 'EOF'
#!/bin/bash
cd /opt/qcar
sudo systemctl stop qcar
sudo cp qcar-system-1.0.0.jar qcar-system-1.0.0.jar.backup
# Upload new JAR here
sudo systemctl start qcar
sudo systemctl status qcar
EOF

chmod +x /opt/qcar/update.sh
```

## Monitoring & Maintenance

### 1. Application Logs

```bash
# View logs
sudo journalctl -u qcar -f

# Save logs to file
sudo journalctl -u qcar --since today > /var/log/qcar.log
```

### 2. Database Backup

Create backup script `/opt/qcar/backup.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/opt/qcar/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/qcar_backup_$DATE.sql"

mkdir -p $BACKUP_DIR

mysqldump -u qcaruser -p'password' qcar_db > $BACKUP_FILE
gzip $BACKUP_FILE

# Keep only last 30 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_FILE.gz"
```

Setup cron job:
```bash
# Run daily at 2 AM
0 2 * * * /opt/qcar/backup.sh
```

### 3. Health Check Endpoint

Add to Spring Boot application:

```java
@RestController
public class HealthController {
    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "UP");
        status.put("timestamp", LocalDateTime.now().toString());
        return status;
    }
}
```

Setup monitoring:
```bash
# Check every 5 minutes
*/5 * * * * curl -f https://yourdomain.com/health || echo "Qcar is down" | mail -s "Alert" admin@yourdomain.com
```

### 4. Performance Monitoring

Install monitoring tools:
```bash
# Install Prometheus (optional)
# Install Grafana (optional)
# Setup application metrics
```

### 5. Log Rotation

Create `/etc/logrotate.d/qcar`:

```
/var/log/qcar/*.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 qcar qcar
    sharedscripts
    postrotate
        systemctl reload qcar
    endscript
}
```

## Troubleshooting

### Application Won't Start
```bash
# Check logs
sudo journalctl -u qcar -n 100

# Check Java
java -version

# Check database connection
mysql -u qcaruser -p qcar_db
```

### High Memory Usage
```bash
# Limit JVM memory
ExecStart=/usr/bin/java -Xms512m -Xmx2g -jar /opt/qcar/qcar-system-1.0.0.jar
```

### Database Connection Pool Exhausted
Add to `application.properties`:
```properties
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
```

## Rollback Procedure

```bash
# Stop service
sudo systemctl stop qcar

# Restore backup
sudo cp /opt/qcar/qcar-system-1.0.0.jar.backup /opt/qcar/qcar-system-1.0.0.jar

# Restore database
gunzip -c /opt/qcar/backups/qcar_backup_YYYYMMDD.sql.gz | mysql -u qcaruser -p qcar_db

# Start service
sudo systemctl start qcar
```

## Support Contacts

- **Technical Support**: tech@yourdomain.com
- **Emergency**: +1-XXX-XXX-XXXX
- **Documentation**: https://docs.yourdomain.com

---

**Deployment Checklist:**
- [ ] Server prepared and secured
- [ ] Database installed and configured
- [ ] Application built and deployed
- [ ] SSL certificate installed
- [ ] Nginx configured
- [ ] Firewall rules set
- [ ] Backups configured
- [ ] Monitoring enabled
- [ ] Documentation updated
- [ ] Team trained
