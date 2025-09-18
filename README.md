# Focus Flow

Focus Flow is a Flutter application that helps you design healthier focus habits, tackle procrastination, and build momentum through intentional, time-boxed work. The experience ships with a cohesive productivity system featuring guided prompts, deep work tools, and insights you can rely on immediately, while still leaving room for future customization.

## Features

- **Momentum cockpit** – Gradient hero cards surface streaks, focus minutes, average session length, and quick recommendations for deep work, quick wins, and approaching deadlines.
- **Guided rituals** – Morning, pre-focus, and reset rituals with affirmations and step-by-step checklists help you prime your environment and decompress intentionally.
- **Dynamic task planner** – Segment tasks by context, filter by priority or tag, preview quick wins, and log micro focus sessions or completions directly from enriched task cards.
- **Adaptive focus timer** – Choose between deep work, momentum, or recovery modes, adjust durations, capture intentions, and stitch in warm-up and cooldown prompts.
- **Insight studio** – Explore sparkline charts, heatmaps, tag balance breakdowns, reflection timelines, and an antidote library tailored to your friction patterns.
- **Provider-driven state** – All insights and workflows are powered by an opinionated `ChangeNotifier`, making it easy to expand or swap persistence layers later.

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

This project is provided under an open license—adapt it freely to match your personal workflow or team environment.
