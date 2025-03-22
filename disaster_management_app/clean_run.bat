@echo off
echo Cleaning Flutter cache and running app...
flutter clean
flutter pub get
flutter run --no-web 