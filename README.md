# QCAR - Car QR Management System

A full-stack web application for managing car registrations with custom-themed QR codes.

## Features

- **Admin Authentication**: Secure login for administrators
- **Car Registration**: Register cars with unit number, owner name, car number, and type
- **Custom QR Codes**: Auto-generated QR codes with color coding (Maroon for Tenants, Dark Blue for Owners)
- **PDF Export**: Download printable QR code stickers
- **Public View**: Scan QR code to view car details on any device
- **Modern UI**: Clean, responsive interface with gradient designs

## Tech Stack

### Backend
- **Java 17**
- **Spring Boot 3.2.0**
- **MySQL 8.0**
- **Maven**

### Frontend
- **HTML5**
- **CSS3**
- **JavaScript (ES6)**
- **Bootstrap 5.3**

### Libraries
- **ZXing** - QR code generation
- **iText 7** - PDF generation
- **Thymeleaf** - Server-side templating
- **Lombok** - Reduce boilerplate code

## Project Structure

```
qcar-system/
├── backend/
│   ├── QcarApplication.java          # Main Spring Boot application
│   ├── Admin.java                     # Admin entity
│   ├── Car.java                       # Car entity
│   ├── AdminRepository.java           # Admin data access
│   ├── CarRepository.java             # Car data access
│   ├── DTOs.java                      # Data transfer objects
│   ├── QRCodeService.java            # QR code generation logic
│   ├── PDFService.java               # PDF generation logic
│   ├── CarService.java               # Car business logic
│   ├── AuthController.java           # Authentication endpoints
│   ├── CarController.java            # Car management endpoints
│   ├── PublicController.java         # Public view controller
│   ├── application.properties        # Application configuration
│   └── pom.xml                       # Maven dependencies
├── frontend/
│   ├── login.html                    # Admin login page
│   ├── dashboard.html                # Admin dashboard
│   ├── car-details.html              # Public car details (Thymeleaf)
│   └── error.html                    # Error page
└── database/
    └── schema.sql                    # Database schema
```

## Setup Instructions

### Prerequisites

1. **Java Development Kit (JDK) 17+**
   ```bash
   java -version
   ```

2. **MySQL Server 8.0+**
   ```bash
   mysql --version
   ```

3. **Maven 3.6+**
   ```bash
   mvn -version
   ```

### Database Setup

1. Start MySQL server
2. Run the database schema:
   ```bash
   mysql -u root -p < database/schema.sql
   ```

3. This creates:
   - Database: `qcar_db`
   - Tables: `admins`, `cars`
   - Default admin credentials: `admin` / `admin123`

### Backend Setup

1. Navigate to backend directory and update `application.properties`:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/qcar_db
   spring.datasource.username=root
   spring.datasource.password=your_mysql_password
   app.base.url=http://localhost:8080
   ```

2. Build the project:
   ```bash
   mvn clean install
   ```

3. Run the application:
   ```bash
   mvn spring-boot:run
   ```

4. Backend server starts on: `http://localhost:8080`

### Frontend Setup

1. For development, serve frontend files using any HTTP server:
   
   **Using Python:**
   ```bash
   cd frontend
   python -m http.server 3000
   ```

   **Using Node.js:**
   ```bash
   cd frontend
   npx http-server -p 3000
   ```

2. Access the application:
   - Login: `http://localhost:3000/login.html`
   - Dashboard: `http://localhost:3000/dashboard.html`

### Production Deployment

1. Place Thymeleaf templates (`car-details.html`, `error.html`) in:
   ```
   src/main/resources/templates/
   ```

2. Place static files (`login.html`, `dashboard.html`) in:
   ```
   src/main/resources/static/
   ```

3. Update `API_BASE` in frontend JavaScript files to your production URL

4. Build and deploy the Spring Boot JAR:
   ```bash
   mvn clean package
   java -jar target/qcar-system-1.0.0.jar
   ```

## API Endpoints

### Authentication

- **POST** `/api/login` - Admin login
  ```json
  {
    "username": "admin",
    "password": "admin123"
  }
  ```

- **POST** `/api/logout` - Admin logout
- **GET** `/api/check-auth` - Check authentication status

### Car Management (Protected)

- **POST** `/api/cars` - Register new car
  ```json
  {
    "unitNo": "A-101",
    "ownerName": "John Doe",
    "carNumber": "MH-01-AB-1234",
    "type": "Owner"
  }
  ```

- **GET** `/api/cars` - Get all registered cars
- **GET** `/api/cars/qr/pdf/{qrId}` - Download QR code PDF

### Public Access

- **GET** `/car/{qrId}` - View car details (public page)

## Usage Flow

1. **Admin Login**
   - Visit login page
   - Enter credentials (default: admin/admin123)

2. **Register Car**
   - Fill in car details
   - Select type (Tenant/Owner)
   - Click "Register Car"

3. **Download QR Code**
   - View registered cars table
   - Click "Download QR" button
   - Print the PDF sticker

4. **Scan QR Code**
   - User scans QR with phone camera
   - Opens public car details page
   - View unit, owner, car number, and type

## QR Code Color Scheme

- **Tenant**: Maroon (`#800000`)
- **Owner**: Dark Blue (`#00008B`)

## Security Features

- Session-based authentication
- Protected admin routes
- Read-only public access
- Input validation
- Unique car number enforcement

## Database Schema

### Admins Table
- `id` - Primary key
- `username` - Unique username
- `password` - Password (use encryption in production)
- `created_at` - Timestamp

### Cars Table
- `id` - Primary key
- `qr_id` - Unique QR identifier
- `unit_no` - Unit number
- `owner_name` - Owner name
- `car_number` - Car number (unique)
- `type` - Tenant or Owner
- `qr_color` - QR code color
- `created_at` - Created timestamp
- `updated_at` - Updated timestamp

## Customization

### Change Colors
Edit CSS variables in `login.html` and `dashboard.html`:
```css
:root {
    --primary: #1a1a2e;
    --highlight: #e94560;
    --success: #06d6a0;
}
```

### Update QR Size
Modify in `QRCodeService.java`:
```java
byte[] qrImage = qrCodeService.generateQRCode(qrUrl, colorHex, 300);
```

### Change PDF Layout
Update in `PDFService.java`:
```java
.setBorder(new SolidBorder(borderColor, 5));
```

## Production Recommendations

1. **Security**
   - Use BCrypt for password hashing
   - Implement JWT tokens
   - Add HTTPS
   - Enable CORS properly

2. **Database**
   - Use connection pooling
   - Add database indexes
   - Regular backups

3. **Performance**
   - Enable caching
   - Optimize QR generation
   - CDN for static files

4. **Monitoring**
   - Add logging (Logback/Log4j)
   - Health check endpoints
   - Error tracking

## Troubleshooting

### MySQL Connection Error
```
Error: Access denied for user 'root'@'localhost'
Solution: Update password in application.properties
```

### Port Already in Use
```
Error: Port 8080 is already in use
Solution: Change port in application.properties:
server.port=8081
```

### QR Code Not Generating
```
Solution: Ensure ZXing dependencies are in pom.xml
mvn clean install
```

## License

This project is open source and available under the MIT License.

## Support

For issues or questions, please contact your system administrator.

---

**Version**: 1.0.0  
**Last Updated**: February 2026
