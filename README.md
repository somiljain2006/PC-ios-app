# Programming-Club - iOS App
A comprehensive iOS application built with SwiftUI for competitive programming enthusiasts. It serves as a unified hub for the Programming Club community to track daily challenges, discuss problems, read editorials, and stay updated on coding events.
## Features
### Authentication & Profiles
- **Secure Access**: Integrated with Supabase for robust authentication.
- **Session Management**: Magic link / Deep link support for session recovery and password resets.
- **User Profiles**: Manage personal information and community presence.
## Integrated Platforms
- LeetCode
- Codeforces
- CodeChef
- AtCoder
### Home & Dashboard
- **Daily Challenges**: An interactive, swipeable carousel featuring problems from LeetCode, Codeforces, AtCoder, and CodeChef.
- **Challenge Pinning**: Save and pin specific problems for quick access later using local storage.
- **Network Monitoring**: Real-time network status checks to handle offline scenarios gracefully.
### Community & Interaction
- **Community Chat**: Real-time group messaging backed by Supabase with support for text and media (full-screen image viewing).
- **Group Management**: Create new groups, rename existing ones, and add members seamlessly.
- **AskPC (AI Assistant)**: A futuristic, intelligent coding assistant to help users with their programming queries (requires newer iOS environments).
### Learning & Events
- **Editorials**: Detailed write-ups, explanations, and code snippets for various competitive programming contests.
- **Events**: Track upcoming community meetups and programming competitions.
- **Widgets**: Home and Lock Screen widgets to keep track of your GitHub, LeetCode, Codeforces, and AtCoder metrics at a glance.
## Design
- **Theme**: Dark and vibrant aesthetics (`Color.background` with deep purple/red accents) for a modern, developer-focused look.
- **Animations**: Smooth transitions, spring-based swipe gestures for the challenge carousel, and engaging splash screen animations.
- **UI Components**: Custom bottom navigation bar, dynamic loading skeletons, and interactive cards for a premium user experience.
## Screenshots
## Project Structure
```text
PC-ios-app/
├── PC/
│   ├── App/
│   │   ├── PCApp.swift               # Application entry point and deep link handling
│   │   └── ContentView.swift         # Splash screen and initial routing
│   ├── Core/
│   │   ├── SupabaseManager.swift     # Supabase client configuration
│   │   ├── AuthValidator.swift       # Authentication state validation
│   │   ├── NetworkMonitor.swift      # Real-time connectivity tracking
│   │   └── NotificationManager.swift # Local push notifications
│   ├── Features/
│   │   ├── Home/                     # Dashboard, daily challenges, and pinned items
│   │   ├── Chat/                     # Real-time messaging and group management
│   │   ├── Editorials/               # Contest solutions and problem explanations
│   │   ├── Events/                   # Upcoming contests and community events
│   │   ├── Profile/                  # User account and preferences
│   │   └── AskPC/                    # AI coding assistant interface
│   ├── Shared/
│   │   ├── Models.swift              # App-wide data models (Codeforces, LeetCode, etc.)
│   │   ├── UI/                       # Reusable UI components
│   │   └── Extensions/               # Swift extensions and utilities
│   └── PCWidgets/                    # iOS Home and Lock Screen widgets
```
## Backend Configuration
**Platform**: Supabase
- Handles secure authentication, real-time database subscriptions (for Chat), and user profile management.
- Configuration requires `Secrets.xcconfig` to store sensitive API keys and database URLs.
## Setup & Installation
1. Clone the repository to your local machine.
2. Open `PC.xcodeproj` in Xcode.
3. Configure your Supabase credentials:
   - Ensure `Secrets.xcconfig` is populated with your specific Supabase URL and Anon Key.
4. In the project navigator, select the `PC` project.
5. Go to the **Signing & Capabilities** tab and select your development team.
6. Choose an iOS simulator or a connected physical device.
7. Hit `Cmd + R` or click the Play button to build and run the application.
## Architecture & State Management
- **UI Framework**: Exclusively uses SwiftUI for declarative UI development.
- **Concurrency**: Heavily relies on modern Swift Concurrency (`async/await` and `Task`) for all network requests and background operations.
- **State Management**: Uses `@StateObject`, `@Environment`, and specialized singleton managers (e.g., `ProblemService`, `PinnedChallengeManager`) to maintain app state.
- **Caching**: Implements robust local caching strategies (`ChatCache`, `ProblemCache`) for faster load times and offline support.
## Requirements
- **OS**: iOS 16.0+ 
- **IDE**: Xcode 15.0+
- **Language**: Swift 5.9+
## Notes
- Uses local push notifications to alert users (`NotificationDelegate`).
- Widgets refresh automatically when the app enters the foreground.
- Support for deep linking handles authentication session recovery.
## Contributing
1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.
