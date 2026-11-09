//
//  GameManager.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI

@Observable
class GameManager {
    var hold1 = Hold.hold1
    var hold2 = Hold.hold2
    var mainGrid = MainGrid.empty

    /// Generates a random valid main grid
    func randomiseMainGrid() {
        while true {
            // generate two random hold positions
            let hold1Pos = HoldPosition(edge: .allCases.randomElement()!, flipped: .random())
            let hold2Pos = HoldPosition(edge: .allCases.randomElement()!, flipped: .random())
            var hold1Candidate = Hold.hold1
            var hold2Candidate = Hold.hold2
            hold1Candidate.position = hold1Pos
            hold2Candidate.position = hold2Pos
            // check if they are valid, and not equal to the current main grid
            guard let grid = gridFromHolds(hold1: hold1Candidate, hold2: hold2Candidate), grid != mainGrid else {
                // holds not valid, try again
                continue
            }
            // they are valid! Update the main grid and exit
            mainGrid = grid
//            hold1 = hold1Candidate
//            hold2 = hold2Candidate
            return
        }
    }

    /// Checks if the holds match the main grid. If it does, it is marked as a victory and the game is refreshed
    func checkForVictory() {
        guard gridFromHolds(hold1: hold1, hold2: hold2) == mainGrid else { return }

        // victory!
        // TODO: some sort of points sysetm
        // TODO: some sort of celebration system
        randomiseMainGrid()
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
