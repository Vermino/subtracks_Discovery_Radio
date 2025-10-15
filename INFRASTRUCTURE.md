# Subtracks Homelab Infrastructure

## 🎵 Service Overview

### Navidrome (Music Streaming Server)
- **URL**: `http://192.168.0.214:4533`
- **API Endpoint**: `/rest` (Subsonic API compatible)
- **Version**: 0.58.0
- **Status**: ✅ Connected and working
- **Purpose**: Streams existing music library to Subtracks app
- **Authentication**: Username/Password (already configured in app)

### Lidarr (Music Collection Manager)
- **URL**: `https://lidarr.404oak.com`
- **API Endpoint**: `/api/v1`
- **API Key**: `97559dd2947143288c213cdc170f3444`
- **Version**: 2.12.4.4658
- **Status**: ✅ API tested and working
- **Purpose**: Automatically downloads new music when discovery tracks are liked

### yt-dlp (YouTube Discovery)
- **Version**: 2025.09.05
- **Command**: `python -m yt_dlp`
- **Status**: ✅ Installed and ready
- **Purpose**: Extract metadata and streams from YouTube for music discovery

## 🔗 Integration Architecture

```
[Discovery Sources] → [yt-dlp] → [Subtracks App] → [Rating System]
                                       ↓
[Navidrome Server] ← [Music Library] ← [Lidarr] ← [Auto-Request]
```

### Data Flow
1. **Music Streaming**: Navidrome → Subtracks App
2. **Discovery**: YouTube → yt-dlp → Subtracks App
3. **Auto-Download**: Liked Discovery → Lidarr API → Music Library → Navidrome

## 📋 API Endpoints

### Navidrome (Subsonic API)
```
Base URL: http://192.168.0.214:4533/rest
Authentication: ?u=USERNAME&p=PASSWORD&v=1.15.0&c=subtracks

Examples:
- Ping: /ping.view
- Get Artists: /getArtists.view
- Get Albums: /getAlbums.view
- Stream: /stream.view?id=SONG_ID
```

### Lidarr API
```
Base URL: https://lidarr.404oak.com/api/v1
Headers: X-Api-Key: 97559dd2947143288c213cdc170f3444

Examples:
- Status: /system/status
- Search Artist: /artist/lookup?term=ARTIST_NAME
- Add Artist: /artist (POST)
- Add Album: /album (POST)
```

### yt-dlp Commands
```
# Extract metadata only (fast)
python -m yt_dlp --dump-json "YOUTUBE_URL"

# Get audio stream URL
python -m yt_dlp -f "bestaudio" --get-url "YOUTUBE_URL"

# Search and extract
python -m yt_dlp "ytsearch:ARTIST SONG" --dump-json
```

## 🚀 Development Configuration

All endpoints and credentials are stored in:
- **File**: `lib/config/infrastructure_config.dart`
- **Purpose**: Centralized configuration for all external services
- **Security**: Contains development credentials (not for production)

## 🔧 Testing Commands

Test all services:
```bash
# Test Navidrome
curl "http://192.168.0.214:4533/rest/ping.view?u=Vermino&p=Jessejames2004%40&v=1.15.0&c=test"

# Test Lidarr
curl -H "X-Api-Key: 97559dd2947143288c213cdc170f3444" "https://lidarr.404oak.com/api/v1/system/status"

# Test yt-dlp
python -m yt_dlp --version
```

## 📱 Implementation Stages

1. **Stage 1**: Basic rating system (thumbs up/down)
2. **Stage 2**: Smart recommendations based on ratings
3. **Stage 3**: YouTube discovery integration via yt-dlp
4. **Stage 4**: Lidarr auto-requesting for liked discoveries
5. **Stage 5**: Advanced features and UI polish

## ✅ Infrastructure Status
- ✅ Navidrome: Connected in Subtracks app
- ✅ Lidarr: API tested and working
- ✅ yt-dlp: Installed and ready
- ✅ Configuration: Saved in infrastructure_config.dart
- ✅ Ready for Stage 1 development

Last Updated: 2025-09-19