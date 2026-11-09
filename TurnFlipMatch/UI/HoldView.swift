//
//  HoldView.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI

struct HoldView: View {
    @Binding var hold: Hold

    var body: some View {
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
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    if value.translation.magnitude <= 10 {
                        // flip
                        hold.position.flipped = !hold.position.flipped
                        return
                    }

                    // check clockwise and anticlockwise movement
                    // note that it defaults to being on the right side, and the gesture rotates with the view.
                    if value.translation.height > 0 {
                        hold.position.edge = hold.position.edge.acwNext
                    } else {
                        hold.position.edge = hold.position.edge.cwNext
                    }
                }
        )
        .offset(x: cellWidth * 1.5 + cellSpacing + gridHandleSpacing)
        .rotationEffect(.degrees(-hold.position.edge.degrees))
    }
}

extension CGSize {
    var magnitude: CGFloat {
        sqrt(width*width + height*height)
    }
}
