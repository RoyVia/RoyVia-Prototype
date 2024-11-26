import SwiftUI

struct ProductIngredientScanView: View {
    @ObservedObject var royviaData: RoyViaDataViewModel
    @StateObject private var viewModel = ProductIngredientScanViewModel()
    @State private var capturedPhoto: UIImage? = nil
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
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                if let photo = capturedPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                        .overlay(Text("Photo will appear here").foregroundColor(.gray))
                }
                
                VStack {
                    Text("Take a photo of 'Ingredients' label")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                    Text("Please ensure to capture from 'Ingredients:' to the period ('.').")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                    Button(action: {
                        viewModel.capturedImage = nil
                        viewModel.ingredientData = nil
                        activeModal = .scanner
                    }) {
                        OutlineTextView(text: "Take a Photo")
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
            }
        }
        .onAppear {
            print("Product Ingredient View appeared")
        }
        .onDisappear {
            print("Product Ingredient View disappeared")
        }
        .fullScreenCover(item: $activeModal, content: { modal in
            switch modal {
                case .scanner:
                    IngredientScannerView(viewModel: viewModel)
                        .onAppear {
                            capturedPhoto = nil
                            print("Previous photo is cleared on scanner view appear")
                        }
                        .onDisappear {
                            print("Ingredient scanner view disappeared")
                        }
                case .ingredientCheck:
                    IngredientFoodDataView(
                        ingredients: viewModel.ingredientData?.ingredients ?? [],
                        errorMessage: viewModel.ingredientData?.errorMessage,
                        onDismiss: {
                            print("Resetting ingredient camera")
                            activeModal = nil
                        }
                    )
            }
        })
        .onChange(of: viewModel.capturedImage) { _, new in
            if let photo = new {
                print("Ingredient photo changed")
                capturedPhoto = photo
                print("Parsing ingredients")
                viewModel.processImageForIngredients()
            } else {
                print("Invalid ingredient photo")
            }
        }
        .onChange(of: viewModel.ingredientData) { _, newData in
            if newData != nil {
                print("Navigating to ingredient check view")
                activeModal = .ingredientCheck
            } else {
                print("No data from ingredient")
            }
        }
    }
}
