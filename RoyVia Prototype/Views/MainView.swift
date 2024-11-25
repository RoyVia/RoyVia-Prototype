import SwiftUI

struct MainView: View {
    @StateObject var royviaData = RoyViaDataViewModel()
    @StateObject var presentationManager = GlobalPresentationManager() // Central manager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            if !royviaData.isLoading && royviaData.errorMessage == nil {
                TabView(selection: $selectedTab) {
                    UserSettingView(royviaData: royviaData)
                        .tabItem {
                            Label("Your Settings", systemImage: "person.crop.square")
                        }
                        .tag(0)
                    
                    ProductBarcodeScanView(royviaData: royviaData)
                        .environmentObject(presentationManager)
                        .tabItem {
                            Label("Barcode Scan", systemImage: "barcode.viewfinder")
                        }
                        .tag(1)
                    
                    ProductIngredientScanView()
                        .environmentObject(presentationManager)
                        .tabItem {
                            Label("Ingredient Scan", systemImage: "text.viewfinder")
                        }
                        .tag(2)
                }
                .onChange(of: selectedTab) { newTab in
                    presentationManager.activeSheet = nil
                    if newTab == 1 { // Barcode Scanner tab
                        NotificationCenter.default.post(name: .activateBarcodeScanner, object: nil)
                    } else if newTab == 2 { // Ingredient Scanner tab
                        NotificationCenter.default
                            .post(name: .resetBarcodeState, object: nil)
                    }
                }
            } else {
                getMainLoadingView()
            }
        }
        .onAppear {
            Task {
                await royviaData.fetchData()
            }
        }
        .tint(.white)
    }
    
    fileprivate func getMainLoadingView() -> some View {
        ZStack {
            BackgroundView()
            VStack {
                RoyViaView()
                if let errorMessage = royviaData.errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            Task {
                                await royviaData.fetchData()
                            }
                        }) {
                            OutlineTextView(text: "Let's ReTry!")
                        }
                        .padding(.top, 20)
                    }
                } else {
                    ProgressView("Loading RoyVia Data...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: royviaData.isLoading)
    }
}
