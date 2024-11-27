import SwiftUI

struct ProductBarcodeScanView: View {
    @ObservedObject var royviaData: RoyViaDataViewModel
    @StateObject private var viewModel = ProductBarcodeScanViewViewModel()
    @State private var modalState: ModalState = .idle
    
    enum ModalState: Equatable {
        case idle
        case showingScanner
        case showingIngredients
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0){
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                        .overlay(
                            Image(systemName: "barcode.viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.height * 0.25) // 50% of rectangle height
                                .foregroundColor(modalState == .showingScanner ? .green : .gray)
                        )
                    
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
                            
                            Text("We retrieve food/ingredient data from USDA database and analyze\ntheir hormonal and health impacts based on\nRoyVia's perspectives.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .font(.headline)
                                .padding()
                            
                            Button(action: {
                                modalState = .showingScanner
                            }) {
                                OutlineTextView(text: "Activate Scanner")
                            }
                            .padding()
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { modalState != .idle },
                set: { modalState = $0 ? modalState : .idle }
            )) {
                if modalState == .showingScanner {
                    BarcodeScannerView(
                        onCodeScanned: { code, _ in
                            viewModel.handleScannedBarcode(code)
                            modalState = .showingIngredients
                        },
                        isScanning: .constant(modalState == .showingScanner)
                    )
                } else if modalState == .showingIngredients {
                    BarcodeFoodDataView(
                        ingredients: viewModel.ingredientData?.ingredients ?? [],
                        errorMessage: viewModel.ingredientData?.errorMessage,
                        onDismiss: {
                            modalState = .idle
                            viewModel.resetState()
                        }
                    )
                }
            }
            .onChange(of: viewModel.ingredientData) { _, newData in
                if newData != nil && modalState != .showingIngredients {
                    modalState = .showingIngredients
                }
            }
        }
    }
}
