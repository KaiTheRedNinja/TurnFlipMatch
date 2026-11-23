//
//  Tone.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 15/11/26.
//

import AVFAudio
import Foundation

@MainActor
private final class TonePlaybackManager {

    static let shared = TonePlaybackManager()

    private var activePlayers: [AVAudioPlayer] = []

    func play(
        duration: TimeInterval,
        frequency: Double,
        amplitude: Float
    ) {
        guard duration.isFinite,
              duration > 0,
              duration <= 600,
              frequency.isFinite,
              frequency >= 20,
              frequency <= 20_000,
              amplitude.isFinite,
              amplitude > 0,
              amplitude <= 1
        else {
            return
        }

        let sampleRate = 48_000.0
        let frameCount = Int((duration * sampleRate).rounded())

        guard frameCount > 1,
              let data = makeWAV(
                  frameCount: frameCount,
                  sampleRate: Int(sampleRate),
                  frequency: frequency,
                  amplitude: amplitude
              )
        else { return }

        do {
            let player = try AVAudioPlayer(data: data)

            player.volume = 1
            player.numberOfLoops = 0
            // NOTE: this throws a lot of errors about being on the main actor? is this fixable?
            player.prepareToPlay()

            activePlayers.append(player)

            guard player.play() else {
                activePlayers.removeAll { $0 === player }
                return
            }

            // Retain the player until playback completes.
            Task {
                try? await Task.sleep(
                    for: .seconds(player.duration + 1)
                )

                activePlayers.removeAll { $0 === player }
            }

        } catch {
            print("Unable to play tone: \(error)")
        }
    }

    // generate a pure sine waveform
    private func makeWAV(
        frameCount: Int,
        sampleRate: Int,
        frequency: Double,
        amplitude: Float
    ) -> Data? {
        let bytesPerSample = 2
        let dataSize = frameCount * bytesPerSample

        guard let dataSize32 = UInt32(exactly: dataSize),
              let sampleRate32 = UInt32(exactly: sampleRate),
              let frameCount32 = UInt32(exactly: frameCount)
        else { return nil }

        var data = Data()

        func appendLE<T: FixedWidthInteger>(_ value: T) {
            var value = value.littleEndian
            Swift.withUnsafeBytes(of: &value) {
                data.append(contentsOf: $0)
            }
        }

        // WAV header: PCM, mono, 16-bit.
        data.append(contentsOf: Array("RIFF".utf8))
        appendLE(UInt32(36) + dataSize32)
        data.append(contentsOf: Array("WAVE".utf8))

        data.append(contentsOf: Array("fmt ".utf8))
        appendLE(UInt32(16))                 // Header size
        appendLE(UInt16(1))                  // PCM
        appendLE(UInt16(1))                  // Mono
        appendLE(sampleRate32)
        appendLE(sampleRate32 * 2)           // Byte rate
        appendLE(UInt16(2))                  // Block alignment
        appendLE(UInt16(16))                 // Bits per sample

        data.append(contentsOf: Array("data".utf8))
        appendLE(dataSize32)

        let fadeDuration = 0.005 // 5 milliseconds
        let fadeFrames = max(
            1,
            Int(fadeDuration * Double(sampleRate))
        )

        let angularFrequency =
            2.0 * Double.pi * frequency / Double(sampleRate)

        for index in 0..<frameCount {

            let position = Double(index)

            // Raised-cosine fade-in and fade-out.
            let fadeIn = min(
                1.0,
                0.5 - 0.5 * cos(
                    Double.pi * position / Double(fadeFrames)
                )
            )

            let remaining = Double(frameCount - 1 - index)

            let fadeOut = min(
                1.0,
                0.5 - 0.5 * cos(
                    Double.pi * remaining / Double(fadeFrames)
                )
            )

            let envelope = min(fadeIn, fadeOut)

            let sample = sin(angularFrequency * position)
                * Double(amplitude)
                * envelope

            let pcm = Int16(
                (sample * Double(Int16.max)).rounded()
            )

            appendLE(pcm)
        }

        return data
    }
}

// Fire-and-forget public API.
func playPureTone(
    duration: TimeInterval,
    frequency: Double = 440,
    amplitude: Float = 0.5
) {
    Task { @MainActor in
        TonePlaybackManager.shared.play(
            duration: duration,
            frequency: frequency,
            amplitude: amplitude
        )
    }
}
