# QCAR Quick Start Guide

Get the Qcar system running in under 10 minutes.

## Prerequisites Checklist

- [ ] Java JDK 17+ installed
- [ ] MySQL 8.0+ installed and running
- [ ] Maven 3.6+ installed
- [ ] Web browser
- [ ] Text editor (VS Code, IntelliJ, etc.)

## Quick Start (5 Steps)

### Step 1: Clone or Download Project
```bash
# If using Git
git clone https://github.com/yourusername/qcar-system.git
cd qcar-system

# Or extract downloaded ZIP
unzip qcar-system.zip
cd qcar-system
```

### Step 2: Setup Database
```bash
# Login to MySQL
mysql -u root -p

# Run these commands in MySQL prompt
source database/schema.sql
exit;

# Verify database
mysql -u root -p -e "USE qcar_db; SHOW TABLES;"
```

Expected output:
```
+-------------------+
| Tables_in_qcar_db |
+-------------------+
| admins            |
| cars              |
+-------------------+
```

### Step 3: Configure Backend
```bash
# Edit backend/application.properties
# Update these lines:

spring.datasource.password=your_mysql_password
app.base.url=http://localhost:8080
```

### Step 4: Run Backend
```bash
cd backend

# Build and run
mvn spring-boot:run

# Wait for: "Started QcarApplication in X seconds"
```

### Step 5: Open Frontend
```bash
# In a new terminal
cd frontend
python -m http.server 3000

# Or use Node.js
npx http-server -p 3000
```

**Access Application:**
- Login: http://localhost:3000/login.html
- Credentials: `admin` / `admin123`

---

## Your First Car Registration

1. **Login** at http://localhost:3000/login.html
   - Username: `admin`
   - Password: `admin123`

2. **Fill the Form:**
   - Unit Number: `A-101`
   - Owner Name: `John Doe`
   - Car Number: `MH-01-AB-1234`
   - Type: `Owner`

3. **Click "Register Car"**

4. **Download QR Code:**
   - Click "Download QR" button
   - PDF will download automatically

5. **Test QR Code:**
   - Open the PDF
   - Scan QR with phone camera
   - View car details page

---

## Project Structure at a Glance

```
qcar-system/
│
├── backend/                    # Spring Boot application
│   ├── *.java                  # Java source files
│   ├── pom.xml                 # Maven dependencies
│   └── application.properties  # Configuration
│
├── frontend/                   # Web interface
│   ├── login.html             # Admin login
│   ├── dashboard.html         # Car management
│   ├── car-details.html       # Public view (Thymeleaf)
│   └── error.html             # Error page
│
├── database/
│   └── schema.sql             # Database schema
│
└── Documentation
    ├── README.md
    ├── API_DOCUMENTATION.md
    └── DEPLOYMENT.md
```

---

## Common Commands

### Start MySQL
```bash
# Linux/Mac
sudo systemctl start mysql

# Windows
net start MySQL80
```

### Check if Backend is Running
```bash
curl http://localhost:8080/health
# or visit in browser
```

### View Backend Logs
```bash
# In the terminal where you ran mvn spring-boot:run
# Logs appear in real-time
```

### Stop Backend
```bash
# Press Ctrl+C in the terminal running Spring Boot
```

### Reset Database
```bash
mysql -u root -p -e "DROP DATABASE qcar_db;"
mysql -u root -p < database/schema.sql
```

---

## Troubleshooting Quick Fixes

### Problem: Port 8080 already in use
**Solution:**
```properties
# Change in application.properties
server.port=8081

# Update in frontend files
const API_BASE = 'http://localhost:8081/api';
```

### Problem: MySQL connection failed
**Solutions:**
1. Check MySQL is running: `sudo systemctl status mysql`
2. Verify credentials in `application.properties`
3. Test connection: `mysql -u root -p`

### Problem: Cannot build Maven project
**Solution:**
```bash
# Clean and rebuild
mvn clean install -U

# Skip tests if they fail
mvn clean install -DskipTests
```

### Problem: Frontend not loading
**Solutions:**
1. Check if running on correct port: `http://localhost:3000`
2. Clear browser cache
3. Check browser console for errors (F12)

### Problem: QR code not generating
**Solution:**
```bash
# Ensure ZXing dependency is present
mvn dependency:tree | grep zxing

# If missing, run:
mvn clean install
```

---

## Default Credentials

| Service  | Username | Password   |
|----------|----------|------------|
| Admin    | admin    | admin123   |
| MySQL    | root     | (your pwd) |

**⚠️ Change these in production!**

---

## Key URLs

