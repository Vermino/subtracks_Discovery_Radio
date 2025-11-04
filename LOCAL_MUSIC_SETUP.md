# Local Music Import - Setup Instructions

## Important: Generate Code First!

Before you can run the app, you **MUST** generate the Riverpod provider code:

### Windows:
```bash
# Option 1: Run the batch file
generate_code.bat

# Option 2: Run directly
dart run build_runner build --delete-conflicting-outputs
```

### Linux/Mac:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## What This Does

This command generates the `local_music_import_service.g.dart` file which contains:
- The Riverpod provider (`localMusicImportServiceProvider`)
- The base class `_$LocalMusicImportService`
- All the boilerplate code needed by Riverpod

## After Code Generation

Once code generation completes successfully, you can run the app:

```bash
flutter run
```

## Using Local Music Import

1. Open the app and go to **Settings**
2. Scroll to **Local Music** section
3. Tap **Import from Device**
4. Select MP3 files from your device
5. Songs will be imported with metadata and available in **Offline Mode**

## Supported Features

- **File Formats**: MP3 (with full metadata), FLAC, OGG, M4A, AAC, WAV (filename only)
- **Metadata**: Title, Artist, Album, Genre, Year, Track#, Disc# (MP3 only)
- **Storage**: Files copied to app documents/local_music directory
- **Offline**: Always available in offline mode
- **Database**: Source ID = 0 (separate from server sources)

## Troubleshooting

### Error: "local_music_import_service.g.dart not found"
→ Run code generation: `dart run build_runner build --delete-conflicting-outputs`

### Error: "localMusicImportServiceProvider not found"
→ Same as above - code generation needed

### Error during build_runner
→ Make sure you ran `flutter pub get` first
→ Try: `dart run build_runner clean` then generate again

## Technical Notes

- Local music uses `sourceId = 0` (reserved for local)
- Files stored with `downloadFilePath` set (treated as downloaded)
- Works with existing audio playback system via `AudioSource.file()`
- MP3 metadata extracted using pure Dart `id3` package
- No duration extraction (id3 package limitation)
