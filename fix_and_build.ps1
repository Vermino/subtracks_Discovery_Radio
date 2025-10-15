# PowerShell script to fix namespaces and build
# This is more reliable than running bash from PowerShell

Write-Host "Step 1: Running flutter pub get..." -ForegroundColor Cyan
flutter pub get

Write-Host "`nStep 2: Applying namespace fixes..." -ForegroundColor Cyan
bash fix_namespaces.sh

Write-Host "`nStep 3: Cleaning Gradle cache..." -ForegroundColor Cyan
cd android
./gradlew clean
cd ..

Write-Host "`nStep 4: Building APK..." -ForegroundColor Cyan
flutter build apk --debug

Write-Host "`nDone! Check above for any errors." -ForegroundColor Green
