# Watch Vibro Metronome

Apple Watch metronome (watchOS 10+) with **haptic-only** feedback.

## Features (MVP)
- BPM 40...240
- Time signatures: 2/4, 3/4, 4/4, 6/8
- Start / Stop
- Strong beat accent (strong haptic on beat 1, light haptic on others)
- Preset BPM buttons
- Tap Tempo (настучи нужный ритм вручную)

## Create project in Xcode
1. Open Xcode → **File → New Project → watchOS App**
2. Product name: `WatchVibroMetronome`
3. Interface: SwiftUI, Language: Swift
4. Deployment target: **watchOS 10.0**
5. Replace generated files with code from this repo.

## Files
- `WatchVibroMetronomeApp.swift`
- `ContentView.swift`
- `MetronomeEngine.swift`
- `HapticPattern.swift`

## Notes
- Uses `WKInterfaceDevice.current().play(...)` for haptics.
- No audio output.
