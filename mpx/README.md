# Music Vibe - MPX

**A Flutter application that tracks your emotional trends and generates a weekly forecast based on recent listenings.**

MP-X will analyze your Spotify listening data, predicts your emotional state, and recommends a playlist to help balance or enhance your mood. The app also provides an “Emotional Forecast” showing projected moods for the upcoming week based on your listening behavior. 

## App Pitch
Music directly influences emotional well-being, MP-X incorporates your listening habits into a predictive model that determines your mood and generate a playlists to help support or uplift you. By integrating Spotify APIs with mood analysis, MP-X delivers a personalized emotional experience that evolves with your music taste.

## MVVM Architecture (Separation of Concerns)
Music Vibe follows a  MVVM (Model–View–ViewModel) architecture to ensure scalability, testability, and maintainability.   

### Models
Responsible for structured data representation:  
- `mood_data.dart` — Mood enums and emotion mappings
- Spotify data formatted into track, audio feature, and playlist objects

### ViewModels
Business logic and state management:  
- `auth_viewmodel.dart`
  - Handles Spotify authentication state
  - Manages login, logout, and session persistence
- Exposes immutable app state to the UI using `Provider`  

### Views   
UI widgets only:  
- `login_page.dart` — Spotify authentication UI  
- `landing_page.dart` — Emotional forecast dashboard   
- `callback_page.dart` — OAuth redirect handler  

## Firebase and API
**Spotify Web API**  
Music Vibe integrates multiple Spotify endpoints:  
- Authentication & OAuth
- User Profile
- Playback History (Recently Played)
- Audio Features (energy, valence, danceability)
- Artist Genres
- Recommendations
- User Playlists
- Playlist Creation

**Firebase**  
* Firebase Hosting: https://music-vibe-718b5.web.app/
* Firebase CLI: firebase deploy --only hosting --project music-vibe-718b5

## Build Instructions and Dependencies 
**Instructions**
run 'flutter pub get'  
run 'flutter build web'  
run 'firebase deploy --only hosting --project music-vibe-718b5'   

**Dependencies**
* Provider 
* http
* shared_preferences
* flutter_localizations
* intl
* url_launcher
* flutter_svg


**Developed by Jessica Baek and Danielle Paton**   
**University of Pittsburgh — CS 1635**    
**User Interface Design Methodology — Final MPX Project**  