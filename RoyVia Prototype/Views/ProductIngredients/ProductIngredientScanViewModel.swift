import Foundation
import SwiftUI
import Vision

class ProductIngredientScanViewModel: ObservableObject {
    @Published var capturedImage: UIImage? = nil
    @Published var ingredientData: IngredientData? = nil
    
    // Resets the state of the view model
    func resetState() {
        capturedImage = nil
        ingredientData = nil
    }
    
    func processImageForIngredients() {
        guard let image = capturedImage, let cgImage = image.cgImage else {
            presentError("Invalid image")
            return
        }
        print("Received Ingredient Image")
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let textRecognitionRequest = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                self?.presentError("Text recognition failed: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                self?.presentError("No text found in the image")
                return
            }
            
            self?.parseIngredients(from: observations)
        }
        
        textRecognitionRequest.recognitionLevel = .accurate
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([textRecognitionRequest])
            } catch {
                self.presentError(
                    "Failed to process image: \(error.localizedDescription)"
                )
            }
        }
    }
    
    private func parseIngredients(from observations: [VNRecognizedTextObservation]) {
        let recognizedText = observations
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: " ")
            .lowercased()
        
        guard let range = recognizedText.range(of: "ingredients:") else {
            presentError("Ingredients section not found")
            print("Ingredients section not found")
            return
        }
        
        let ingredientsText = recognizedText[range.upperBound...]
        if let endIndex = ingredientsText.firstIndex(of: ".") {
            let rawIngredients = ingredientsText[..<endIndex]
            let parsedIngredients = splitIngredients(String(rawIngredients))
            print("Ingredient Parsing completed")
            DispatchQueue.main.async {
                self.ingredientData = IngredientData(ingredients: parsedIngredients, errorMessage: nil)
                print("Ingredients List Dispatched")
            }
        } else {
            presentError("Ingredients section not properly formatted")
        }
    }
    
    private func splitIngredients(_ text: String) -> [String] {
        var result = [String]()
        var current = ""
        var insideParentheses = 0
        
        for char in text {
            if char == "(" {
                insideParentheses += 1
            } else if char == ")" {
                insideParentheses = max(0, insideParentheses - 1)
            }
            
            if char == "," && insideParentheses == 0 {
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                result.append(trimmed.uppercased().trimmingCharacters(in: ["."]))
                current = ""
            } else {
                current.append(char)
            }
        }
        
        if !current.isEmpty {
            let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
            result.append(trimmed.uppercased().trimmingCharacters(in: ["."]))
        }
        
        return result
    }
    
    private func presentError(_ message: String) {
        DispatchQueue.main.async {
            self.ingredientData = IngredientData(ingredients: [], errorMessage: message)
        }
    }
}
