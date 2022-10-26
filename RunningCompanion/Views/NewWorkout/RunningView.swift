import SwiftUI

struct RunningView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var healthStore: HealthStore
    @State var newRun: Run = Run(startDate: Date(), endDate: Date())
    
    var body: some View {
        VStack {
            LottieView(lottieFile: "runningSushi", loopMode: .loop)
                .frame(height: 200)
            Spacer()
            
            Text("End Run")
                .frame(width: 200, height: 15)
                .padding()
                .background(Color(hue: 1.0, saturation: 0.989, brightness: 0.694))
                .foregroundColor(.white)
                .clipShape(Capsule())
                .onTapGesture {
                    
                    DispatchQueue.main.async {
                        self.newRun.endDate = Date()
                        healthStore.startNewRun(newRun: newRun) { _ in
                            
                        }
                    }
                }
        }
        .navigationBarHidden(true)
    }
}
