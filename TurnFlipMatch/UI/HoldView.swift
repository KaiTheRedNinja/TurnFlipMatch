//
//  HoldView.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI

struct HoldView: View {
    @State var manager: GameManager
    var holdId: HoldID

    @State var storedAngle: Angle = .zero

    var body: some View {
        let centerPoint = CGPoint(x: mainGridWidth/2, y: mainGridWidth/2)
        let offsetDist = cellWidth + cellSpacing + gridHandleSpacing + handleCellWidth/2
        let hold = manager[holdId: holdId]

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
                (hold.angle.radians + .pi/4).posRemainder(dividingBy: .pi/2) - .pi/4
            )
        )
        .rotationEffect(-hold.angle)
        .onAppear {
            storedAngle = .degrees(hold.angle.degrees)
        }
        .onChange(of: hold.position.edge) { _, newValue in // update from external signals
            let currentEdge = EdgePosition.closest(toDegrees: hold.angle.degrees)
            if currentEdge != newValue {
                // current edge and new value are different, we update the position
                // TODO: animate?
                let newAngle = Angle.degrees(newValue.degrees)
                manager.rotateHold(holdId, moveToAngle: newAngle)
                storedAngle = newAngle
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("mainGrid"))
                .onChanged { value in
                    let startPolar = Polar(point: value.startLocation.vflip(), center: centerPoint.vflip())
                    let currentPolar = Polar(point: value.location.vflip(), center: centerPoint.vflip())
                    let difference = currentPolar.angle - startPolar.angle

                    // current polar must be more than the offset distance away
                    // otherwise it will spin quite crazy
//                    guard currentPolar.magnitude > offsetDist * 0.8 else {
//                        print("Too close!")
//                        return
//                    }

                    withAnimation(.interactiveSpring) {
                        manager.rotateHold(holdId, moveToAngle: (storedAngle + difference).nearestEquivalent(to: hold.angle))
                    }
                }
                .onEnded { value in
                    guard value.translation.magnitude >= 10 else {
                        // flip and align
                        manager.flipHold(holdId)
                        let newEdge = EdgePosition.closest(toDegrees: hold.angle.degrees)
                        let newAngle = Angle.degrees(newEdge.degrees).nearestEquivalent(to: hold.angle)
                        withAnimation(.interactiveSpring) {
                            manager.rotateHold(holdId, moveToAngle: newAngle)
                            storedAngle = newAngle
                        }
                        return
                    }

                    let startPolar = Polar(point: value.startLocation.vflip(), center: centerPoint.vflip())
                    let projectedEndPolar = Polar(point: value.predictedEndLocation.vflip(), center: centerPoint.vflip())
                    let difference = projectedEndPolar.angle - startPolar.angle
                    // preserve inertia, calculate end based off of projected end position
                    let projectedEndAngle = (storedAngle + difference).nearestEquivalent(to: hold.angle)
                    let projectedEndEdge = EdgePosition.closest(toDegrees: projectedEndAngle.degrees)

                    // if the projected end angle is too close to the center (magnitude too small) or it results in skipping by
                    // more than one edge (e.g. back to front), we just use the current position
                    let chosenEdge: EdgePosition = if projectedEndPolar.magnitude > offsetDist * 0.8, projectedEndEdge.isNextTo(hold.position.edge) {
                        projectedEndEdge
                    } else {
                        // if not, then we just stick to where we are
                        hold.position.edge
                    }

                    // animate to the chosen position
                    let newAngle = Angle.degrees(chosenEdge.degrees).nearestEquivalent(to: hold.angle)
                    withAnimation(.interactiveSpring) {
                        manager.rotateHold(holdId, moveToAngle: newAngle)
                        storedAngle = newAngle
                    }
                }
        )
    }
}
