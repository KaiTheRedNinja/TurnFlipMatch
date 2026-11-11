//
//  Grid.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 11/11/26.
//

import Foundation

struct MainGrid: Equatable {
    var colors: [Quadrant: CellColor]

    init(colors: [Quadrant : CellColor]) {
        self.colors = colors
    }

    init(color: CellColor?) {
        self.colors = [
            .topLeft: color,
            .topRight: color,
            .bottomLeft: color,
            .bottomRight: color
        ].compactMapValues { $0 }
    }

    static let empty = MainGrid(colors: [:])
}

struct RenderedGrid: Equatable {
    var grid: MainGrid
    var brightness: CGFloat = 0; // negative to reduce brightness, positive to increase it

    static let empty = RenderedGrid(grid: .empty)
}
