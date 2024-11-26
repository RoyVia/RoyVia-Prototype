import SwiftUI

struct ProductBarcodeScanView: View {
    @ObservedObject var royviaData: RoyViaDataViewModel
    @StateObject private var viewModel = ProductBarcodeScanViewViewModel()
    @State private var isScanning = false // Manage scanning state explicitly
    @State private var activeModal: ActiveModal? = nil // Enum to manage modals
    
    enum ActiveModal: Identifiable {
        case scanner
        case ingredientCheck
        
        var id: String {
            switch self {
                case .scanner:
                    return "scanner"
                case .ingredientCheck:
                    return "ingredientCheck"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                        .overlay(
                            Text(isScanning ? "Scanner active..." : "Scanner inactive")
                                .foregroundColor(isScanning ? .green : .gray)
                        )
                    
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
                                
                                // Activate Scanner Button
                                Button(action: {
                                    isScanning = true // Activate scanner
                                    activeModal = .scanner // Open scanner modal
                                    print("Scanner activated")
                                }) {
                                    OutlineTextView(text: "Activate Scanner")
                                }
                                .disabled(isScanning) // Disable button if already scanning
                                .padding()
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .fullScreenCover(item: $activeModal, content: { modal in
                switch modal {
                    case .scanner:
                        BarcodeScannerView(
                            onCodeScanned: { code, type in
                                print("Barcode Scanned: \(code)")
                                viewModel.handleScannedBarcode(code)
                                isScanning = false // Deactivate scanner
                                activeModal = nil // Close scanner modal
                            },
                            isScanning: $isScanning // Scanner only runs when this is true
                        )
                        .onDisappear {
                            print("Scanner closed")
                            isScanning = false // Ensure scanner is deactivated
                        }
                    case .ingredientCheck:
                        BarcodeFoodDataView(
                            ingredients: viewModel.ingredientData?.ingredients ?? [],
                            errorMessage: viewModel.ingredientData?.errorMessage,
                            onDismiss: {
                                print("Resetting scanner state")
                                activeModal = nil
                                viewModel.resetState()
                            }
                        )
                }
            })
            .onChange(of: viewModel.ingredientData) { _, newData in
                if let newData = newData {
                    print("Navigating to ingredient check view")
                    activeModal = .ingredientCheck
                } else {
                    print("No data from barcode")
                }
            }
        }
        .onAppear {
            print("Product Barcode View appeared")
            viewModel.resetState()
            isScanning = false // Ensure scanner starts inactive
        }
        .onDisappear {
            print("Product Barcode View disappeared")
            isScanning = false // Ensure scanner stops when view disappears
        }
    }
}
