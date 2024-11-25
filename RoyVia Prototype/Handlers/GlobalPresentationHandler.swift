import SwiftUI

class GlobalPresentationManager: ObservableObject {
    @Published var activeSheet: String? = nil // Tracks the active sheet
    @Published var isPresenting: Bool = false // Prevents overlapping presentations
    
    // Helper to safely update presentation state with a delay
    func present(sheet: String) {
        guard !isPresenting else { return }
        isPresenting = true
        activeSheet = sheet
        
        // Allow new presentations after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isPresenting = false
        }
    }
}
