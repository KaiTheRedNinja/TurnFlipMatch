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
    var playState: PlayState = .playing

    /// The current number of points
    var points: Int = 0
    /// The current phase. This is equal to `floor(points/5)+1`, and controls the speed of the game.
    var phase: Int = 1

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

    func playHaptic() {
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred(intensity: 1.0)
    }
}

enum PlayState {
    case playing
    case celebration
    // every 5 wins, the phase changes. Each phase change reduces the time by 10%.
    case phaseChange
    case lost
}
