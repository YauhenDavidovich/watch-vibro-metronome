import SwiftUI

struct ContentView: View {
    @StateObject private var engine = MetronomeEngine()

    private let signatures: [(label: String, beats: Int)] = [
        ("2/4", 2), ("3/4", 3), ("4/4", 4), ("6/8", 6)
    ]

    private let presets = [60, 80, 100, 120]

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(engine.isRunning ? "RUN" : "STOP")
                    .font(.caption2)
                    .foregroundStyle(engine.isRunning ? .green : .red)

                Text("\(engine.bpm) BPM")
                    .font(.title3).bold()

                Stepper("Темп", value: Binding(
                    get: { engine.bpm },
                    set: { engine.updateTempo($0) }
                ), in: 40...240)

                HStack {
                    ForEach(presets, id: \.self) { p in
                        Button("\(p)") {
                            engine.updateTempo(p)
                            engine.resetTapTempo()
                        }
                        .buttonStyle(.bordered)
                        .font(.caption2)
                    }
                }

                Button("🥁 Tap Tempo") {
                    engine.tapTempo()
                }
                .buttonStyle(.borderedProminent)

                Picker("Размер", selection: Binding(
                    get: { engine.beatsPerBar },
                    set: { engine.updateBeatsPerBar($0) }
                )) {
                    ForEach(signatures, id: \.beats) { s in
                        Text(s.label).tag(s.beats)
                    }
                }
                .pickerStyle(.segmented)

                Text(engine.currentBeat == 0 ? "—" : "Доля: \(engine.currentBeat)/\(engine.beatsPerBar)")
                    .font(.footnote)

                Button(engine.isRunning ? "Stop" : "Start") {
                    engine.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
