//
//  RotationManager.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 14/11/26.
//

import CoreMotion
import SwiftUI

@Observable
class RotationManager {
    @ObservationIgnored
    lazy var motion: CMMotionManager = .init()

    var motionTracking: Bool = false
    var currentMotion: CMDeviceMotion?

    func startDeviceMotion() {
        guard motion.isDeviceMotionAvailable else {
            print("Device motion not available")
            return
        }

        motion.deviceMotionUpdateInterval = 1.0 / 120.0 // attempt to get 120Hz updates
        motion.showsDeviceMovementDisplay = true

        motion.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] update, error in
            guard let self else { return }
            if let error {
                print("Error: \(error)")
                return
            }
            guard let update = update else {
                print("No motion provided")
                return
            }

            self.currentMotion = update
        }
    }

    func stopDeviceMotion() {
        motion.stopDeviceMotionUpdates()
    }

    deinit {
        stopDeviceMotion()
    }
}
