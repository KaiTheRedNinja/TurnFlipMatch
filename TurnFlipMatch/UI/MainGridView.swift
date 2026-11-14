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
                (grid.grid.cells[.topLeft]?.color ?? Color.gray.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: cellWidth, height: cellWidth)
                (grid.grid.cells[.topRight]?.color ?? Color.gray.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: cellWidth, height: cellWidth)
            }
            HStack(spacing: cellSpacing) {
                (grid.grid.cells[.bottomLeft]?.color ?? Color.gray.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: cellWidth, height: cellWidth)
                (grid.grid.cells[.bottomRight]?.color ?? Color.gray.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: cellWidth, height: cellWidth)
            }
        }
        .brightness(grid.brightness)
        .padding(cellSpacing)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary)
        }
    }
}
