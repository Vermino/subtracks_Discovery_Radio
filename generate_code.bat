@echo off
echo Generating Riverpod provider code...
echo.
dart run build_runner build --delete-conflicting-outputs
echo.
echo Code generation complete!
echo You can now run: flutter run
pause
