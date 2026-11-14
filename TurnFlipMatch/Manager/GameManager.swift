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
    var referenceGrid: ColorGrid
    /// The current play state
    var playState: PlayState = .idle

    /// The current number of points
    var points: Int = 0
    /// The current phase. This is equal to `floor(points/10)+1`, and controls the speed of the game.
    var phase: Int = 1

    /// The current animation task. This task is responsible for playing rush, celebration, and loss animations.
    var animation: Task<Void, Never>?

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
