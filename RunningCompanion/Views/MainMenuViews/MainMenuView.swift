import SwiftUI
import HealthKit

struct MainMenuView: View {
    @EnvironmentObject var healthStore: HealthStore
    @State private var distance: Double = 0.00
    @State private var caloriesBurnt: Double = 0.00
    @State private var timeSpent: Double = 0.00
    @State private var progress: CGFloat = 1.0
    @State private var energyProgress: Double = 0.00
    @State private var standProgress: Double = 0.00
    @State private var exerciseProgress: Double = 0.00
    
    var body: some View {
        
        NavigationView {
            VStack{
                
                Text("Weekly Summary")
                CaloriesBurntView(caloriesBurnt: self.$caloriesBurnt)
                DistanceTravelledView(distanceTravelled: self.$distance)
                TimeSpentView(timeSpent: self.$timeSpent)
                
                Spacer()
                
                Text("Daily Activity Progress")
                    

                ZStack {
                    /// Calories
                    Group {
                        PercentageRing(
                            ringWidth: 20, percent: energyProgress,
                            backgroundColor: Color.darkRed.opacity(0.2),
                            foregroundColors: [.darkRed, .lightRed]
                        )
                        .frame(width: 300, height: 300)
                    }
                    
                    /// Exercise
                    Group {
                        PercentageRing(
                            ringWidth: 20, percent: exerciseProgress,
                            backgroundColor: Color.darkGreen.opacity(0.2),
                            foregroundColors: [.darkGreen, .lightGreen]
                        )
                        .frame(width: 260, height: 260)
                    }
                    
                    /// Stand
                    Group {
                        PercentageRing(
                            ringWidth: 20, percent: standProgress,
                            backgroundColor: Color.darkBlue.opacity(0.2),
                            foregroundColors: [.darkBlue, .lightBlue]
                        )
                        .frame(width: 220, height: 220)
                    }
                }
            }
            .background(Color(hue: 0.001, saturation: 0.005, brightness: 0.944))
        }
        
        .onAppear {
            
            /// Get calories burnt
            healthStore.getTotalCaloriesBurnt { calories in
                self.caloriesBurnt = calories
            }
            
            /// Get time spent
            healthStore.getTimeSpent { time in
                self.timeSpent = time
            }
            
            /// Get distance travelled
            healthStore.getTotalDistanceRun { distance in
                self.distance = distance
            }
            
            /// Get the Goals
            healthStore.getGoals { (energyProgress, standProgress, exerciseProgress) in
                self.energyProgress = energyProgress
                self.standProgress = standProgress
                self.exerciseProgress = exerciseProgress
                
            }
        }
    }
}
