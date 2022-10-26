import SwiftUI


@main
struct RunningCompanionApp: App {
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeRemaining: Int = 3
    @State var isLoading: Bool = true
    @State var isAuthorized = false
    @StateObject var healthStore: HealthStore = HealthStore()
    
    var body: some Scene {
        WindowGroup {
            VStack {
                if self.isLoading {
                    SplashScreenView().onReceive(timer) {_ in
                        if ( timeRemaining > 0 )
                        {
                            timeRemaining -= 1
                        }
//                        if (timeRemaining <= 0 && isAuthorized == true)
                        if (timeRemaining <= 0)
                        {
                            timer.upstream.connect().cancel()
                            isLoading = false
                        }
                    }
                }
                else {
                    MainMenuView().environmentObject(healthStore)
                }
            }
            .onAppear {
                /// Request Authorization to use the user's health data
                healthStore.requestAuthorization { success in 
                    if success {
                        isAuthorized = true
                    }
                }
            }
        }
    }
}
