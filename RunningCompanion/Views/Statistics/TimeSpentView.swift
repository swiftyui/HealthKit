import SwiftUI

struct TimeSpentView: View {
    @Binding var timeSpent: Double
    var body: some View {
        GroupBox {
            HStack {
                LottieView(lottieFile: "timer", loopMode: .loop)
                    .frame(width: 64, height: 64)
                Text("Time spent \(self.timeSpent, specifier: "%.0f") minutes").bold()
                Spacer()
            }
        }
        .padding(.horizontal)
        .shadow(radius: 5)
        .groupBoxStyle(ColoredGroupBox(color: .white))
    }
}
