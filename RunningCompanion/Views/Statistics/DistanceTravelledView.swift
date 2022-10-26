import SwiftUI

struct DistanceTravelledView: View {
    @Binding var distanceTravelled: Double
    var body: some View {
        GroupBox {
            HStack {
                LottieView(lottieFile: "running", loopMode: .loop)
                    .frame(width: 64, height: 64)
                Text("Distance travelled \(self.distanceTravelled, specifier: "%.2f") km").bold()
                Spacer()
            }
        }
        .padding(.horizontal)
        .shadow(radius: 5)
        .groupBoxStyle(ColoredGroupBox(color: .white))
    }
}
