import Foundation
import Combine

final class MetronomeEngine: ObservableObject {
    @Published var bpm: Int = 100
    @Published var beatsPerBar: Int = 4
    @Published var isRunning: Bool = false
    @Published var currentBeat: Int = 0 // 1...beatsPerBar when running

    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "metronome.engine.queue", qos: .userInteractive)

    func start() {
        guard !isRunning else { return }
        isRunning = true
        currentBeat = 0
        scheduleTimer()
    }

    func stop() {
        isRunning = false
        currentBeat = 0
        timer?.cancel()
        timer = nil
    }

    func toggle() {
        isRunning ? stop() : start()
    }

    func updateTempo(_ newBpm: Int) {
        bpm = max(40, min(240, newBpm))
        if isRunning { scheduleTimer() }
    }

    func updateBeatsPerBar(_ beats: Int) {
        beatsPerBar = max(1, beats)
        currentBeat = 0
    }

    private func scheduleTimer() {
        timer?.cancel()

        let interval = 60.0 / Double(bpm)
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(3))

        t.setEventHandler { [weak self] in
            guard let self else { return }
            guard self.isRunning else { return }

            let next = (self.currentBeat % self.beatsPerBar) + 1
            DispatchQueue.main.async {
                self.currentBeat = next
                HapticPattern.play(isStrongBeat: next == 1)
            }
        }

        timer = t
        t.resume()
    }
}
