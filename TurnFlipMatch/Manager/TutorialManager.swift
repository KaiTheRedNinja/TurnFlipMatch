//
//  TutorialManager.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 14/11/26.
//

import SwiftUI

enum TutorialPhase: Int {
    /// Inform the user that they can flip a hold
    case flipping
    /// Inform the user that they can rotate a hold
    case rotating
    /// Inform the user that they can move two holds at once
    case twoAtOnce
    /// Trial match
    case match
    /// Allow the user to play a regular game
    case ready
}
