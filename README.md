# Focus Flow

Focus Flow is a comprehensive Flutter application that helps you build better habits, tackle procrastination, manage your time effectively, and maintain focus through intentional work. The app combines habit tracking with productivity tools, creating a complete system for personal growth and time management across web, iOS, and Android platforms.

## Features

### Habit Tracking
- **Daily habit tracking** – Check off habits as you complete them, build streaks, and track your consistency over time
- **Streak visualization** – See your current and longest streaks with visual feedback and motivational indicators
- **Habit categories** – Organize habits by type: Health, Productivity, Learning, Mindfulness, Social, Creative, Fitness, and more
- **Smart analytics** – View completion rates, weekly/monthly statistics, and progress indicators for each habit
- **Customizable habits** – Create habits with custom icons, colors, descriptions, and frequency targets
- **Quick dashboard check-in** – Complete habits directly from the main dashboard for quick access

### Time Management & Procrastination
- **Momentum cockpit** – Gradient hero cards surface streaks, focus minutes, average session length, and quick recommendations for deep work, quick wins, and approaching deadlines
- **Guided rituals** – Morning, pre-focus, and reset rituals with affirmations and step-by-step checklists help you prime your environment and decompress intentionally
- **Dynamic task planner** – Segment tasks by context, filter by priority or tag, preview quick wins, and log micro focus sessions or completions directly from enriched task cards
- **Adaptive focus timer** – Choose between deep work, momentum, or recovery modes, adjust durations, capture intentions, and stitch in warm-up and cooldown prompts
- **Insight studio** – Explore sparkline charts, heatmaps, tag balance breakdowns, reflection timelines, and an antidote library tailored to your friction patterns
- **Provider-driven state** – All insights and workflows are powered by an opinionated `ChangeNotifier`, making it easy to expand or swap persistence layers later

### Cross-Platform Support
- **Web** – Responsive design with navigation rail for larger screens and optimized layouts
- **iOS** – Native feel with Cupertino-style widgets and smooth animations
- **Android** – Material Design 3 with adaptive components and platform-specific interactions

## Getting started

1. Ensure you have [Flutter](https://docs.flutter.dev/get-started/install) installed (`flutter --version` should work).
2. Clone this repository:
   ```bash
   git clone <repository-url>
   cd Testrepo
   ```
3. Fetch the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app on your preferred platform:
   - **Web**: `flutter run -d chrome`
   - **iOS**: `flutter run -d ios` (requires macOS and Xcode)
   - **Android**: `flutter run -d android`
   - **Auto-detect**: `flutter run` (automatically selects available device)
5. (Optional) Execute automated tests:
   ```bash
   flutter test
   ```

## Project structure

```
lib/
├── main.dart                # Entry point and global theme
├── models/                  # Data models
│   ├── habit.dart          # Habit tracking model with streaks and completion history
│   ├── task.dart           # Task management model
│   ├── focus_session.dart  # Focus timer session records
│   ├── reflection_entry.dart  # Daily reflection entries
│   ├── procrastination_trigger.dart  # Procrastination patterns and antidotes
│   └── support_ritual.dart # Morning, pre-focus, and reset rituals
├── state/
│   └── app_state.dart      # Centralized app state with Provider
├── screens/                # Main feature screens
│   ├── dashboard_screen.dart  # Overview with habit summary and momentum metrics
│   ├── habits_screen.dart     # Full habit tracking interface
│   ├── tasks_screen.dart      # Task management and planning
│   ├── focus_timer_screen.dart  # Pomodoro-style focus sessions
│   ├── insights_screen.dart   # Analytics and reflection tools
│   └── home_screen.dart       # Navigation shell with responsive layout
└── widgets/                # Reusable UI components
    ├── habit_calendar.dart    # Visual habit completion calendar
    ├── gradient_card.dart     # Styled cards with gradient backgrounds
    ├── focus_heatmap.dart     # Focus session heatmap visualization
    ├── sparkline_chart.dart   # Miniature trend charts
    └── progress_ring.dart     # Circular progress indicators
```

## Key Features in Detail

### Habit Tracking System
The habit tracking system helps you build consistency and overcome procrastination through:
- **Visual progress tracking**: See your streaks and completion history at a glance
- **Flexible scheduling**: Set daily habits or custom frequency targets (e.g., 5x per week)
- **Categories**: Organize habits by category with custom icons and colors
- **Smart reminders**: Set reminder times for each habit (UI ready, persistence needed)
- **Dashboard integration**: Quick check-in directly from the main screen

### Procrastination Management
Combat procrastination with evidence-based strategies:
- **Trigger identification**: Recognize patterns like overwhelm, unclear next steps, perfectionism
- **Actionable antidotes**: Get specific micro-steps and supporting questions
- **Reflection tools**: Daily mood, energy, and focus tracking with insights
- **Ritual guidance**: Structured morning, pre-focus, and reset rituals

### Responsive Design
The app automatically adapts to different screen sizes:
- **Large screens (web/tablet)**: Extended navigation rail with labels
- **Medium screens**: Compact navigation rail
- **Small screens (mobile)**: Bottom navigation bar

## Extending the Framework

- **Persist data** by integrating `hive`, `sqflite`, or `shared_preferences` for local storage
- **Push notifications** for habit reminders and focus session alerts
- **Cloud sync** to back up habits and sync across devices
- **Social features** for accountability partners and shared progress
- **Advanced analytics** with `fl_chart` for detailed visualizations
- **Calendar integration** to block focus time and track habits with calendar events
- **Gamification** with achievements, badges, and challenges
- **Export/import** data for backup and migration

## License

This project is provided under an open license—adapt it freely to match your personal workflow or team environment.
