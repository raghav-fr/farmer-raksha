
# 🌾 AI Agricultural Assistant – Flutter App
### Intelligent Chat UI • Location-Aware • Session-Based Farming Assistant

---

## 📌 Overview
This Flutter app is the **frontend client** for the AI Agricultural Assistant backend (FastAPI + Gemini LLM + ML models).  
It enables farmers to chat with an AI-powered assistant that:
- Predicts the best crops to grow
- Recommends fertilizers intelligently
- Fetches environmental data using geolocation
- Uses Firebase-stored soil attributes
- Supports follow-up agricultural questions
- Remembers context using session IDs

The app acts as a conversational AI guide for agriculture.

---

## 🚀 Features

### 💬 1. Conversational AI Chat
- Beautiful chat UI  
- Continuous conversation  
- Typing indicator  
- Auto-scroll  
- Error-safe responses  

### 📍 2. Automatic Location Fetch
The app retrieves:
- Latitude  
- Longitude  
and sends to backend to trigger auto-environment fetching.

### ☁ Weather + Soil Fetching
Backend automatically fetches:
- Temperature  
- Humidity  
- Rainfall  
- Soil moisture  
- Soil type  
- NPK (Nitrogen, Phosphorus, Potassium)  
- Soil pH  

These values are *not* entered manually through chat — they come from Firebase and WeatherAPI.

---

## 🔥 3. Session-Based Conversation
Each chat uses:
```
session_id = user.uid
```
So the backend knows:
- The user
- The previous crop predicted
- Previous fertilizer result
- Context for follow-up questions

---

## 🧠 4. Intelligent Follow-Up Question Support
The LLM can answer:
- “How does this crop look?”
- “How should I care for it?”
- “What is the fertilizer dosage?”
- “When should I apply it?”

It uses reasoning (no ML call).

---

## 📡 API Used

### 🔹 Chat Endpoint
```
POST /llm/gemini_chat
```

Payload structure:
```json
{
  "session_id": "<uid>",
  "uid": "<uid>",
  "latitude": 20.25,
  "longitude": 85.82,
  "message": "What should I grow now?"
}
```

Backend handles:
- Intent detection  
- Tool calling  
- ML model prediction  
- Follow-up context  

---

## 🛠 Project Structure (Recommended)

```
lib/
│── main.dart
│── screens/
│   └── chat_screen.dart
│── widgets/
│   ├── message_bubble.dart
│   ├── input_field.dart
│   └── typing_indicator.dart
│── services/
│   ├── api_service.dart   → Calls FastAPI backend
│   └── location_service.dart
│── providers/
│   └── chat_provider.dart → session & message state
```

---

## 🔧 API Service Example

```dart
class ApiService {
  static const baseUrl = "http://127.0.0.1:8000/llm/gemini_chat";

  static Future<String> sendMessage({
    required String uid,
    required String sessionId,
    required double latitude,
    required double longitude,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "session_id": sessionId,
        "uid": uid,
        "latitude": latitude,
        "longitude": longitude,
        "message": message,
      }),
    );

    final data = jsonDecode(response.body);
    return data["gemini_text"] ?? "No response";
  }
}
```

---

## 🧭 Location Service Example

```dart
class LocationService {
  static Future<Position> getPosition() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception("Location disabled");

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
```

---

## 🔥 Chat Flow Example

1. User: *“What should I grow now?”*  
2. Flutter → sends location + message  
3. Backend → fetches environment + soil  
4. Backend → predicts crop  
5. Gemini → creates final human-friendly response  
6. Flutter → displays response  

---

## 🧱 Requirements
- Flutter SDK ≥ 3.10  
- Firebase Auth  
- HTTP package  
- Geolocator package  

---

## 🚀 Run the App

### 1. Install packages
```
flutter pub get
```

### 2. Configure Firebase
Add:
```
google-services.json
```
inside:
```
android/app/
```

### 3. Run the app
```
flutter run
```

---

## 🧑‍💻 Author
AI-driven agricultural support system built to help farmers make smart crop & fertilizer decisions.

