# Document Upload & Preview Fix

## Issue Fixed
Documents (PDF and Images) uploaded by users were not accessible in the admin panel preview/download.

## Root Cause
The file path handling was inconsistent:
- Files were being saved to relative paths
- File paths weren't being resolved correctly during retrieval
- URL construction for static files was incorrect

## Changes Made

### 1. **Backend: fileUpload.js**
- Fixed upload directory to use absolute path: `path.join(__dirname, "../uploads/documents")`
- Now files are consistently saved in `/backend/uploads/documents/`
- Added proper imports for `fileURLToPath` and `__dirname`

### 2. **Backend: document.service.js**
- Updated to store relative file path: `uploads/documents/{filename}`
- Ensures consistent path format across all operations
- Path is now relative to the project root for easy resolution

### 3. **Backend: server.js**
- Enhanced static file serving with proper MIME types
- Added caching headers for uploaded files
- Configured automatic MIME type detection for PDFs and images

### 4. **Backend: admin.routes.js**
- Fixed document download endpoint (`/api/admin/documents/:id/download`):
  - Correctly resolves relative file paths to absolute paths
  - Added security check to prevent path traversal attacks
  - Properly streams files with correct Content-Type headers
- Enhanced delete endpoint:
  - Deletes both database record AND physical file
  - Handles errors gracefully
  - Security checks for file path validation

### 5. **Frontend: Documents.jsx**
- Updated `getDownloadUrl()` function:
  - Now uses auth-protected endpoint: `/api/admin/documents/:id/download`
  - Ensures proper authentication for sensitive documents
  - More reliable than static file serving

## File Structure
```
backend/
├── uploads/
│   └── documents/
│       ├── document-[timestamp-random].pdf
│       └── document-[timestamp-random].jpg
├── server.js (updated)
├── routes/
│   └── admin.routes.js (updated)
├── services/
│   └── document.service.js (updated)
└── utils/
    └── fileUpload.js (updated)
```

## How It Works Now

### Upload Flow:
1. User uploads document (PDF/Image)
2. Multer saves file to `/backend/uploads/documents/[filename]`
3. Database stores path: `uploads/documents/[filename]`
4. Metadata (name, size, type) stored in MongoDB

### Download/Preview Flow:
1. Admin clicks preview icon in Documents section
2. Frontend calls: `GET /api/admin/documents/{id}/download`
3. Backend resolves path: `process.cwd()/uploads/documents/[filename]`
4. Validates path is within uploads directory (security)
5. Streams file with proper Content-Type headers
6. Frontend displays in preview modal

### Delete Flow:
1. Admin clicks delete icon
2. Backend finds document record
3. Deletes physical file from filesystem
4. Deletes database record
5. Updates UI

## Testing the Fix

### For PDF Documents:
1. Go to Documents section
2. Upload a PDF file
3. Click the eye icon (preview)
4. PDF should appear in the preview modal
5. Can scroll through pages (if embedded viewer supports it)

### For Images:
1. Upload JPG/PNG/GIF
2. Click preview icon
3. Image should display in modal
4. Can download or close modal

### For Download:
1. Click download icon or use download button in preview
2. File should download to your computer

## Supported File Types
- **Images**: JPEG, JPG, PNG, GIF, WEBP
- **Documents**: PDF
- **Maximum size**: 10 MB per file

## Troubleshooting

### If files still don't appear:
1. Restart the backend server
2. Clear browser cache
3. Check `/backend/uploads/documents/` directory exists
4. Check file permissions on the uploads folder

### Check server logs for errors:
Look for messages like:
- "File not found on server" - physical file missing
- "Access denied" - security check failed
- "Document not found" - database record missing

## Security Features
✅ Path traversal prevention (files must be in uploads dir)
✅ File type validation (only PDF and images)
✅ File size limits (max 10 MB)
✅ Authentication required for admin endpoints
✅ Proper MIME type headers to prevent execution
