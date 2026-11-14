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
        ZStack(alignment: .center) {
            Color.clear

            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 20)

                Text("\(manager.points) Points")
                    .font(.largeTitle)
                    .monospacedDigit()

                if manager.playState == .idle {
                    Text("Move a hold to start")
                        .font(.title)
                        .italic()
                }

                Spacer()
            }

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
        }
    }
}

#Preview {
    ContentView()
}
