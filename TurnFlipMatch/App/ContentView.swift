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
                    .shadow(radius: 10)
                HoldView(manager: manager, holdId: .two)
                    .shadow(radius: 10)
                MainGridView(grid: manager.mainGrid)
                    .compositingGroup()
                    .shadow(
                        color: manager.mainGrid.backight?.color ?? Color(.sRGBLinear, white: 0, opacity: 0.33),
                        radius: manager.mainGrid.backight == nil ? 10 : 50
                    )
            }
            .frame(width: mainGridWidth, height: mainGridWidth)
            .coordinateSpace(.named("mainGrid"))
        }
    }

    @ViewBuilder
    var tutorialInstructions: some View {
        Text("Tutorial")
            .font(.largeTitle)

        VStack(spacing: 20) {
            Text(tutorial.instructions)
                .minimumScaleFactor(0.5)
                .font(.body)
                .italic()
                .multilineTextAlignment(.center)

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
                .tint(.green)
                .saturation(2.0)
                .disabled(tutorial.tracker?.isComplete() == false)
            }
            // NOTE: there are 5 phases, from 0 to 4, so we add 1
            ProgressView(value: CGFloat(tutorial.phase.rawValue + 1), total: 5)
        }
        .padding(.horizontal, 30)
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
