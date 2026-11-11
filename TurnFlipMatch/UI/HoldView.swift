//
//  HoldView.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI

struct HoldView: View {
    @Binding var hold: Hold

    @State var currentAngle: Angle = .zero
    @State var storedAngle: Angle = .zero

    var body: some View {
        let centerPoint = CGPoint(x: mainGridWidth/2, y: mainGridWidth/2)
        let offsetDist = cellWidth + cellSpacing + gridHandleSpacing + handleCellWidth/2

        VStack(spacing: cellSpacing) {
            hold.oppositeCwColor.color
                .frame(width: handleCellWidth, height: cellSpacing)
            hold.currentAcwColor.color
                .frame(width: handleCellWidth, height: cellWidth)
            hold.currentCwColor.color
                .frame(width: handleCellWidth, height: cellWidth)
            hold.oppositeAcwColor.color
                .frame(width: handleCellWidth, height: cellSpacing)
        }
        .overlay {
            Text("\(hold.position.edge.rawValue)")
        }
        // equation for a square with side lengths 2r:
        // distance = l / cos((theta-pi/4 mod pi/2) - pi/4)
        .offset(
            x: offsetDist / cos(
                (currentAngle.radians + .pi/4).posRemainder(dividingBy: .pi/2) - .pi/4
            )
        )
        .rotationEffect(-currentAngle)
        .onChange(of: hold.position.edge, initial: true) { _, newValue in
            let currentEdge = EdgePosition.closest(toDegrees: currentAngle.degrees)
            if currentEdge != newValue {
                // current edge and new value are different, we update the position
                // TODO: animate?
                currentAngle = .degrees(newValue.degrees)
                storedAngle = currentAngle
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("mainGrid"))
                .onChanged { value in
                    let startPolar = Polar(point: value.startLocation.vflip(), center: centerPoint.vflip())
                    let currentPolar = Polar(point: value.location.vflip(), center: centerPoint.vflip())
                    let difference = currentPolar.angle - startPolar.angle

                    withAnimation(.interactiveSpring) {
                        currentAngle = (storedAngle + difference).nearestEquivalent(to: currentAngle)
                    }
                }
                .onEnded { value in
                    if value.translation.magnitude <= 10 {
                        // flip
                        hold.position.flipped = !hold.position.flipped
                        return
                    }
                    // animate to the closest position
                    let newEdge = EdgePosition.closest(toDegrees: currentAngle.degrees)
                    hold.position.edge = newEdge
                    withAnimation(.interactiveSpring) {
                        currentAngle = .degrees(newEdge.degrees).nearestEquivalent(to: currentAngle)
                        storedAngle = currentAngle
                    }
                }
        )
    }
}