| Page                | URL                              |
|---------------------|----------------------------------|
| Admin Login         | http://localhost:3000/login.html |
| Dashboard           | http://localhost:3000/dashboard.html |
| API Base            | http://localhost:8080/api        |
| Public Car Details  | http://localhost:8080/car/{qrId} |

---

## Development Workflow

### Making Changes to Backend

1. **Edit Java files** in `backend/` directory
2. **Stop the server** (Ctrl+C)
3. **Restart:** `mvn spring-boot:run`
4. **Test changes** in browser

### Making Changes to Frontend

1. **Edit HTML/CSS/JS** files in `frontend/`
2. **Refresh browser** (F5)
3. **Changes appear immediately** (no restart needed)

### Adding New Features

1. **Backend:** Create new controller/service
2. **Frontend:** Add new HTML page or update existing
3. **Database:** Update schema.sql if needed
4. **Test:** Run full workflow

---

## Testing Checklist

- [ ] Backend starts without errors
- [ ] Can login with default credentials
- [ ] Can register a car
- [ ] Car appears in table
- [ ] Can download PDF
- [ ] PDF contains QR code
- [ ] QR code scans correctly
- [ ] Public page displays car details
- [ ] Can logout

---

## Next Steps

### Basic Customization
1. **Change Colors:** Edit CSS in HTML files
2. **Update Logo:** Modify `.logo` class
3. **Add Fields:** Update Car model and forms

### Advanced Features
1. **Add Search:** Filter cars by number/owner
2. **Export Data:** Add Excel export
3. **Bulk Upload:** CSV import feature
4. **Analytics:** Dashboard statistics

### Production Deployment
1. Read `DEPLOYMENT.md`
2. Setup SSL certificate
3. Configure production database
4. Enable password hashing
5. Setup backups

---

## Learning Resources

### Spring Boot
- Official Guide: https://spring.io/guides
- Rest API Tutorial: https://spring.io/guides/gs/rest-service/

### QR Codes
- ZXing Documentation: https://github.com/zxing/zxing

### MySQL
- MySQL Tutorial: https://dev.mysql.com/doc/

### Frontend
- Bootstrap 5: https://getbootstrap.com/docs/5.3
- JavaScript Fetch API: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API

---

## Get Help

### Check Logs First
```bash
# Backend logs
# Check terminal where Spring Boot is running

# MySQL logs
sudo tail -f /var/log/mysql/error.log

# Nginx logs (if using)
sudo tail -f /var/log/nginx/error.log
```

### Debug Mode
```properties
# Add to application.properties
logging.level.com.qcar=DEBUG
spring.jpa.show-sql=true
```

### Contact Support
- Documentation: See README.md
- API Reference: See API_DOCUMENTATION.md
- Deployment: See DEPLOYMENT.md

---

## Useful Snippets

### Create New Admin
```sql
INSERT INTO admins (username, password) 
VALUES ('newadmin', 'password123');
```

### View All Cars
```sql
SELECT * FROM cars ORDER BY created_at DESC;
```

### Delete Test Data
```sql
DELETE FROM cars WHERE car_number LIKE 'TEST%';
```

### Change Car Type
```sql
UPDATE cars 
SET type = 'Owner', qr_color = '#00008B' 
WHERE car_number = 'MH-01-AB-1234';
```

---

## Environment Variables (Optional)

Instead of hardcoding in `application.properties`:

```bash
# Linux/Mac
export DB_PASSWORD=mypassword
export APP_BASE_URL=http://localhost:8080

# Windows
set DB_PASSWORD=mypassword
set APP_BASE_URL=http://localhost:8080
```

Then use in `application.properties`:
```properties
spring.datasource.password=${DB_PASSWORD}
app.base.url=${APP_BASE_URL}
```

---

## Docker Setup (Optional)

Create `Dockerfile`:
```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/qcar-system-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: qcar_db
    ports:
      - "3306:3306"
  
  app:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - mysql
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/qcar_db
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: rootpassword
```

Run:
```bash
docker-compose up
```

---

## Success Criteria

You've successfully set up Qcar when:
✅ Backend starts on port 8080
✅ Frontend loads in browser
✅ You can login as admin
✅ You can register a car
✅ QR code downloads as PDF
✅ Scanning QR shows car details

**Time to complete: 5-10 minutes**

---

## What's Next?

1. **Explore the Code:** Understand how it works
2. **Customize Design:** Make it yours
3. **Add Features:** Extend functionality
4. **Deploy:** Put it in production
5. **Share:** Help others learn

Happy Coding! 🚀
