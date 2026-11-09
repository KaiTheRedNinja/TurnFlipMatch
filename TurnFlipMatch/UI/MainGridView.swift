//
//  MainGridView.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI

struct MainGridView: View {
    var mainGrid: MainGrid

    var body: some View {
        VStack(spacing: cellSpacing) {
            HStack(spacing: cellSpacing) {
                (mainGrid.colors[.topLeft]?.color ?? Color.clear)
                    .frame(width: cellWidth, height: cellWidth)
                (mainGrid.colors[.topRight]?.color ?? Color.clear)
                    .frame(width: cellWidth, height: cellWidth)
            }
            HStack(spacing: cellSpacing) {
                (mainGrid.colors[.bottomLeft]?.color ?? Color.clear)
                    .frame(width: cellWidth, height: cellWidth)
                (mainGrid.colors[.bottomRight]?.color ?? Color.clear)
                    .frame(width: cellWidth, height: cellWidth)
            }
        }
    }
}
