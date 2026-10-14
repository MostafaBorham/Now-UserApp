# nowdelivery_user_app

Customer-facing mobile application for NowDelivery platform, allowing users to browse products, place orders, and track deliveries in real-time.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Support chat realtime

The customer support chat retrieves the public Reverb app key and WebSocket
endpoint from the authenticated Backend, then authorizes its private
conversation channel through `/broadcasting/auth` with the signed-in user's
existing API token. Set `REVERB_APP_KEY`, `REVERB_HOST`, `REVERB_SCHEME`, and
`REVERB_PORT` in the Backend environment. Message sync continues as a fallback
if Reverb is unavailable.
