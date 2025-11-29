# Critical fixes for HMS compilation errors

Write-Host "Fixing critical compilation errors..." -ForegroundColor Yellow

# 1. Add 'user' getter as alias in AuthProvider
 = Get-Content "lib\providers\auth_provider.dart" -Raw
 =  -replace "(bool get isAuthenticated => _currentUser != null;)", "$1
  AppUser? get user => _currentUser; // Alias for compatibility"
 | Set-Content "lib\providers\auth_provider.dart"

Write-Host "✓ Fixed AuthProvider.user getter" -ForegroundColor Green

# Done
Write-Host "
Fixes applied! Now fixing providers to handle Streams..." -ForegroundColor Cyan
