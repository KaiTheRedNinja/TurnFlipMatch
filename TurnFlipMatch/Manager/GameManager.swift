//
//  GameManager.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI

@Observable
class GameManager {
    /// The first hold
    var hold1 = Hold.hold1
    /// The second hold
    var hold2 = Hold.hold2
    /// The main grid that renders on the screen
    var mainGrid = RenderedGrid.empty
    /// The main grid that is actually used for comparisons
    var referenceGrid = MainGrid.empty
    /// The current play state
    var playState = PlayState.playing

    /// The current animation task. This task is responsible for playing rush, celebration, and loss animations.
    var animation: Task<Void, Never>?

    /// Generates a random valid main grid
    func randomiseMainGrid() {
        playState = .playing
        while true {
            // generate two random hold positions
            let hold1Pos = HoldPosition(edge: .allCases.randomElement()!, flipped: .random())
            let hold2Pos = HoldPosition(edge: .allCases.randomElement()!, flipped: .random())
            var hold1Candidate = Hold.hold1
            var hold2Candidate = Hold.hold2
            hold1Candidate.position = hold1Pos
            hold2Candidate.position = hold2Pos
            // check if they are valid, and not equal to the current main grid
            guard let grid = gridFromHolds(hold1: hold1Candidate, hold2: hold2Candidate), grid != referenceGrid else {
                // holds not valid, try again
                continue
            }
            // they are valid! Update the reference grid and exit
            referenceGrid = grid
//            hold1 = hold1Candidate
//            hold2 = hold2Candidate
            // send out the animation
            animation = Task {
                do {
                    try await animatePlayingMainGrid()
                } catch {
                    print("Playing main grid animation interrupted")
                }
            }
            return
        }
    }

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
    func didLose() {
        playState = .lost
        // play the lose animation
        animation?.cancel()
        animation = Task {
            // main grid becomes fully red for 0.5s
            mainGrid = .init(grid: .init(color: .red))
            do {
                try await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { throw CancellationError() }

                // TODO: determine if we want to auto-restart?
                randomiseMainGrid()
            } catch {
                print("Playing lost grid animation interrupted")
                return
            }
        }
    }

    /// Changes the state to winning
    func didWin() {
        print("Game WON!!!")
        playState = .celebration
        // play the lose animation
        animation?.cancel()
        animation = Task {
            func wait(_ time: Duration) async throws {
                try await Task.sleep(for: time)
                guard !Task.isCancelled else { throw CancellationError() }
            }

            do {
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

                // TODO: determine if we want to auto-restart?
                randomiseMainGrid()
            } catch {
                print("Playing win grid animation interrupted")
                return
            }
        }
    }

    /// Checks if the holds match the main grid. If it does, it is marked as a victory and the game is refreshed
    func checkForVictory() {
        guard gridFromHolds(hold1: hold1, hold2: hold2) == referenceGrid else { return }

        // victory!
        // TODO: some sort of points sysetm
        // TODO: some sort of celebration system
//        randomiseMainGrid()
        didWin()
    }

    /// Returns the grid produced by two holds, or `nil` if they do not produce a valid grid (overlapping cells are different, or the holds themselves take up the same position)
    func gridFromHolds(hold1: Hold, hold2: Hold) -> MainGrid? {
        // must not be on the same edge
        guard hold1.position.edge != hold2.position.edge else { return nil }

        // fill up the quadrants
        var grid = MainGrid.empty
        for hold in [hold1, hold2] {
            let cw = hold.currentCwColor
            let acw = hold.currentAcwColor
            let (acwQuad, cwQuad) = hold.position.quadrants

            // check if there are any conflicts
            if let existingCw = grid.colors[cwQuad], existingCw != cw { return nil }
            if let existingAcw = grid.colors[acwQuad], existingAcw != acw { return nil }

            // update the grid
            grid.colors[cwQuad] = cw
            grid.colors[acwQuad] = acw
        }
        return grid
    }
}

enum PlayState {
    case playing
    case celebration
    case lost
}
