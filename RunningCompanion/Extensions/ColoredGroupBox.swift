import SwiftUI

struct ColoredGroupBox: GroupBoxStyle {
    
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            HStack {
                configuration.label
                    .font(.headline)
                Spacer()
            }
            
            configuration.content
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(color)) // Set your color here!!
    }
}
