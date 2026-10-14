# ScanFlow

ScanFlow is an Android-first, offline document scanner built with Flutter. Camera captures, source photos, PDF files, OCR text, and document metadata stay on the device. There is no account or backend.

## Architecture

- `lib/app`: Material 3 theme, GoRouter, and Riverpod state providers.
- `lib/core/database`: Drift/SQLite document and page metadata, OCR text, ordering, favorites, and trash state.
- `lib/core/storage`: Private app document storage for source images and PDF exports.
- `lib/core/services`: Image enhancement, on-device OCR, PDF creation, and the document edge correction bridge.
- `lib/features`: Home library, scanner, page editor, document viewer, and trash.
- `android/app`: Camera permission setup and the OpenCV Android implementation used for photo edge detection and perspective correction.

## Implemented

- High-resolution manual camera capture with focus tap, Auto/On/Off flash, gallery import, and multi-page sessions.
- SQLite-backed library with OCR, title, and tag search; favorites; folders and tags; name/date sorting; grid/list views; bulk favorite and trash actions; rename; and trash restore/permanent deletion. The schema upgrade adds organization fields without dropping existing records.
- Synchronized page preview and thumbnail selection, crop from the preview, manual corner crop, OpenCV auto-crop/perspective correction, rotate, color enhancement and document filters, duplicate, delete, gallery insertion, and drag reorder. Original source images remain available for reset and re-editing.
- On-device Latin-script OCR per page, searchable OCR text, basic text correction, and TXT export.
- Multi-page PDF generation with an invisible positioned OCR text layer when OCR is present. PDFs can be previewed and shared from Android's sharesheet.
- PDF import, preview, page rasterization into editable scan pages, and sharing of the original PDF.
- ScanFlow vector logo, Android adaptive launcher icon, and branded startup screen.

## Current limitations

- Capture is manual. There is no live edge overlay or auto-capture stability detector.
- PDF merge, split, and page extraction are not implemented. Imported pages are rasterized at 144 DPI for editing; the original PDF is retained for viewing and sharing.
- PDF output currently uses image-fit page dimensions and a fixed balanced JPEG setting. A4/A5/Letter/Legal, margin controls, and quality presets are not exposed yet.
- PDF export uses the app's private document storage and Android sharing. A dedicated save-to-folder flow is not implemented.
- A dedicated settings screen, PDF merge/split/page extraction, per-page image export, and PDF page-size, margin, orientation, and compression controls are not implemented.
- The official OpenCV Android archive increases application size substantially. Build architecture-specific APKs for direct installation or use the App Bundle for store delivery.
- OCR supports the ML Kit Latin model only. Additional language models are not configured.
- Physical-device camera testing and 1/10/50/100-page performance checks remain to be done. Debug APK builds use debug signing; publishing needs a private release keystore.

## Development

```sh
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter run
```

## Android builds

```sh
flutter build apk --debug --split-per-abi
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

The app uses Java 17, Android Gradle Plugin 9.1.0, Kotlin 2.4.0, and the Android SDK configured by Flutter. Kotlin incremental compilation is disabled because Windows cannot relativize cached plugin sources on `C:` against this workspace on `G:`.

## Direct dependencies

Version constraints and resolved versions are recorded in `pubspec.yaml` and `pubspec.lock`.

- `flutter_riverpod` `^3.4.3`
- `go_router` `^18.0.2`
- `drift` `^2.35.2`, `sqlite3_flutter_libs` `^0.6.0+eol`
- `camera` `^0.12.1`, `image_picker` `^1.2.4`, `file_picker` `^13.1.0`
- `image` `^4.12.0`, `crop_your_image` `^2.0.1`
- `google_mlkit_text_recognition` `^0.17.1`
- `pdf` `^3.13.1`, `printing` `^5.15.1`, `share_plus` `^13.3.1`
- `path_provider` `^2.1.6`, `path` `^1.9.1`, `uuid` `^4.6.0`
- Android native `org.opencv:opencv:4.13.0` (Apache-2.0)

## Storage and privacy

Scans and exports live in the app's private documents directory by default. Uninstalling the app can remove these files. Export or share documents to keep copies elsewhere. OCR and image processing run on-device.
