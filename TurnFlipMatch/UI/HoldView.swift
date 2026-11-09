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
        .overlay {
            Text("\(hold.position.edge)")
        }
        .onTapGesture {
            hold.position.flipped = !hold.position.flipped
        }
        .offset(x: cellWidth * 1.5 + cellSpacing + gridHandleSpacing)
        .rotationEffect(.degrees(-hold.position.edge.degrees))
    }
}

