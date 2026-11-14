//
//  GameManager+animations.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 11/11/26.
//

import SwiftUI

extension GameManager {
    /// Animates the main grid during play
    func animatePlayingMainGrid() async throws {
        let currentGrid = referenceGrid // make sure we're still operating on the same grid
        mainGrid.color = referenceGrid
        mainGrid.brightness = .allHigh

        func wait(_ time: Duration) async throws {
            try await Task.sleep(for: time)
            guard !Task.isCancelled, referenceGrid == currentGrid else { throw CancellationError() }
        }

        // at the start, the user will have 10s.
        // this will decrease to 3s starting at phase 11
        // the very last 2 seconds will have flashing, four flashes = game over
        let totalSeconds: CGFloat = 10.0 - 0.7 * CGFloat(phase - 1)/10.0
        let nonRushSeconds: CGFloat = totalSeconds - 2

        // wait 3s, because outside 3s is not rushing
        try await wait(.milliseconds(Int(nonRushSeconds * 1000)))
        // start blinking, PD of 50% at 2Hz for 2s (four cycles)
        for _ in 0..<4 {
            // off for 0.25s
            mainGrid.brightness = .allOff
            try await wait(.milliseconds(250))
            // on for 0.25s
            mainGrid.brightness = .allHigh
            try await wait(.milliseconds(250))
        }
        // the game has been lost, change state
        print("Game lost :(")
        stateChangeLose()
    }

    /// Changes the state to losing
    func animateLostMainGrid() async throws {
        // main grid becomes fully red for 0.5s
        mainGrid = .init(color: .init(all: .red))

        try await Task.sleep(for: .milliseconds(500))
        guard !Task.isCancelled else { throw CancellationError() }

        stateChangeIdle()
    }

    /// Changes the state to winning
    func animateWinMainGrid() async throws {
        func wait(_ time: Duration) async throws {
            try await Task.sleep(for: time)
            guard !Task.isCancelled else { throw CancellationError() }
        }
        mainGrid.brightness = .allHigh

        // every 0.1s we mark another square green
        mainGrid.color.cells[.topLeft] = .green
        try await wait(.milliseconds(100))
        mainGrid.color.cells[.topRight] = .green
        try await wait(.milliseconds(100))
        mainGrid.color.cells[.bottomRight] = .green
        try await wait(.milliseconds(100))
        mainGrid.color.cells[.bottomLeft] = .green

        // every 0.1s we wipe the screen, in the same order
        try await wait(.milliseconds(100))
        mainGrid.color.cells[.topLeft] = nil
        try await wait(.milliseconds(100))
        mainGrid.color.cells[.topRight] = nil
        try await wait(.milliseconds(100))
        mainGrid.color.cells[.bottomRight] = nil
        try await wait(.milliseconds(100))
        mainGrid.color.cells[.bottomLeft] = nil

        // if the number of points means we're in a new phase, change it
        let newPhase = (points/10) + 1
        if newPhase > phase {
            // do a phase change before switching to playing
            phase = newPhase
            try await animatePhaseChangeMainGrid(phase: newPhase)
        } else {
            // same phase, change to playing
            stateChangePlaying()
        }
    }

    func animatePhaseChangeMainGrid(phase: Int) async throws {
        // blink according to what the phase is now
        func wait(_ time: Duration) async throws {
            try await Task.sleep(for: time)
            guard !Task.isCancelled else { throw CancellationError() }
        }

        // make all green
        mainGrid = .init(color: .init(all: .green))

        // wait 0.5s
        try await wait(.milliseconds(500))

        // no more than 10 flashes, since that would be 5 whole seconds
        for _ in 0..<min(10, phase) {
            // turn off
            mainGrid.brightness = .allOff
            try await wait(.milliseconds(250))
            // turn on
            mainGrid.brightness = .allHigh
            try await wait(.milliseconds(250))
        }

        // change to playing
        stateChangePlaying()
    }
}
