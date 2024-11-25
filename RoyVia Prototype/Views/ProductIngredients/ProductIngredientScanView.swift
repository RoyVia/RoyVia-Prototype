import SwiftUI
struct ProductIngredientScanView: View {
    @EnvironmentObject var presentationManager: GlobalPresentationManager
    @StateObject private var viewModel = ProductIngredientScanViewModel()
    @State private var capturedPhoto: UIImage? = nil
    
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
                        presentationManager.present(sheet: "Scanner")
                        capturedPhoto = nil
                        viewModel.capturedImage = nil
                        viewModel.ingredientsSheetData = nil
                    }) {
                        OutlineTextView(text: "Take a Photo")
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetIngredientState)) { _ in
            capturedPhoto = nil
            viewModel.capturedImage = nil
            viewModel.ingredientsSheetData = nil
        }
        .fullScreenCover(isPresented: Binding(
            get: { presentationManager.activeSheet == "Scanner" },
            set: { if !$0 { presentationManager.activeSheet = nil } }
        )) {
            IngredientScannerView(viewModel: viewModel)
                .onAppear {
                    capturedPhoto = nil
                    viewModel.capturedImage = nil
                }
                .onDisappear {
                    capturedPhoto = nil
                    viewModel.capturedImage = nil
                }
        }
        .onChange(of: viewModel.capturedImage) { photo in
            if let photo = photo {
                capturedPhoto = photo
                viewModel.processImageForIngredients()
                
                // Delay the sheet presentation to prevent overlapping
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    presentationManager.present(sheet: "IngredientSheet")
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { presentationManager.activeSheet == "IngredientSheet" },
            set: { if !$0 { presentationManager.activeSheet = nil } }
        )) {
            if let sheetData = viewModel.ingredientsSheetData {
                IngredientSheetView(
                    ingredients: sheetData.ingredients,
                    errorMessage: sheetData.errorMessage
                ) {
                    viewModel.dismissIngredientsSheet()
                    presentationManager.activeSheet = nil
                }
            }
        }
    }
}
