//
//  MainGridView.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI

struct MainGridView: View {
    var grid: RenderedGrid

    var body: some View {
        VStack(spacing: cellSpacing) {
            HStack(spacing: cellSpacing) {
                ledCell(forQuad: .topLeft)
                ledCell(forQuad: .topRight)
            }
            HStack(spacing: cellSpacing) {
                ledCell(forQuad: .bottomLeft)
                ledCell(forQuad: .bottomRight)
            }
        }
        .padding(cellSpacing)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary)
        }
    }

    func ledCell(forQuad quad: Quadrant) -> some View {
        grid.uiColor(forQuad: quad)
            .saturation(2.0)
            .brightness(grid.uiBrightness(forQuad: quad))
            .overlay {
                grid.uiColor(forQuad: quad)
                    .brightness(grid.uiBrightness(forQuad: quad) + 0.3)
                    .frame(width: cellWidth/2, height: cellWidth/2)
                    .blur(radius: cellWidth/4)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(width: cellWidth, height: cellWidth)
    }
}
