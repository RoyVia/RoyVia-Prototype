import SwiftUI

struct ProductBarcodeScanView: View {
    @ObservedObject var royviaData: RoyViaDataViewModel
    @EnvironmentObject var presentationManager: GlobalPresentationManager
    @StateObject var viewModel = ProductBarcodeScanViewViewModel()
    @State private var isScanning = true
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 0) {
                BarcodeScannerView(
                    onCodeScanned: { code, type in
                        viewModel.handleScannedBarcode(code)
                        isScanning = false
                        presentationManager.present(sheet: "BarcodeSheet")
                    },
                    isScanning: $isScanning
                )
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .clipped()
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Fetching Ingredients...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .padding()
                    } else {
                        VStack {
                            Text("Scan Food Product Barcode")
                                .foregroundColor(.gray)
                                .font(.headline)
                                .padding()
                            Text("We retrieve food/ingredient data from\nUSDA central food database.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .font(.headline)
                                .padding()
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.resetState()
            isScanning = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetBarcodeState)) { _ in
            isScanning = true
            viewModel.resetState()
        }
        .onChange(of: presentationManager.activeSheet) { newSheet in
            if newSheet == nil {
                isScanning = true // Resume scanning when the sheet is dismissed
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { presentationManager.activeSheet == "BarcodeSheet" },
            set: { if !$0 { presentationManager.activeSheet = nil } }
        )) {
            IngredientSheetView(
                ingredients: viewModel.ingredients,
                errorMessage: viewModel.errorMessage,
                onDismiss: {
                    presentationManager.activeSheet = nil
                }
            )
        }
    }
}
