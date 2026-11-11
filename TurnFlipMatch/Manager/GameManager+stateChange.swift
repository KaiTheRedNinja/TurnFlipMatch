//
//  GameManager+stateChange.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 11/11/26.
//

extension GameManager {
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
        _ = Task {
            do {
                try await Task.sleep(for: .milliseconds(200))
            } catch {
                print("Could not wait for victory")
            }

            // check again if we're still winning
            guard gridFromHolds(hold1: hold1, hold2: hold2) == referenceGrid else { return }
            // if so, we won!
            stateChangeWin()
        }
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
