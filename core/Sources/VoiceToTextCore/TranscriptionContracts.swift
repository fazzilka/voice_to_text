import Foundation

/// Canonical audio representation at the boundary between capture and ASR.
/// Platform adapters are responsible for converting microphone input to mono
/// Float32 samples before constructing this value.
public struct PCMChunk: Sendable, Equatable {
    public let samples: [Float]
    public let sampleRate: Int

    public init(samples: [Float], sampleRate: Int = Int(RecordingPolicy.sampleRate)) {
        self.samples = samples
        self.sampleRate = sampleRate
    }

    public var durationSeconds: TimeInterval {
        guard sampleRate > 0 else { return 0 }
        return TimeInterval(samples.count) / TimeInterval(sampleRate)
    }
}

public struct Transcript: Sendable, Equatable {
    public let text: String
    public let durationSeconds: TimeInterval

    public init(text: String, durationSeconds: TimeInterval) {
        self.text = text
        self.durationSeconds = durationSeconds
    }
}

/// Implemented by the native macOS engine today and by future Windows/Linux
/// adapters without coupling the shared domain to AppKit or AVFoundation.
public protocol SpeechTranscribing: Sendable {
    func transcribe(_ audio: PCMChunk) async throws -> Transcript
}

/// Destination for a finished transcript: active application, clipboard,
/// file, or another platform-specific integration.
public protocol TranscriptDestination: Sendable {
    func deliver(_ transcript: Transcript) async throws
}
