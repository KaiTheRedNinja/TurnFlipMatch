//
//  GameManager.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI
import CoreHaptics

@Observable
class GameManager {
    /// The first hold
    var hold1: Hold
    /// The second hold
    var hold2: Hold
    /// Get and set a copy of the requested hold
    subscript (holdId holdId: HoldID) -> Hold {
        get {
            switch holdId {
            case .one: hold1
            case .two: hold2
            }
        }
        set {
            switch holdId {
            case .one: hold1 = newValue
            case .two: hold2 = newValue
            }
        }
    }
    /// The main grid that renders on the screen
    var mainGrid: RenderedGrid
    /// The main grid that is actually used for comparisons
    var referenceGrid: MainGrid
    /// The current play state
    var playState: PlayState = .playing

    /// The current number of points
    var points: Int = 0;

    /// The current animation task. This task is responsible for playing rush, celebration, and loss animations.
    var animation: Task<Void, Never>?

    init() {
        self.hold1 = .hold1
        self.hold2 = .hold2
        self.mainGrid = .empty
        self.referenceGrid = .empty
        self.playState = .playing
        self.points = 0

        // set up haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Device does not support haptics")
            return
        }
    }

    /// Informs the game manager of the intention to move the hold to the given angle.
    ///
    /// Note that this does not guarantee that the hold will move to that angle, as holds are not allowed to move through each other.
    func rotateHold(_ id: HoldID, moveToAngle newAngle: Angle) {
        // TODO: check if the angle is valid. Each hold should not be allowed to move any closer than 80 degrees from the other.
        self[holdId: id].angle = newAngle
        let newEdge = EdgePosition.closest(toDegrees: newAngle.degrees)
        if newEdge != self[holdId: id].position.edge {
            self[holdId: id].position.edge = newEdge
            // a hold was changed, trigger haptic and check for victory
            playHaptic()
            checkForVictory()
        }
    }

    /// Informs the game manager of the intention to flip the hold.
    ///
    /// Unlike `rotateHold`, this will flip the hold no matter what.
    func flipHold(_ id: HoldID) {
        self[holdId: id].position.flipped.toggle()
        playHaptic()
        checkForVictory()
    }

    func playHaptic() {
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred(intensity: 1.0)
    }

    /// Generates a random valid main grid
    func stateChangePlaying() {
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

    /// Changes the state to losing
    func stateChangeLose() {
        print("Game lost :(")
        // TODO: end game?
        playState = .lost
        // play the lose animation
        animation?.cancel()
        animation = Task {
            do {
                try await animateLostMainGrid()
            } catch {
                print("Playing lost grid animation interrupted")
                return
            }
        }
    }

    /// Changes the state to winning
    func stateChangeWin() {
        print("Game WON!!!")
        points += 1
        playState = .celebration
        // play the lose animation
        animation?.cancel()
        animation = Task {
            do {
                try await animateWinMainGrid()
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
        stateChangeWin()
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
