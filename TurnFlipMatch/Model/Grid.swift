//
//  Grid.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 11/11/26.
//

import Foundation

struct QuadrantGrid<Cell: Equatable>: Equatable {
    var cells: [Quadrant: Cell]

    init(cells: [Quadrant: Cell]) {
        self.cells = cells
    }

    init(all: Cell?) {
        self.cells = [
            .topLeft: all,
            .topRight: all,
            .bottomLeft: all,
            .bottomRight: all
        ].compactMapValues { $0 }
    }
}

typealias ColorGrid = QuadrantGrid<CellColor>

extension ColorGrid {
    static let empty = ColorGrid(cells: [:])
}

typealias BrightnessGrid = QuadrantGrid<CellBrightness>

extension BrightnessGrid {
    static let empty = BrightnessGrid(cells: [:])
}

struct RenderedGrid: Equatable {
    var grid: ColorGrid
    var brightness: CGFloat = 0; // negative to reduce brightness, positive to increase it

    static let empty = RenderedGrid(grid: .empty)
}
