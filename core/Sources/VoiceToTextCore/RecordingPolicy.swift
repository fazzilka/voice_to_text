import Foundation

/// Platform-neutral limits shared by every VoiceToText client.
public enum RecordingPolicy {
    public static let sampleRate: Double = 16_000
    public static let maximumRecordingSeconds: TimeInterval = 40 * 60

    public static let pendingFileVersion: UInt32 = 1
    public static let pendingHeaderSize = 16
    public static let maximumPendingRecordingSeconds: TimeInterval = 45 * 60
    public static let maximumPendingRecordingBytes =
        Int(maximumPendingRecordingSeconds * sampleRate * 4) + pendingHeaderSize
}
