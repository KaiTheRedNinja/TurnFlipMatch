import SwiftUI
import Playgrounds

let cellWidth: CGFloat = 80
let handleCellWidth: CGFloat = 60
let cellSpacing: CGFloat = 10
let gridHandleSpacing: CGFloat = 20

struct ContentView: View {
    @State var manager = GameManager()

    var body: some View {
        ZStack {
            HoldView(hold: $manager.hold1)
            HoldView(hold: $manager.hold2)
            MainGridView(mainGrid: manager.mainGrid)
                .onTapGesture {
                    manager.checkForVictory()
                }
        }
        .onAppear {
            manager.randomiseMainGrid()
        }
    }
}

#Preview {
    ContentView()
}
