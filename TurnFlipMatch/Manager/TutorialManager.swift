//
//  TutorialManager.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 14/11/26.
//

import SwiftUI

enum TutorialPhase: Int {
    /// Inform the user that they can flip a hold
    ///
    /// Requirements:
    /// - Flip a hold once
    case flipping
    /// Inform the user that they can rotate a hold
    ///
    /// Requirements:
    /// - Move a hold once
    case rotating
    /// Inform the user that they can move two holds at once
    ///
    /// Requirements:
    /// - Have both holds held down at the same time
    /// - Move both holds
    case twoAtOnce
    /// Trial match. The same as playing, but will be set such that the timer never expires.
    ///
    /// Requirements:
    /// - Win a match
    case match
    /// No requirements, just play.
    case ready
}

protocol TutorialTracker {
    init()
    func isComplete() -> Bool
}

struct TutorialFlipTracker: TutorialTracker {
    var hasFlippedHold: Bool
    var gameWon: Bool

    init() {
        hasFlippedHold = false
        gameWon = false
    }

    func isComplete() -> Bool { hasFlippedHold && gameWon }
}

struct TutorialRotateTracker: TutorialTracker {
    var hasMovedHold: Bool
    var gameWon: Bool

    init() {
        hasMovedHold = false
        gameWon = false
    }

    func isComplete() -> Bool { hasMovedHold && gameWon }
}

struct TutorialTwoAtOnceTracker: TutorialTracker {
    /// Whether both trackers have been held down together at any point during this tutorial phase - i.e. both `isHeld` are true.
    var bothHeldDown: Bool
    var hold1Moved: Bool
    var hold2Moved: Bool
    var gameWon: Bool

    init() {
        self.bothHeldDown = false
        self.hold1Moved = false
        self.hold2Moved = false
        self.gameWon = false
    }

    func isComplete() -> Bool {
        bothHeldDown && hold1Moved && hold2Moved && gameWon
    }
}

struct TutorialMatchTracker: TutorialTracker {
    var gameWon: Bool

    init() { gameWon = false }

    func isComplete() -> Bool { gameWon }
}

struct TutorialReadyTracker: TutorialTracker {
    init() {}

    func isComplete() -> Bool { true }
}

@Observable
class TutorialManager: GameManagerDelegate {
    var isActive: Bool = false
    var phase: TutorialPhase = .flipping
    var tracker: (any TutorialTracker)?
    var instructions: String = ""

    weak var gameManager: GameManager!

    /// Starts a tutorial by attaching it to the game manager
    func start(gameManager: GameManager) {
        isActive = true
        gameManager.delegate = self
        gameManager.phase = -100_000 // remove time limit
        self.gameManager = gameManager
        changePhase(to: .flipping)
    }

    /// Exits the tutorial
    func exit() {
        isActive = false
        gameManager.delegate = nil
        gameManager.points = 0
        gameManager.phase = 1
        gameManager.stateChangeIdle()
    }

    /// Triggers the next phase
    func nextPhase() {
        switch phase {
        case .flipping: changePhase(to: .rotating)
        case .rotating: changePhase(to: .twoAtOnce)
        case .twoAtOnce: changePhase(to: .match)
        case .match: changePhase(to: .ready)
        case .ready: exit()
        }
    }

    /// Changes the phase to the given phase
    func changePhase(to newPhase: TutorialPhase) {
        self.phase = newPhase
        switch newPhase {
        case .flipping: startFlippingPhase()
        case .rotating: startRotatePhase()
        case .twoAtOnce: startTwoAtOncePhase()
        case .match: startMatchPhase()
        case .ready: startReadyPhase()
        }
    }

    /// Generates a grid that can be solved just by flipping just one hold.
    func startFlippingPhase() {
        tracker = TutorialFlipTracker()
        // reset the holds to default position
        gameManager.hold1 = .hold1
        gameManager.hold2 = .hold2
        // manually set the game
        var hold1Candidate = gameManager.hold1
        hold1Candidate.position.flipped = true
        let grid = gameManager.gridFromHolds(hold1: hold1Candidate, hold2: gameManager.hold2)
        gameManager.stateChangePlaying(gridOverride: grid)

        // update the instructions
        instructions = "In this game, you move the holds to match the pattern in the middle. Tap on the left hold to flip it!"
    }

