//
//  GameManagerDelegate.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 15/11/26.
//

import Foundation

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

    /// Requests an override to the grid. If `nil` is returned, it will randomly generate a grid.
    ///
    /// If the `gridOverride` parameter of `stateChangePlaying` is specified, that value will be used instead and this function will not be called.
    func getGridOverride() -> ColorGrid?
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
    func getGridOverride() -> ColorGrid? { nil }
}
