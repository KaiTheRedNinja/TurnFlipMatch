//
//  GameManager+hold.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 11/11/26.
//

import SwiftUI

/// The minimum distance apart that holds can be
let angleThreshold: CGFloat = 60

extension GameManager {
    /// Informs the game manager of whether or not the hold is currently actually being held
    func markHold(_ id: HoldID, isHeld: Bool) {
        self[holdId: id].isHeld = isHeld
    }

    /// Informs the game manager of the intention to move the hold to the given angle. Returns the angle that the hold will be moved to.
    ///
    /// Note that this does not guarantee that the hold will move to that angle, as holds are not allowed to move through each other.
    func rotateHold(_ id: HoldID, moveToAngle newAngle: Angle) -> Angle {
        // move the other hold if needed
        let thisHold = self[holdId: id]
        let otherHold = self[holdId: id.other]
        let otherAngleClose = otherHold.angle.nearestEquivalent(to: newAngle)
        let difference = newAngle - otherAngleClose // how many degrees clockwise this hold is relative to the other
        print("Difference: \(difference.degrees)")
        if abs(difference.degrees) < angleThreshold {
            // if the other hold is not being held down, we move it
            if !otherHold.isHeld {
                let newOtherEdge = if difference > .zero {
                    // move the other hold ACW
                    otherHold.position.edge.acwNext
                } else {
                    // move the other hold CW
                    otherHold.position.edge.cwNext
                }
                _ = rotateHold(id.other, moveToAngle: .degrees(newOtherEdge.degrees).nearestEquivalent(to: otherHold.angle))
            } else {
                // the other hold is being held down, so we don't move
                print("Can't overlap!")
                return thisHold.angle
            }
        }

        // ensure that the other angle does not lie between the current angle and the new angle
        // use this code if you want to restrict the arc from 180 deg to smaller: abs((newAngle - thisHold.angle).wrap().degrees) < 2 * angleThreshold
        if otherAngleClose.isBetween(thisHold.angle, newAngle) {
            print("Can't move across a hold!")
            return thisHold.angle
        }

        // move this hold
        self[holdId: id].angle = newAngle
        let newEdge = EdgePosition.closest(toDegrees: newAngle.degrees)
        if newEdge != thisHold.position.edge {
            self[holdId: id].position.edge = newEdge
            // a hold was changed, trigger haptic and check for victory
            playHaptic()
            checkForVictory()
        }
        return newAngle
    }

    /// Informs the game manager of the intention to move the hold to the given edge. Returns the angle that the hold will be moved to.
    ///
    /// Note that this does not guarantee that the hold will move to that angle, as holds are not allowed to move through each other. However,
    /// unlike `rotateHold`, this function will NOT move the other hold under any circumstances.
    func moveHold(_ id: HoldID, moveToEdge newEdge: EdgePosition) -> Angle {
        let thisHold = self[holdId: id]
        let otherHold = self[holdId: id.other]
        let fallbackAngle = Angle.degrees(thisHold.position.edge.degrees).nearestEquivalent(to: thisHold.angle)

        // determine if the other hold is in the way
        let newAngle = Angle.degrees(newEdge.degrees).nearestEquivalent(to: thisHold.angle)
        let otherAngleClose = otherHold.angle.nearestEquivalent(to: newAngle)
        let difference = newAngle - otherAngleClose // how many degrees clockwise this hold is relative to the other
        print("Difference: \(difference.degrees)")
        if abs(difference.degrees) < angleThreshold {
            // the other hold is being held down, so we just stick to the current edge
            print("Can't overlap!")
            self[holdId: id].angle = fallbackAngle
            return fallbackAngle
        }
        // ensure that the other angle does not lie between the current angle and the new angle
        // use this code if you want to restrict the arc from 180 deg to smaller: abs((newAngle - thisHold.angle).wrap().degrees) < 2 * angleThreshold
        if otherAngleClose.isBetween(thisHold.angle, newAngle) {
            print("Can't move across a hold!")
            self[holdId: id].angle = fallbackAngle
            return fallbackAngle
        }

        // move this hold
        self[holdId: id].angle = newAngle
        if newEdge != thisHold.position.edge {
            self[holdId: id].position.edge = newEdge
            // a hold was changed, trigger haptic and check for victory
            playHaptic()
            checkForVictory()
        }
        return newAngle
    }

    /// Informs the game manager of the intention to flip the hold.
    ///
    /// Unlike `rotateHold`, this will flip the hold no matter what.
    func flipHold(_ id: HoldID) {
        self[holdId: id].position.flipped.toggle()
        playHaptic()
        checkForVictory()
    }
}
