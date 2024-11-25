import Foundation

enum HTTPError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case httpError(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
            case .invalidURL:
                return "The provided URL is invalid."
            case .noData:
                return "The server responded with no data."
            case .decodingError:
                return "Failed to decode the response data."
            case .networkError(let error):
                return "Network error occurred: \(error.localizedDescription)"
            case .httpError(let statusCode):
                return "HTTP error occurred with status code: \(statusCode)."
            case .unknown:
                return "An unknown error occurred."
        }
    }
}

class HTTPHandler {
    static func fetchData<T: Decodable>(from urlString: String, as type: T.Type) async throws -> T {
        // Check for a valid URL
        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }
        
        do {
            // Perform the network request
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check for HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw HTTPError.httpError(httpResponse.statusCode)
                }
            }
            
            // Ensure data is not empty
            guard !data.isEmpty else {
                throw HTTPError.noData
            }
            
            // Decode the JSON into the desired type
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } catch {
                throw HTTPError.decodingError
            }
            
        } catch {
            if let urlError = error as? URLError {
                throw HTTPError.networkError(urlError)
            }
            throw HTTPError.unknown
        }
    }
}
