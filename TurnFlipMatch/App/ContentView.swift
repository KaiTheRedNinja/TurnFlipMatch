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

#Preview {
    ContentView()
}
