//
//  GameManager.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI
import CoreHaptics

let startingTimeSec: CGFloat = 10.0
let endingTimeSec: CGFloat = 3.0
let maxPhases: CGFloat = 10.0

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
    var referenceGrid: ColorGrid
    /// The current play state
    var playState: PlayState = .idle

    /// The current number of points
    var points: Int = 0
    /// The current phase. This is equal to `floor(points/10)+1`, and controls the speed of the game.
    var phase: Int = 1

    /// The delegate
    weak var delegate: (any GameManagerDelegate)?

    /// The current animation task. This task is responsible for playing rush, celebration, and loss animations.
    private(set) var animation: Task<Void, Never>?

    init() {
        self.hold1 = .hold1
        self.hold2 = .hold2
        self.mainGrid = .empty
        self.referenceGrid = .empty
        self.playState = .idle
        self.points = 0

        // set up haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Device does not support haptics")
            return
        }

        // enter idle state
        stateChangeIdle()
    }

    func playHaptic() {
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred(intensity: 1.0)
    }

    func playAnimation<E: Error>(name: String, task: @escaping () async throws(E) -> Void) {
        print("Playing \(name) animation")
        animation?.cancel()
        animation = Task {
            do {
                try await task()
                print("Ended \(name) animation")
            } catch {
                print("Stopped \(name) animation: interrupted due to \(error.localizedDescription)")
                return
            }
        }
    }
}

/// The states that the game can be in.
///
/// ```
///   ╭----- lost
///   ↓        ↑
/// idle -→ playing -→ celebration -→ phaseChange
///            ↑            |              |
///            ╰------------╯←-------------╯
/// ```
enum PlayState {
    /// The game is not running
    case idle
    /// The user must match the tiles to the current main grid
    case playing
    /// The user has just successfully matched a grid, play a celebration animation
    case celebration
    /// The user has just successfully matched a grid 10 times, play a phase change animation.
    /// Each phase change reduces the time, starting at 10s all the way down to 3.
    case phaseChange
    /// The user failed to match the holds within the given time. Play a lose animation.
    case lost
}

protocol GameManagerDelegate: AnyObject {
    /// Informs the delegate that a hold has been flipped
    func holdDidFlip(flippedHold: HoldID)
    /// Informs the delegate that a hold has changed angle, but not nescessarily that it has changed edge
    func holdDidRotate(rotatedHold: HoldID)
    /// Informs the delegate that a hold has moved to a new edge
    func holdDidChangeEdge(changedHold: HoldID)
    /// Informs the delegate that the `isHeld` state of a hold has changed
    func holdDidChangeHeld(changedHold: HoldID)

    /// Informs the delegate that the game has started
    func userDidEnterPlaying()
    /// Informs the delegate that the user has successfully matched a tile. This corresponds with entering the `celebration` play state.
    func userDidEnterCelebration()
    /// Informs the delegate that the user has failed to match a tile. This corresponds with entering the `lost` play state.
    func userDidEnterLost()
    /// Informs the delegate that the game has returned to idle state
    func userDidEnterIdle()
}

/// Default implementations
extension GameManagerDelegate {
    func holdDidFlip(flippedHold: HoldID) {}
    func holdDidRotate(rotatedHold: HoldID) {}
    func holdDidChangeEdge(changedHold: HoldID) {}
    func holdDidChangeHeld(changedHold: HoldID) {}
    func userDidEnterPlaying() {}
    func userDidEnterCelebration() {}
    func userDidEnterLost() {}
    func userDidEnterIdle() {}
}
