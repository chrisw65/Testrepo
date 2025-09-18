# Focus Flow

Focus Flow is a Flutter starter application that helps you design healthier focus habits, tackle procrastination, and build momentum through intentional, time-boxed work. The app demonstrates a lightweight productivity framework with guided prompts and tools that you can expand into a full product.

## Features

- **Dashboard snapshot** – Track your completion streak, recent wins, weekly focus minutes, and upcoming checkpoints at a glance.
- **Task planning workflow** – Break work into small, approachable focus tasks with priorities, estimated effort, due dates, and context tags.
- **Focus timer** – Launch distraction-free sessions, choose preset or custom durations, and log every block to reinforce consistency.
- **Insights and experiments** – Review focus history, celebrate wins, and receive adaptive suggestions to keep resistance low.
- **State management with Provider** – A simple `ChangeNotifier` powers the app state so you can quickly extend the behavior.

## Getting started

1. Ensure you have [Flutter](https://docs.flutter.dev/get-started/install) installed (`flutter --version` should work).
2. Fetch the dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on an emulator or device:
   ```bash
   flutter run
   ```
4. (Optional) Execute automated tests:
   ```bash
   flutter test
   ```

## Project structure

```
lib/
├── main.dart                # Entry point and global theme
├── models/                  # Task and focus session models
├── state/app_state.dart     # Application state, stats, and sample data
├── screens/                 # Feature screens (dashboard, tasks, timer, insights)
└── widgets/                 # Reusable presentation components
```

## Extending the framework

- Persist data by integrating `hive`, `sqflite`, or `shared_preferences` for local storage.
- Connect to calendar or notification APIs so focus sessions reserve time on your schedule.
- Expand analytics with charts (e.g., `fl_chart`) to visualize focus trends over time.
- Introduce accountability by syncing progress with friends or mentors.

## License

This project is provided as a starting point for experimentation. Adapt it freely for personal projects.
