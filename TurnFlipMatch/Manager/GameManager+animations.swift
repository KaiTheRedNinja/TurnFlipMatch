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
        mainGrid.grid = referenceGrid
        mainGrid.brightness = 0

        func wait(_ time: Duration) async throws {
            try await Task.sleep(for: time)
            guard !Task.isCancelled, referenceGrid == currentGrid else { throw CancellationError() }
        }

        // wait 3s, because outside 3s is not rushing
        try await wait(.seconds(3))
        // start blinking, PD of 50% at 2Hz for 3s (six cycles)
        for _ in 0..<6 {
            // off for 0.25s
            mainGrid.brightness = -0.5
            try await wait(.milliseconds(250))
            // on for 0.25s
            mainGrid.brightness = 0
            try await wait(.milliseconds(250))
        }
        //        // the game has been lost, change state
        //        print("Game lost :(")
        //        didLose()
    }

    /// Changes the state to losing
    func animateLostMainGrid() async throws {
        // main grid becomes fully red for 0.5s
        mainGrid = .init(grid: .init(color: .red))

        try await Task.sleep(for: .milliseconds(500))
        guard !Task.isCancelled else { throw CancellationError() }

        // TODO: determine if we want to auto-restart?
        stateChangePlaying()
    }

    /// Changes the state to winning
    func animateWinMainGrid() async throws {
        func wait(_ time: Duration) async throws {
            try await Task.sleep(for: time)
            guard !Task.isCancelled else { throw CancellationError() }
        }
        mainGrid.brightness = 0

        // every 0.1s we mark another square green
        mainGrid.grid.colors[.topLeft] = .green
        try await wait(.milliseconds(100))
        mainGrid.grid.colors[.topRight] = .green
        try await wait(.milliseconds(100))
        mainGrid.grid.colors[.bottomRight] = .green
        try await wait(.milliseconds(100))
        mainGrid.grid.colors[.bottomLeft] = .green

        // every 0.1s we wipe the screen, in the same order
        try await wait(.milliseconds(100))
        mainGrid.grid.colors[.topLeft] = nil
        try await wait(.milliseconds(100))
        mainGrid.grid.colors[.topRight] = nil
        try await wait(.milliseconds(100))
        mainGrid.grid.colors[.bottomRight] = nil
        try await wait(.milliseconds(100))
        mainGrid.grid.colors[.bottomLeft] = nil

        // if the number of points means we're in a new phase, change it
        let newPhase = (points/5) + 1
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
        mainGrid = .init(grid: .init(color: .green))

        for _ in 0..<phase {
            // turn off
            mainGrid.brightness = -0.5
            try await wait(.milliseconds(250))
            // turn on
            mainGrid.brightness = 0.0
            try await wait(.milliseconds(250))
        }

        // change to playing
        stateChangePlaying()
    }
}
