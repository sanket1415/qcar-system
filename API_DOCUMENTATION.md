# QCAR API Documentation

Complete API reference for the Qcar Car QR Management System.

## Base URL
```
Development: http://localhost:8080/api
Production: https://yourdomain.com/api
```

## Authentication

All admin endpoints require session-based authentication. After successful login, a session cookie is created.

### Headers
```
Content-Type: application/json
```

### Credentials
```
credentials: 'include'  // Required for session cookies
```

---

## Endpoints

### 1. Authentication

#### POST /login
Authenticate admin user and create session.

**Request:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Login successful",
  "username": "admin"
}
```

**Response (Error - 401):**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

**Example:**
```javascript
const response = await fetch('http://localhost:8080/api/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  credentials: 'include',
  body: JSON.stringify({
    username: 'admin',
    password: 'admin123'
  })
});

const data = await response.json();
console.log(data);
```

---

#### POST /logout
Destroy admin session.

**Request:** No body required

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

**Example:**
```javascript
const response = await fetch('http://localhost:8080/api/logout', {
  method: 'POST',
  credentials: 'include'
});
```

---

#### GET /check-auth
Check if user is authenticated.

**Request:** No body required

**Response (Authenticated):**
```json
{
  "authenticated": true,
  "username": "admin"
}
```

**Response (Not Authenticated):**
```json
{
  "authenticated": false
}
```

**Example:**
```javascript
const response = await fetch('http://localhost:8080/api/check-auth', {
  credentials: 'include'
});
const data = await response.json();

if (!data.authenticated) {
  window.location.href = '/login.html';
}
```

---

### 2. Car Management (Protected)

All car management endpoints require authentication.

#### POST /cars
Register a new car and generate QR code.

**Request:**
```json
{
  "unitNo": "A-101",
  "ownerName": "John Doe",
  "carNumber": "MH-01-AB-1234",
  "type": "Owner"
}
```

**Field Validations:**
- `unitNo`: Required, string
- `ownerName`: Required, string
- `carNumber`: Required, string, must be unique
- `type`: Required, enum ("Tenant" | "Owner")

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Car registered successfully",
  "car": {
    "id": 1,
    "qrId": "abc12345",
    "unitNo": "A-101",
    "ownerName": "John Doe",
    "carNumber": "MH-01-AB-1234",
    "type": "Owner",
    "qrColor": "#00008B"
  },
  "qrUrl": "http://localhost:8080/car/abc12345"
}
```

**Response (Error - 400):**
```json
{
  "success": false,
  "message": "Car number already exists"
}
```

**Response (Unauthorized - 401):**
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

**Example:**
```javascript
const carData = {
  unitNo: 'A-101',
  ownerName: 'John Doe',
  carNumber: 'MH-01-AB-1234',
  type: 'Owner'
};

const response = await fetch('http://localhost:8080/api/cars', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  credentials: 'include',
  body: JSON.stringify(carData)
});

const result = await response.json();
console.log(result);
```

---

#### GET /cars
Retrieve all registered cars.

**Request:** No body required

**Response (Success - 200):**
```json
{
  "success": true,
  "cars": [
    {
      "id": 1,
      "qrId": "abc12345",
      "unitNo": "A-101",
      "ownerName": "John Doe",
      "carNumber": "MH-01-AB-1234",
      "type": "Owner",
      "qrColor": "#00008B"
    },
    {
      "id": 2,
      "qrId": "def67890",
      "unitNo": "B-205",
      "ownerName": "Jane Smith",
      "carNumber": "MH-02-CD-5678",
      "type": "Tenant",
      "qrColor": "#800000"
    }
  ]
}
```

**Response (Unauthorized - 401):**
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

**Example:**
```javascript
const response = await fetch('http://localhost:8080/api/cars', {
  credentials: 'include'
});

const data = await response.json();
const cars = data.cars;

// Display in table
cars.forEach(car => {
  console.log(`${car.carNumber} - ${car.ownerName}`);
});
```

---

#### GET /cars/qr/pdf/{qrId}
Download QR code as PDF sticker.

**Parameters:**
- `qrId`: The unique QR identifier (e.g., "abc12345")

**Response (Success - 200):**
- Content-Type: `application/pdf`
- File download with name: `qr-{carNumber}.pdf`

**Response (Unauthorized - 401):**
- HTTP 401 status

**Response (Not Found - 500):**
- HTTP 500 status

