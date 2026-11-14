import SwiftUI
import Playgrounds

let cellWidth: CGFloat = 80
let handleCellWidth: CGFloat = 60
let cellSpacing: CGFloat = 10
let gridHandleSpacing: CGFloat = 20

let mainGridWidth = cellWidth*2 + cellSpacing + gridHandleSpacing*2
let totalMaxWidth = mainGridWidth + 2 * (cellSpacing + cellWidth)

struct ContentView: View {
    @State var manager = GameManager()
    @State var tutorial = TutorialManager()

    var body: some View {
        ZStack(alignment: .center) {
            Color.clear

            // instructions
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 20)

                if tutorial.isActive {
                    tutorialInstructions
                } else {
                    normalInstructions
                }

                Spacer()
                    .frame(height: 20)
            }

            // actual game board
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

    @ViewBuilder
    var tutorialInstructions: some View {
        Text("Tutorial")
            .font(.largeTitle)

        Text(tutorial.instructions)
            .minimumScaleFactor(0.5)
            .font(.body)
            .italic()

        Spacer()
            .frame(minHeight: totalMaxWidth)

        HStack {
            if tutorial.phase != .ready {
                Button("Exit") {
                    tutorial.exit()
                }
                .buttonStyle(.bordered)
            }
            Spacer()
            Button("Next") {
                tutorial.nextPhase()
            }
            .buttonStyle(.borderedProminent)
            .disabled(tutorial.tracker?.isComplete() == false)
        }
        // NOTE: there are 5 phases, from 0 to 4, so we add 1
        ProgressView(value: CGFloat(tutorial.phase.rawValue + 1), total: 5)
    }

    @ViewBuilder
    var normalInstructions: some View {
        Text("\(manager.points) Points")
            .font(.largeTitle)
            .monospacedDigit()

        if manager.playState == .idle {
            Text("Move a hold to start")
                .font(.title)
                .italic()
        }

        Spacer()
            .frame(minHeight: totalMaxWidth)

        if manager.playState == .idle {
            Button("Tutorial") {
                tutorial.start(gameManager: manager)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ContentView()
}
