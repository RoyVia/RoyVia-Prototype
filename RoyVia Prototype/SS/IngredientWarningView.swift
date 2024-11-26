//import SwiftUI
//import Vision
//
//struct IngredientWarningView: View {
//    @State private var selectedImage: UIImage?
//    @State private var harmfulIngredients: [String] = ["sugar", "high fructose corn syrup", "Red 60"]
//    @State private var detectedHarmfulIngredients: [String] = []
//    @State private var highlightedAreas: [CGRect] = []
//    @State private var showCamera = false
//    
//    var body: some View {
//        VStack {
//            if let selectedImage {
//                // Display the image with highlighted areas
//                Image(uiImage: selectedImage)
//                    .resizable()
//                    .scaledToFit()
//                    .overlay(HighlightOverlay(areas: highlightedAreas))
//                    .frame(maxHeight: 400)
//            } else {
//                Text("No image selected")
//                    .font(.headline)
//            }
//            
//            // Show detected harmful ingredients and warning
//            if !detectedHarmfulIngredients.isEmpty {
//                Text("⚠️ Warning: Detected harmful ingredients: \(detectedHarmfulIngredients.joined(separator: ", "))")
//                    .foregroundColor(.red)
//                    .padding()
//            }
//            
//            Button("Take Photo") {
//                showCamera = true
//            }
//            .padding()
//            .sheet(isPresented: $showCamera) {
//                CameraView(image: $selectedImage)
//            }
//        }
//        .onChange(of: selectedImage) { newImage in
//            if let newImage {
//                detectText(in: newImage)
//            }
//        }
//    }
//    
//    // Highlight Overlay View
//    func HighlightOverlay(areas: [CGRect]) -> some View {
//        GeometryReader { geometry in
//            ForEach(areas, id: \.self) { area in
//                Rectangle()
//                    .stroke(Color.red, lineWidth: 2)
//                    .frame(width: area.width * geometry.size.width,
//                           height: area.height * geometry.size.height)
//                    .position(x: area.midX * geometry.size.width,
//                              y: area.midY * geometry.size.height)
//            }
//        }
//    }
//    
//    // Text Detection using Vision Framework
//    func detectText(in image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        
//        let request = VNRecognizeTextRequest { (request, error) in
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//            
//            var detectedIngredients: [String] = []
//            var highlightRects: [CGRect] = []
//
//            // Get the image size
//            let imageWidth = CGFloat(cgImage.width)
//            let imageHeight = CGFloat(cgImage.height)
//
//            for observation in observations {
//                guard let topCandidate = observation.topCandidates(1).first else { continue }
//
//                let recognizedText = topCandidate.string.lowercased()
//
//                for harmfulIngredient in harmfulIngredients {
//                    if recognizedText.contains(harmfulIngredient.lowercased()) {
//                        detectedIngredients.append(harmfulIngredient)
//                        
//                        // Normalize the bounding box and convert to actual image coordinates
//                        let boundingBox = observation.boundingBox
//                        let rect = VNImageRectForNormalizedRect(boundingBox, Int(imageWidth), Int(imageHeight))
//                        highlightRects.append(rect) // Add the converted bounding box
//                    }
//                }
//            }
//            
//            DispatchQueue.main.async {
//                detectedHarmfulIngredients = detectedIngredients
//                highlightedAreas = highlightRects
//            }
//        }
//        
//        do {
//            try requestHandler.perform([request])
//        } catch {
//            print("Error performing text detection: \(error)")
//        }
//    }
//}
//
//// Camera View to take a new photo
