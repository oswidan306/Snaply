# Snaply Development Roadmap

## Phase 1 - Core Features & Local Storage

### 1. Photo and Diary Entry (✓ Completed)
- Photo capture/selection
- Text overlay
- Drawing capabilities
- Emotion selection
- Entry saving

### 2. Calendar View (In Progress)
- Local storage setup (CoreData)
- Photo thumbnail calendar implementation
- Entry viewing functionality
- Month navigation
- Entry management (edit/delete)

### 3. Connections View
- Emotion-based clustering algorithm
- Dynamic line stroke weights
- Interactive visualization
- Entry preview/selection
- Smooth animations for transitions

## Phase 2 - Remote Integration & Enhanced Features

### 1. Supabase Integration
- Project setup
- User authentication
- Data model migration
- Sync functionality
- Backup/restore features

### 2. Enhanced Calendar Features
- Search/filter entries
- Multiple view options (month/year)
- Entry statistics
- Quick entry preview

### 3. Enhanced Connections Features
- Zoom/pan capabilities
- Emotion filtering
- Connection strength visualization
- Entry grouping options

## Phase 3 - Polish & App Store Release

### 1. Performance Optimization
- Image caching
- Lazy loading
- Memory management
- Animation optimization

### 2. User Experience
- Onboarding flow
- Tutorial/help system
- Settings/preferences
- Haptic feedback
- Error handling

### 3. App Store Preparation
- Privacy policy
- Terms of service
- App Store screenshots
- Marketing materials
- Analytics integration

## Technical Requirements

### Data Models
swift
struct DiaryEntry {
let id: UUID
let date: Date
let photo: UIImage
let diaryText: String
var emotions: [Emotion]
var textOverlays: [TextOverlay]
var drawings: [DrawingPath]
}
struct EmotionConnection {
let sourceEntry: UUID
let targetEntry: UUID
let matchingEmotions: [Emotion]
var connectionStrength: Float // 0.0 - 1.0 based on matching emotions
}

### Storage Requirements
- Local: CoreData for entries and connections
- Remote: Supabase tables for users, entries, and connections
- Image storage optimization

### UI Components
- Custom calendar with thumbnails
- Interactive connection visualization
- Smooth transitions and animations
- Consistent design language