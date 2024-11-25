import SwiftUI

struct UserSettingView: View {
    @ObservedObject var royviaData: RoyViaDataViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack {
                    Text("Your Areas of Concern")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
        }
    }
}
