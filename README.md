# tennisbookings

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## DEPLOYMENT

1. run `yarn build-web`
2. run `publish-web` from firebase project directory

# UPDATING INDEXES

1. run `firebase firestore:indexes > firestore.indexes.json` from firebase project
This will update the indexes json file

## CORS FIX

1. run `gsutil cors set cors.json gs://<your-bucket-name>` to start the emulator
