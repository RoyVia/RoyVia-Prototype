import SwiftUI

class RoyViaDataViewModel: ObservableObject {
    @Published var checkList: [Ingredient] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    private let apiServiceURL: String = "https://script.google.com/macros/s/AKfycbz-nOKpkRDm5gTuI25bgOfJJwjlSKg0g6prhcaNvCwyTKEAOncxpOxPxcjA2v662rQlCQ/exec"
    
    func fetchData() async {
        // Use a @MainActor context to ensure all published property updates are on the main thread
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedData: [Ingredient] = try await HTTPHandler.fetchData(from: apiServiceURL, as: [Ingredient].self)
            await MainActor.run {
                checkList = fetchedData
                isLoading = false
            }
        } catch let error as HTTPError {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Unexpected error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}
