import SwiftUI
import Playgrounds

let cellWidth: CGFloat = 80
let handleCellWidth: CGFloat = 60
let cellSpacing: CGFloat = 10
let gridHandleSpacing: CGFloat = 20

struct ContentView: View {
    @State var hold1 = Hold.hold1
    @State var hold2 = Hold.hold2
    @State var mainGrid = MainGrid(colors: [
        .topLeft : .red,
        .topRight : .green,
        .bottomLeft : .yellow,
        .bottomRight : .blue
    ])

    var body: some View {
        HStack(spacing: gridHandleSpacing) {
            HoldView(hold: $hold1)
            MainGridView(mainGrid: mainGrid)
            HoldView(hold: $hold2)
        }
    }
}

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
        .onTapGesture {
            hold.position.flipped = !hold.position.flipped
        }
    }
}

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

#Preview {
    ContentView()
}
