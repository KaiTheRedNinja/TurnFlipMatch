import SwiftUI
import Playgrounds

let cellWidth: CGFloat = 80
let handleCellWidth: CGFloat = 60
let cellSpacing: CGFloat = 10
let gridHandleSpacing: CGFloat = 20

let mainGridWidth = cellWidth*2 + cellSpacing + gridHandleSpacing*2

struct ContentView: View {
    @State var manager = GameManager()

    var body: some View {
        VStack {
            Text("\(manager.points) Points")
                .font(.largeTitle)
                .monospacedDigit()

            Spacer()

            ZStack {
                HoldView(manager: manager, holdId: .one)
                HoldView(manager: manager, holdId: .two)
                MainGridView(grid: manager.mainGrid)
                    .onTapGesture {
                        manager.checkForVictory()
                    }
            }
            .shadow(radius: 10)
            .frame(width: mainGridWidth, height: mainGridWidth)
            .coordinateSpace(.named("mainGrid"))
            .onAppear {
                manager.stateChangePlaying()
            }

            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
