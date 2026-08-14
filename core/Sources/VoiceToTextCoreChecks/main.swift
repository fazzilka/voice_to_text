import VoiceToTextCore

let chunk = PCMChunk(samples: Array(repeating: 0, count: 32_000))
let checks: [(passed: Bool, message: String)] = [
    (
        RecordingPolicy.maximumRecordingSeconds == 2_400,
        "recording limit must be 40 minutes"
    ),
    (
        RecordingPolicy.maximumPendingRecordingSeconds
            > RecordingPolicy.maximumRecordingSeconds,
        "recovery journal must have headroom"
    ),
    (
        RecordingPolicy.maximumPendingRecordingBytes == 172_800_016,
        "recovery journal byte limit is inconsistent"
    ),
    (chunk.durationSeconds == 2, "PCM duration calculation is incorrect"),
]
let failures = checks.compactMap { $0.passed ? nil : $0.message }

if failures.isEmpty {
    print("VoiceToTextCore checks passed.")
} else {
    fatalError(failures.joined(separator: "\n"))
}
