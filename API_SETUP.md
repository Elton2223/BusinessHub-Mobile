# API Setup Guide

This guide explains how to set up your Flutter app to connect with your Loopback4 backend API server.

## 🚀 Current Configuration

Your app is now configured to connect to:
- **API Server**: `http://127.0.0.1:3005`
- **API Version**: `api`
- **Database**: XAMPP (MySQL)

## 📋 Required API Endpoints

Your Loopback4 server should have the following endpoints:

### Authentication Endpoints
```
POST /businesshubdb/usermanagement
POST /businesshubdb/usermanagement
POST /businesshubdb/usermanagement
GET /businesshubdb/usermanagement
```

### Expected Request/Response Formats

#### Login Request
```json
POST /businesshubdb/usermanagement
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Login Response
```json
{
  "id": "access_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

#### Register Request
```json
POST /businesshubdb/usermanagement
{
  "name": "John",
  "surname": "Doe",
  "email": "user@example.com",
  "profile_photo": "NULL",
  "ratings": 0,
  "phone_number": "+1234567890",
  "street_address": "NULL",
  "city": "NULL",
  "state": "NULL",
  "postal_code": "NULL",
  "country": "NULL",
  "identification_doc": "NULL",
  "latitude": 0,
  "longitude": 0,
  "password": "password123"
}
```

#### Register Response
```json
{
  "id": "user_id",
  "name": "John",
  "surname": "Doe",
  "email": "user@example.com",
  "phone_number": "+1234567890",
  "profile_photo": "NULL",
  "ratings": 0,
  "street_address": "NULL",
  "city": "NULL",
  "state": "NULL",
  "postal_code": "NULL",
  "country": "NULL",
  "identification_doc": "NULL",
  "latitude": 0,
  "longitude": 0
}
```

## 🔧 Loopback4 Configuration

### 1. User Management Model
Make sure your Loopback4 User Management model has these properties:
```json
{
  "name": "string",
  "surname": "string",
  "email": "string",
  "password": "string",
  "profile_photo": "string?",
  "ratings": "number",
  "phone_number": "string?",
  "street_address": "string?",
  "city": "string?",
  "state": "string?",
  "postal_code": "string?",
  "country": "string?",
  "identification_doc": "string?",
  "latitude": "number",
  "longitude": "number"
}
```

### 2. Authentication Settings
In your `server/datasources.json`:
```json
{
  "businesshubdb": {
    "name": "businesshubdb",
    "connector": "mysql",
    "host": "localhost",
    "port": 3306,
    "user": "Admin",
    "password": "",
    "database": "businesshubdb"
  }
}
```

Or if you're using a TypeScript datasource file:
```typescript
const config = {
  name: 'businesshubdb',
  connector: 'mysql',
  host: 'localhost',
  port: 3306,
  user: 'Admin',
  password: '',
  database: 'businesshubdb'
};
```

### 3. CORS Configuration
In your `server/middleware.json`:
```json
{
  "initial": {
    "cors": {
      "origin": "*",
      "methods": "GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS",
      "preflightContinue": false,
      "optionsSuccessStatus": 204
    }
  }
}
```

## 🧪 Testing Your API

### 1. Test Login Endpoint
```bash
curl -X POST http://127.0.0.1:3005/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 2. Test Register Endpoint
```bash
curl -X POST http://127.0.0.1:3005/businesshubdb/usermanagement \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John",
    "surname": "Doe",
    "email": "newuser@example.com",
    "password": "password123",
    "phone_number": "+1234567890",
    "profile_photo": "NULL",
    "ratings": 0,
    "street_address": "NULL",
    "city": "NULL",
    "state": "NULL",
    "postal_code": "NULL",
    "country": "NULL",
    "identification_doc": "NULL",
    "latitude": 0,
    "longitude": 0
  }'
```

## 🔍 Troubleshooting

### Common Issues

1. **Connection Refused**
   - Make sure your Loopback4 server is running on port 3005
   - Check if XAMPP MySQL service is running

2. **CORS Errors**
   - Ensure CORS is properly configured in your Loopback4 server
   - Check if the origin is set to allow your Flutter app

3. **Authentication Errors**
   - Verify your User model has the correct properties
   - Check if password hashing is properly configured

4. **Database Connection**
   - Ensure XAMPP MySQL is running on port 3306
   - Verify database name `businesshubdb` exists
   - Check that user `Admin` has access to the database
   - Verify the `usermanagement` table exists in your database

### Debug Steps

1. **Check Server Status**
   ```bash
   curl http://127.0.0.1:3005/api/users
   ```

2. **Check Database Connection**
   - Open phpMyAdmin at `http://localhost/phpmyadmin`
   - Verify your database exists and has the users table

3. **Check Flutter Logs**
   - Run `flutter run` and check console output
   - Look for API error messages

## 📱 Flutter App Features

Your Flutter app now includes:

- ✅ **Login with API**: Connects to `/api/users/login`
- ✅ **Registration with API**: Connects to `/businesshubdb/usermanagement`
- ✅ **Complete User Profile**: Sends all required fields including NULL values for optional fields
- ✅ **Token Storage**: Automatically stores and manages auth tokens
- ✅ **Error Handling**: User-friendly error messages
- ✅ **Loading States**: Shows loading indicators during API calls
- ✅ **Navigation**: Automatic navigation after successful auth

## 🔐 Security Notes

1. **HTTPS in Production**: Change `API_BASE_URL` to use HTTPS in production
2. **Token Expiry**: Implement token refresh logic if needed
3. **Password Validation**: Add client-side password validation
4. **Input Sanitization**: Ensure all inputs are properly validated

## 🚀 Next Steps

1. **Start your Loopback4 server**:
   ```bash
   cd your-loopback4-project
   npm start
   ```

2. **Start XAMPP** and ensure MySQL is running

3. **Create a .env file** in your Flutter project root:
   ```bash
   cp env.example .env
   ```

4. **Run your Flutter app**:
   ```bash
   flutter run
   ```

5. **Test the authentication flow** by registering and logging in

## 📞 Support

If you encounter issues:
1. Check the Flutter console for error messages
2. Verify your Loopback4 server is running and accessible
3. Test API endpoints directly with curl or Postman
4. Check XAMPP MySQL service status
