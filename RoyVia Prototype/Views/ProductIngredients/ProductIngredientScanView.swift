import SwiftUI

struct ProductIngredientScanView: View {
    @ObservedObject var royviaData: RoyViaDataViewModel
    @StateObject private var viewModel = ProductIngredientScanViewModel()
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
                
                VStack(spacing: 0) {
                    if let capturedImage = viewModel.capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: UIScreen.main.bounds.height * 0.5)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: UIScreen.main.bounds.height * 0.5)
                            .overlay(
                                Image(systemName: "text.viewfinder")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.height * 0.25) // 50% of rectangle height
                                    .foregroundColor(modalState == .showingScanner ? .green : .gray)
                            )
                    }
                    
                    VStack {
                        Text("Take a photo of 'Ingredients' label")
                            .foregroundColor(.gray)
                            .font(.headline)
                            .padding()
                        
                        Text("We identify ingredients from the label and analyze\ntheir hormonal and health impacts based on\nRoyVia's perspectives.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .font(.headline)
                            .padding()
                        
                        Button(action: {
                            modalState = .showingScanner
                        }) {
                            OutlineTextView(text: "Take a Photo")
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { modalState != .idle },
                set: { modalState = $0 ? modalState : .idle }
            )) {
                if modalState == .showingScanner {
                    IngredientScannerView(viewModel: viewModel)
                        .onDisappear {
                            if let capturedImage = viewModel.capturedImage {
                                viewModel.processImageForIngredients()
                            }
                        }
                } else if modalState == .showingIngredients {
                    IngredientFoodDataView(
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
        .onAppear {
            print("Product Ingredient View appeared")
        }
        .onDisappear {
            print("Product Ingredient View disappeared")
        }
    }
}
