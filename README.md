# Flutter Explore Page - Real-time Social Media Issues Tracker

A Flutter application that displays real-time civic issues from Twitter, Koo, and Facebook with interactive list and map views.

## Features

- **Real-time Data Integration**: Fetches live issues from Twitter API, Koo, and Facebook
- **Dual View Interface**: Switch between List view and Map view
- **Auto-refresh**: Automatically updates every 10 minutes
- **Source Filtering**: Filter issues by Twitter, Koo, Facebook, or view all
- **Interactive Maps**: OpenStreetMap integration with location markers
- **Location Services**: Shows user location and geocoded issue addresses
- **Rich UI**: Material Design 3 with source badges, images, and engagement metrics
- **Deduplication**: Removes similar issues automatically

## Setup Instructions

1. **Install Flutter**: Make sure Flutter SDK is installed and configured
2. **Get Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Generate Code** (if needed):
   ```bash
   flutter packages pub run build_runner build
   ```
4. **Run the App**:
   ```bash
   flutter run
   ```

## API Configuration

The app uses Twitter API v2 with the following credentials (already configured):
- Bearer Token: Integrated in `lib/services/twitter_service.dart`

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── issue.dart              # Issue data model
│   └── issue.g.dart            # Generated JSON serialization
├── services/
│   ├── data_service.dart       # Main data management service
│   ├── twitter_service.dart    # Twitter API integration
│   ├── koo_service.dart        # Koo scraping service
│   ├── facebook_service.dart   # Facebook data service
│   └── location_service.dart   # Location and geocoding
├── screens/
│   └── explore_page.dart       # Main explore page
└── widgets/
    ├── issue_list_view.dart    # List view component
    ├── issue_map_view.dart     # Map view component
    └── source_filter_chips.dart # Source filter UI
```

## How It Works

1. **Data Collection**: 
   - Twitter: Uses Twitter API v2 to search for civic issues
   - Koo: Web scraping for public posts about problems
   - Facebook: Sample realistic data (production would need Graph API)

2. **Data Processing**:
   - Normalizes data from all sources into unified Issue model
   - Geocodes addresses using location services
   - Deduplicates similar issues
   - Refreshes automatically every 10 minutes

3. **User Interface**:
   - **List View**: Scrollable cards with issue details, images, and metadata
   - **Map View**: Interactive OpenStreetMap with issue markers
   - **Filtering**: Toggle between sources or view all combined
   - **Real-time Updates**: Live status indicators and refresh controls

## Usage

1. **Launch**: App opens directly to Explore page (no login required)
2. **View Issues**: Browse issues in list or map view
3. **Filter Sources**: Use chips to filter by Twitter, Koo, Facebook, or all
4. **Interact**: Tap issues for details, tap map markers for info cards
5. **Refresh**: Pull to refresh or use refresh button for latest data
6. **Location**: Grant location permission to see your position on map

## Dependencies

- `flutter_map`: Interactive maps with OpenStreetMap
- `http` & `dio`: API requests and web scraping
- `provider`: State management
- `geolocator` & `geocoding`: Location services
- `cached_network_image`: Efficient image loading
- `url_launcher`: Open external links

## Notes

- App works offline with cached data
- Location permission enhances map experience
- Twitter API has rate limits (handled gracefully)
- Sample data provided for Koo and Facebook for demo purposes
