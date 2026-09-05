# clarus_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:


For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Clarus Mobile App

Clarus is a Flutter mobile app for diabetic retinopathy screening. The app
allows a health worker to submit a retinal image, view the screening result,
and review previous encounters.

## Requirements

- Flutter 3 or later
- Dart 3 or later
- A connected Android device or Android emulator
- The [Clarus_Backend](../../Clarus_Backend/clarus_backend) FastAPI service

## Install and run the app

From this directory, install the Flutter dependencies and start the app:

```bash
flutter pub get
flutter run
```

To run on a specific device, list available devices first:

```bash
flutter devices
flutter run -d <device-id>
```

## Run with the backend

The app is configured to use the real backend by default. Start the backend
from the backend project directory in a separate terminal:

```bash
cd ../../Clarus_Backend/clarus_backend
python -m venv .venv
# Windows PowerShell
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Then start the Flutter app from this directory:

```bash
flutter run
```

The backend API documentation is available at
`http://localhost:8000/docs`.

### Backend URL

The API URL is defined in `lib/services/api_service.dart`:

```dart
const bool useMockApi = false;
const String baseUrl = 'http://10.0.2.2:8000';
```

`10.0.2.2` points from an Android emulator to the host computer. If you use
a physical device, replace it with the host computer's local network IP. For
an iOS simulator, use `http://localhost:8000`.

The app currently uses these backend endpoints:

- `POST /predict` to submit a retinal image and worker name
- `GET /history` to load previous screening encounters

## Run without the backend

For UI development, set `useMockApi` to `true` in
`lib/services/api_service.dart`. The app will use local sample screening
results and history data instead of making network requests.

## Project structure

```text
lib/
	main.dart                 App entry point
	models/                   Screening and history data models
	screens/                  Login, dashboard, screening, and history views
	services/api_service.dart Backend and mock API integration
	theme/                    Application theme
```

## Useful commands

```bash
flutter analyze
flutter test
flutter clean
```
