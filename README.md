# CosmoSafe

CosmoSafe is a cross-platform Flutter app for scanning the back label of cosmetic products from a camera or uploaded image, then sending the image to a backend for ingredient analysis.

The backend is expected to return:

- a safety rating from `A` to `E`
- a written summary
- ingredient findings
- optional product category and confidence
- optional daily-usage guidance

The app computes a final daily-usage suggestion from the returned rating and product category when the backend does not provide one.

## Run

Set your analysis backend URL before launching the app:

```bash
flutter run --dart-define=COSMOSAFE_SCAN_API_BASE_URL=https://your-api.example.com
```

If your backend requires authentication, also pass an API key:

```bash
flutter run \
	--dart-define=COSMOSAFE_SCAN_API_BASE_URL=https://your-api.example.com \
	--dart-define=COSMOSAFE_SCAN_API_KEY=your_secret_key
```

## Supported flow

- Mobile camera capture on Android and iOS
- Image upload on web, Linux, Windows, macOS, Android, and iOS
- Backend-driven result screen with rating and usage guidance

## Backend contract

The app currently posts a multipart image to:

```text
POST /v1/analyze/image
```

Auth header behavior:

- If `COSMOSAFE_SCAN_API_KEY` is set, the app sends `Authorization: Bearer <key>`.
- If it is not set, the request is sent without an auth header.

Expected JSON fields include:

- `rating`
- `summary`
- `ingredients_text`
- `findings`
- `product_category`
- `confidence`
- `daily_usage` or `usageRecommendation`

You can adjust the endpoint or response fields later without changing the UI structure.
