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

    /// `0` for not flipped, `pi` for flipped
    @State var flipAngle: Angle = .zero

    var body: some View {
        let centerPoint = CGPoint(x: mainGridWidth/2, y: mainGridWidth/2)
        let offsetDist = cellWidth + cellSpacing + gridHandleSpacing + handleCellWidth/2 + 10
        let hold = manager[holdId: holdId]

        ZStack {
            sideColors(hold: hold, isSide1: !hold.position.flipped)
                .rotation3DEffect(flipAngle, axis: (x: 1, y: 0, z: 0))
                .scaleEffect(y: hold.position.flipped ? -1 : 1)
        }
        .animation(.easeIn(duration: 0.2), value: hold.position.flipped)
        .onChange(of: hold.position.flipped, initial: true) { _, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                flipAngle = newValue ? .degrees(180) : .degrees(0)
            }
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
        .onChange(of: hold.angle) { _, newValue in // update from external signals
            // ignore external signals if we are holding
            guard !hold.isHeld else { return }
            // update the internal stored angle
            storedAngle = hold.angle
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("mainGrid"))
                .onChanged { value in
                    manager.markHold(holdId, isHeld: true)

                    let startPolar = Polar(point: value.startLocation.vflip(), center: centerPoint.vflip())
                    let currentPolar = Polar(point: value.location.vflip(), center: centerPoint.vflip())
                    let difference = currentPolar.angle - startPolar.angle

                    withAnimation(.interactiveSpring) {
                        _ = manager.rotateHold(holdId, moveToAngle: (storedAngle + difference).nearestEquivalent(to: hold.angle))
                    }
                }
                .onEnded { value in
                    defer { manager.markHold(holdId, isHeld: false) }

                    guard value.translation.magnitude >= 10 else {
                        // flip and align
                        manager.flipHold(holdId)
                        let newEdge = EdgePosition.closest(toDegrees: hold.angle.degrees)
                        let newAngle = Angle.degrees(newEdge.degrees).nearestEquivalent(to: hold.angle)
                        withAnimation(.interactiveSpring) {
                            storedAngle = manager.rotateHold(holdId, moveToAngle: newAngle)
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
                    withAnimation(.interactiveSpring) {
                        storedAngle = manager.moveHold(holdId, moveToEdge: chosenEdge)
                    }
                }
        )
    }

    func sideColors(hold: Hold, isSide1: Bool) -> some View {
        VStack(spacing: cellSpacing) {
            hold.colorFor(side1: !isSide1, isClockwise: true).color
                .frame(width: handleCellWidth * 0.8, height: cellSpacing)
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: 10, bottomTrailing: 10)))

            hold.colorFor(side1: isSide1, isClockwise: false).color
                .frame(width: handleCellWidth, height: cellWidth)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            hold.colorFor(side1: isSide1, isClockwise: true).color
                .frame(width: handleCellWidth, height: cellWidth)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            hold.colorFor(side1: !isSide1, isClockwise: false).color
                .frame(width: handleCellWidth * 0.8, height: cellSpacing)
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10, topTrailing: 10)))
        }
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary)
        }
    }
}
