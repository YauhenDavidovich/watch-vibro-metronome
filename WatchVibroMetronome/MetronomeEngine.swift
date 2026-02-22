import Foundation
import Combine

final class MetronomeEngine: ObservableObject {
    @Published var bpm: Int = 100
    @Published var beatsPerBar: Int = 4
    @Published var isRunning: Bool = false
    @Published var currentBeat: Int = 0 // 1...beatsPerBar when running

    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "metronome.engine.queue", qos: .userInteractive)

    private var tapTimes: [Date] = []
    private let tapWindowSeconds: TimeInterval = 2.5

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

    func tapTempo() {
        let now = Date()
        tapTimes.append(now)
        tapTimes = tapTimes.filter { now.timeIntervalSince($0) <= tapWindowSeconds }

        guard tapTimes.count >= 2 else { return }

        var intervals: [TimeInterval] = []
        for i in 1..<tapTimes.count {
            intervals.append(tapTimes[i].timeIntervalSince(tapTimes[i - 1]))
        }

        guard !intervals.isEmpty else { return }
        let avg = intervals.reduce(0, +) / Double(intervals.count)
        guard avg > 0.2, avg < 2.0 else { return } // ~30...300 BPM safety

        let estimated = Int(round(60.0 / avg))
        updateTempo(estimated)
    }

    func resetTapTempo() {
        tapTimes.removeAll()
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