**Example:**
```javascript
function downloadPDF(qrId) {
  const url = `http://localhost:8080/api/cars/qr/pdf/${qrId}`;
  window.open(url, '_blank');
}

// Direct link
<a href="http://localhost:8080/api/cars/qr/pdf/abc12345" download>
  Download QR
</a>
```

---

### 3. Public Access (No Authentication)

#### GET /car/{qrId}
View car details page (public).

**Parameters:**
- `qrId`: The unique QR identifier

**Response:** HTML page displaying:
- Car Number
- Unit Number
- Owner Name
- Type (Tenant/Owner)

**Example:**
```
Scan QR code or visit:
http://localhost:8080/car/abc12345

Browser opens a styled page showing car details
```

---

## Data Models

### Admin
```typescript
interface Admin {
  id: number;
  username: string;
  password: string;
  created_at: Date;
}
```

### Car
```typescript
interface Car {
  id: number;
  qrId: string;           // Unique 8-character ID
  unitNo: string;         // Unit number
  ownerName: string;      // Owner name
  carNumber: string;      // Car registration number (unique)
  type: "Tenant" | "Owner";
  qrColor: string;        // Hex color code
  created_at: Date;
  updated_at: Date;
}
```

---

## QR Code Colors

| Type   | Color      | Hex Code  |
|--------|------------|-----------|
| Tenant | Maroon     | #800000   |
| Owner  | Dark Blue  | #00008B   |

---

## Error Codes

| Code | Message                      | Description                       |
|------|------------------------------|-----------------------------------|
| 200  | OK                           | Request successful                |
| 400  | Bad Request                  | Invalid input or duplicate entry  |
| 401  | Unauthorized                 | Not authenticated                 |
| 500  | Internal Server Error        | Server error                      |

---

## Rate Limiting

Currently no rate limiting implemented. Recommended for production:
- Login: 5 attempts per minute
- Car registration: 10 per minute
- PDF downloads: 20 per minute

---

## CORS Configuration

Default CORS settings allow all origins:
```java
@CrossOrigin(origins = "*")
```

**Production recommendation:**
```java
@CrossOrigin(origins = "https://yourdomain.com")
```

---

## Example Workflows

### Complete Registration Flow

```javascript
// 1. Login
async function login(username, password) {
  const response = await fetch('http://localhost:8080/api/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify({ username, password })
  });
  return await response.json();
}

// 2. Register Car
async function registerCar(carData) {
  const response = await fetch('http://localhost:8080/api/cars', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify(carData)
  });
  return await response.json();
}

// 3. Get All Cars
async function getCars() {
  const response = await fetch('http://localhost:8080/api/cars', {
    credentials: 'include'
  });
  return await response.json();
}

// 4. Download PDF
function downloadQR(qrId) {
  window.open(`http://localhost:8080/api/cars/qr/pdf/${qrId}`, '_blank');
}

// Usage
(async () => {
  // Login
  const loginResult = await login('admin', 'admin123');
  console.log('Logged in:', loginResult);

  // Register car
  const car = await registerCar({
    unitNo: 'A-101',
    ownerName: 'John Doe',
    carNumber: 'MH-01-AB-1234',
    type: 'Owner'
  });
  console.log('Car registered:', car);

  // Get all cars
  const allCars = await getCars();
  console.log('All cars:', allCars);

  // Download PDF
  downloadQR(car.car.qrId);
})();
```

---

## Testing with cURL

### Login
```bash
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -c cookies.txt \
  -d '{"username":"admin","password":"admin123"}'
```

### Register Car
```bash
curl -X POST http://localhost:8080/api/cars \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{
    "unitNo": "A-101",
    "ownerName": "John Doe",
    "carNumber": "MH-01-AB-1234",
    "type": "Owner"
  }'
```

### Get All Cars
```bash
curl -X GET http://localhost:8080/api/cars \
  -b cookies.txt
```

### Download PDF
```bash
curl -X GET http://localhost:8080/api/cars/qr/pdf/abc12345 \
  -b cookies.txt \
  -o qr-code.pdf
```

---

## WebSocket Support

Currently not implemented. For real-time updates in future versions.

---

## Changelog

### Version 1.0.0
- Initial release
- Basic CRUD operations
- QR code generation
- PDF export
- Session-based authentication

---

## Support

For API issues or questions:
- Email: api@yourdomain.com
- Documentation: https://docs.yourdomain.com
- GitHub: https://github.com/yourusername/qcar

---

**Last Updated**: February 2026