    /// Generates a grid that can be solved by just rotating one hold.
    func startRotatePhase() {
        tracker = TutorialRotateTracker()
        // the holds should be hold1 = left flipped, hold2 = right normal
        // manually set the game
        var hold1Candidate = Hold.hold1
        hold1Candidate.position.flipped = true
        var hold2Candidate = Hold.hold2
        hold2Candidate.position.edge = .top
        let grid = gameManager.gridFromHolds(hold1: hold1Candidate, hold2: hold2Candidate)
        gameManager.stateChangePlaying(gridOverride: grid)

        // update the instructions
        instructions = "Other than flipping, holds can also be moved. Drag the right hold to move it!"
    }

    /// Generates a grid that has to be solved by just rotating two holds.
    func startTwoAtOncePhase() {
        tracker = TutorialTwoAtOnceTracker()
        // the holds should be hold1 = left flipped, hold2 = top normal
        // manually set the game
        var hold1Candidate = Hold.hold1
        hold1Candidate.position.flipped = true
        hold1Candidate.position.edge = .bottom
        var hold2Candidate = Hold.hold2
        hold2Candidate.position.flipped = true
        hold2Candidate.position.edge = .right
        let grid = gameManager.gridFromHolds(hold1: hold1Candidate, hold2: hold2Candidate)
        gameManager.stateChangePlaying(gridOverride: grid)

        // update the instructions
        instructions = "To save time, you can drag two holds at the same time"
    }

    /// Starts a game
    func startMatchPhase() {
        tracker = TutorialMatchTracker()
        // dont care what phase it is rn, just trigger play.
        gameManager.phase = 1
        gameManager.stateChangePlaying()
        instructions = "You have a time limit, starting at \(Int(startingTimeSec))s. As you play, it will get shorter!"
    }

    /// Informs the user that they should be ready
    func startReadyPhase() {
        tracker = TutorialReadyTracker()
        gameManager.stateChangeIdle()
        instructions = "That's it! Ready to play?"
    }

    func holdDidFlip(flippedHold: HoldID) {
        update(tracker: &tracker, as: TutorialFlipTracker.self) { flipTracker in
            flipTracker.hasFlippedHold = true
        }
    }
    func holdDidRotate(rotatedHold: HoldID) { /* intentionally left empty */ }
    func holdDidChangeEdge(changedHold: HoldID) {
        update(tracker: &tracker, as: TutorialRotateTracker.self) { rotateTracker in
            rotateTracker.hasMovedHold = true
        }
        update(tracker: &tracker, as: TutorialTwoAtOnceTracker.self) { twoTracker in
            switch changedHold {
            case .one: twoTracker.hold1Moved = true
            case .two: twoTracker.hold2Moved = true
            }
        }
    }
    func holdDidChangeHeld(changedHold: HoldID) {
        update(tracker: &tracker, as: TutorialTwoAtOnceTracker.self) { twoTracker in
            guard let gameManager else { return }
            if gameManager.hold1.isHeld && gameManager.hold2.isHeld {
                twoTracker.bothHeldDown = true
            }
        }
    }
    func userDidEnterPlaying() {
        // if the user entered playing when they have already succeeded, we enter idle instead
        guard tracker?.isComplete() == true else { return }
        gameManager.stateChangeIdleNoAnimation()
        gameManager.referenceGrid = .init(all: .green)
        gameManager.mainGrid.color = gameManager.referenceGrid
    }
    func userDidEnterCelebration() {
        update(tracker: &tracker, as: TutorialFlipTracker.self) { flipTracker in
            flipTracker.gameWon = true
        }
        update(tracker: &tracker, as: TutorialRotateTracker.self) { rotateTracker in
            rotateTracker.gameWon = true
        }
        update(tracker: &tracker, as: TutorialTwoAtOnceTracker.self) { twoTracker in
            twoTracker.gameWon = true
        }
        update(tracker: &tracker, as: TutorialMatchTracker.self) { matchTracker in
            matchTracker.gameWon = true
        }
    }
    func userDidEnterLost() { /* intentionally left empty - everything handled in getGridOverride and userDidEnterPlaying */ }
    func userDidEnterIdle() {
        // if the user entered idle without having completed the task, we immediately boot back into playing
        if tracker?.isComplete() != true {
            gameManager.stateChangePlaying(gridOverride: gameManager.referenceGrid)
        }
    }
    func getGridOverride() -> ColorGrid? {
        // The only time we want to actually have a random map is during match phase. Else, we just use the current grid.
        if phase == .match { return nil }
        return gameManager.referenceGrid
    }
}

fileprivate func update<Tracker: TutorialTracker>(tracker: inout (any TutorialTracker)?, as: Tracker.Type, operation: (inout Tracker) -> Void) {
    guard var value = tracker as? Tracker else { return }
    operation(&value)
    tracker = value
}
