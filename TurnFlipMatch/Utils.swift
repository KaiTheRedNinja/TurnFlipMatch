//
//  Utils.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 11/11/26.
//

import SwiftUI

extension CGSize {
    var magnitude: CGFloat {
        sqrt(width*width + height*height)
    }
}

struct Polar {
    var center: CGPoint
    var magnitude: CGFloat
    var angle: Angle

    init(point: CGPoint, center: CGPoint = .zero) {
        let magnitude = center.distanceTo(other: point)
        let angleRad = center.angleRadTo(other: point)
        self.magnitude = magnitude
        self.angle = .radians(angleRad)
        self.center = center
    }
}

extension CGPoint {
    /// Flips a point along the x-axis
    func vflip() -> CGPoint {
        .init(x: self.x, y: -self.y)
    }

    func distanceTo(other: CGPoint) -> CGFloat {
        let dx = other.x - self.x
        let dy = other.y - self.y
        return sqrt(dx * dx + dy * dy)
    }

    func angleRadTo(other: CGPoint) -> CGFloat {
        let dx = other.x - self.x
        let dy = other.y - self.y
        // calculate base angle, which will be between 0 and 180 degrees
        let base: CGFloat = if dx == 0 {
            .pi * 0.5
        } else {
            (atan(dy/dx) + .pi).truncatingRemainder(dividingBy: .pi)
        }
        // increase by 180 degrees if in 3rd and 4th quadrants (i.e. negative y)
        return base + (dy >= 0 ? 0 : .pi)
    }

    init(polar: Polar) {
        self.init(
            x: polar.center.x + polar.magnitude * cos(polar.angle.radians),
            y: polar.center.y + polar.magnitude * sin(polar.angle.radians)
        )
    }
}

extension Angle {
    /// Returns the angle which is trigonometrically equivalent to `self`, but has a difference of the smallest magnitude to `reference`.
    func nearestEquivalent(to reference: Angle) -> Angle {
        let rounds = ((reference.radians - self.radians)/(2 * .pi)).rounded()
        return self + .radians(2.0 * .pi * rounds)
    }
}

infix operator %%
extension BinaryFloatingPoint {
    func posRemainder(dividingBy rhs: Self) -> Self {
        let mod = self.truncatingRemainder(dividingBy: rhs)
        return mod >= 0 ? mod : mod + rhs
    }
}
