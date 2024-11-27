import SwiftUI

struct UserSettingView: View {
    @ObservedObject var rvDataViewModel: RVDataViewModel
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack {
                    Text("Your Areas of Concern")
                        .foregroundColor(.white)
                        .font(.title)
                    Text("Future version will allow you to setup\nyour own area(s) of concern")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding()
                    
                }
            }
        }
    }
}
