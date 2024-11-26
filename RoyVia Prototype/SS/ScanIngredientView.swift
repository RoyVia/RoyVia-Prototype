////
////  ScanIngredientView.swift
////  RoyVia Prototype
////
////  Created by Heesun Kim on 11/16/24.
////
//
//import SwiftUI
//import SwiftData
//import Vision
//import AVFoundation
//
//struct ScanIngredientView:View{
//    //@Query private var ingredients: [Ingredient]
//    private var harmfulIngredients: [Ingredient] = [Ingredient(name:"Sugar"), Ingredient(name:"Syrup")]
//    
//    @State private var scanedImage: UIImage?
//    @State private var showCamera = false
//    @State private var detectedHarmfulIngredients: [String] = []
//
//    var body: some View{
//        NavigationView{
//            ZStack{
//                BackgroundView()
//                VStack{
//                    if let scanedImage {
//                        Image(uiImage: scanedImage)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxHeight: 400)
//                        Button("ReTake Photo") {
//                            showCamera = true
//                        }
//                    }
//                    else{
//                        Button("Take Photo") {
//                            showCamera = true
//                        }
//                    }
//                    Spacer()
//                }
//                .padding()
//                .sheet(isPresented: $showCamera) {
//                    CameraView(image: $scanedImage)
//                }
//            }
//        }
//        .onChange(of: scanedImage ?? UIImage()) { prevImage, newImage in
//            detectText(in: newImage)
//        }
//    }
//    
//    func detectText(in image:UIImage){
//        guard let cgImage = image.cgImage else { return }
//        
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        
//        let request = VNRecognizeTextRequest { (request, error) in
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//            
//            var detectedIngredients: [String] = []
//            
//            for observation in observations {
//                guard let topCandidate = observation.topCandidates(1).first else { continue }
//                
//                let recognizedText = topCandidate.string.lowercased()
//                
//                for harmfulIngredient in harmfulIngredients {
//                    if recognizedText
//                        .contains(harmfulIngredient.name.lowercased()) {
//                        detectedIngredients.append(harmfulIngredient.name)
//                    }
//                }
//            }
//            
//            DispatchQueue.main.async {
//                detectedHarmfulIngredients = detectedIngredients
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
