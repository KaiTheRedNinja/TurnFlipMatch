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
                HoldView(hold: $manager.hold1)
                HoldView(hold: $manager.hold2)
                MainGridView(grid: manager.mainGrid)
                    .onTapGesture {
                        manager.checkForVictory()
                    }
            }
            .frame(width: mainGridWidth, height: mainGridWidth)
            .border(Color.cyan)
            .coordinateSpace(.named("mainGrid"))
            .onAppear {
                manager.stateChangePlaying()
            }
            .onChange(of: manager.hold1) { _, _ in
                holdChanged()
            }
            .onChange(of: manager.hold2) { _, _ in
                holdChanged()
            }

            Spacer()
        }
    }

    func holdChanged() {
        manager.playHaptic()
        manager.checkForVictory()
    }
}

#Preview {
    ContentView()
}
