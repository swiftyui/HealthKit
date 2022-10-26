import SwiftUI

struct CaloriesBurntView: View {
    @Binding var caloriesBurnt: Double
    var body: some View {
        GroupBox {
            HStack {
                LottieView(lottieFile: "caloriesBurnt", loopMode: .loop)
                    .frame(width: 64, height: 64)
                Text("Calories burnt \(self.caloriesBurnt, specifier: "%.2f") kCal").bold()
                Spacer()
            }
        }
        .padding(.horizontal)
        .shadow(radius: 5)
        .groupBoxStyle(ColoredGroupBox(color: .white))
    }
}

