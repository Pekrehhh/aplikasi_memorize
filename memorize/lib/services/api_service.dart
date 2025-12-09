// ApiService: deprecated
// This project moved to local Hive storage for auth and notes.
// Network-related utilities were removed or migrated to use `dart:io` directly.
// Keep a small deprecated placeholder to avoid import errors if referenced.

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();
}