# AI Chat & Image Generator (Flutter)

A polished Flutter app combining **AI Chat** (LLM-powered conversation) and
**AI Image Generation** (text-to-image), built on top of the **OpenRouter API**
(openrouter.ai) — using Google's `google/gemini-flash-latest` for chat and
`google/gemini-2.5-flash-image` for images.

## ✨ Features

**Chat**
- Send messages to an LLM (`google/gemini-flash-latest` by default, configurable) and get real-time replies via OpenRouter's OpenAI-compatible `/chat/completions` endpoint
- Full conversation history, persisted locally between app launches (`shared_preferences`)
- Typing indicator while waiting for a response
- Graceful error bubbles if the API call fails (bad key, no network, rate limit, etc.)
- Clear-conversation action

**Image Generator**
- Enter a text prompt and generate an image via OpenRouter's dedicated Image API (`google/gemini-2.5-flash-image` by default)
- Choose output size (square, landscape, portrait)
- Images come back as base64 bytes (not URLs) and render instantly with `Image.memory` — no extra network round-trip needed
- Results shown in a scrollable gallery grid; tap any thumbnail to view it full-screen with its prompt
- Clear-gallery action

**Engineering**
- Clean architecture: `models/ → services/ → providers/ → screens/ + widgets/`
- `provider` package for state management
- Centralized `OpenRouterService` wrapping both `/chat/completions` and the dedicated `/images` endpoint
- API key & model names loaded from `.env` via `flutter_dotenv` (never hard-coded)
- Light & dark theme support
- Basic widget test included

## 📁 Project Structure

```
lib/
├── config/
│   └── app_config.dart          # API base URL, model names, theme
├── models/
│   ├── chat_message.dart
│   └── generated_image.dart
├── services/
│   └── openrouter_service.dart  # All OpenRouter HTTP calls live here
├── providers/
│   ├── chat_provider.dart       # Chat state + local persistence
│   └── image_gen_provider.dart  # Image generation state
├── screens/
│   ├── home_screen.dart         # Bottom nav: Chat / Image Gen
│   ├── chat_screen.dart
│   └── image_screen.dart
├── widgets/
│   ├── chat_bubble.dart
│   └── typing_indicator.dart
└── main.dart
test/
└── widget_test.dart
pubspec.yaml
.env.example                     # Copy to .env and add your key
```

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK 3.22+ installed ([install guide](https://docs.flutter.dev/get-started/install))
- A device/emulator, or Chrome for web
- An OpenAI API key: https://platform.openai.com/api-keys

### 2. Unzip and generate platform folders
This zip ships the **Dart source only** (no generated `android/`, `ios/`, `web/`
folders — those are normally machine/SDK-version specific and are regenerated
on demand). From the project root run:

```bash
flutter create .
```

This safely adds `android/`, `ios/`, `web/`, etc. around the existing `lib/`
folder without touching your source code.

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Add your API key
Edit the `.env` file already at the project root (or copy `.env.example` to
`.env` if it's missing) and set:

```
OPENROUTER_API_KEY=sk-or-v1-your-real-key-here
CHAT_MODEL=google/gemini-flash-latest
IMAGE_MODEL=google/gemini-2.5-flash-image
SITE_URL=https://example.com
APP_TITLE=AI Chat & Image Generator
```

Get a key at https://openrouter.ai/keys (free account, pay-as-you-go credits).

> The app will show a one-time reminder dialog on launch if the key is still
> the placeholder value.
>
> `SITE_URL` / `APP_TITLE` are optional — OpenRouter uses them only to
> attribute your app on their dashboard/rankings. They don't need to be a
> real deployed URL.

### 5. Run it
```bash
flutter run
```
Pick any connected device, emulator, or `chrome` when prompted.

### 6. Run tests
```bash
flutter test
```

## 🔑 About the API key & security

- The key is read at runtime from `.env` via `flutter_dotenv` — it is **not**
  compiled into source control if you keep `.env` in `.gitignore` (already
  configured).
- For a production app, don't ship the raw OpenRouter key inside the client
  binary at all — proxy requests through your own backend so the key never
  leaves your server. This starter is wired for direct calls to keep the
  assignment simple and fully functional out of the box.

## 🧩 Customizing

- Swap models: edit `CHAT_MODEL` / `IMAGE_MODEL` in `.env` — browse slugs at https://openrouter.ai/models.
- Change the system prompt: `OpenRouterService.sendChatMessage`'s `systemPrompt` parameter, passed from `ChatProvider`.
- Change image sizes offered: `_sizes` list in `lib/screens/image_screen.dart` (accepts pixel dimensions like `1024x1024` or tiers like `1K`/`2K`/`4K`).
- Theme colors: `AppConfig` in `lib/config/app_config.dart`.

## 🛠 Troubleshooting

| Symptom | Fix |
|---|---|
| "Missing OpenRouter API key" error bubble | Set `OPENROUTER_API_KEY` in `.env` and hot-restart (not just hot-reload) |
| 401 from API | Key is invalid/revoked — generate a new one at openrouter.ai/keys |
| 402 / insufficient credits | Add credits to your OpenRouter account (openrouter.ai/credits) |
| 429 from API | You've hit a rate limit — free-tier models cap requests/day |
| Image request fails / 502 | OpenRouter's image billing is all-or-nothing: a failed generation isn't billed, just retry the prompt |
| `flutter create .` complains about existing files | That's expected/safe — it only adds the missing platform folders |

## 📄 License

Provided as-is for educational/assignment purposes.
