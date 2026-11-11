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
                (grid.grid.colors[.topLeft]?.color ?? Color.clear)
                    .frame(width: cellWidth, height: cellWidth)
                (grid.grid.colors[.topRight]?.color ?? Color.clear)
                    .frame(width: cellWidth, height: cellWidth)
            }
            HStack(spacing: cellSpacing) {
                (grid.grid.colors[.bottomLeft]?.color ?? Color.clear)
                    .frame(width: cellWidth, height: cellWidth)
                (grid.grid.colors[.bottomRight]?.color ?? Color.clear)
                    .frame(width: cellWidth, height: cellWidth)
            }
        }
        .brightness(grid.brightness)
    }
}
