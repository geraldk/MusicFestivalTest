import Foundation
// I can mock this out and test
public protocol NetworkServiceType {
    func getFestivals() async throws -> [MusicFestival]
}

public class NetworkService: NetworkServiceType {
    public init() { }
    
    public func getFestivals() async throws -> [MusicFestival] {
        let url = URL(string: "https://eacp.energyaustralia.com.au/codingtest/api/v1/festivals")
        return try await request(url: url, forType: [MusicFestival].self)
    }

    private func request<T: Decodable>(url: URL?, forType type: T.Type) async throws -> T {
        guard let url = url else { throw APIError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.other
        }
        if httpResponse.statusCode == 429 {
            throw APIError.throttled
        }
        guard let responseObject = try? JSONDecoder().decode(type, from: data) else {
            // This handles empty responses too, probably should handle more optionals in Model if I had more time
            throw APIError.invalidResponseJSON
        }
        
        return responseObject
    }
}

public enum APIError: Error {
    
    case throttled
    case noNetwork
    case invalidResponseJSON
    case invalidURL
    case other
    
    public var description: String {
        switch self {
        case .throttled:
            return "Too many requests, please try again later"
        case .noNetwork:
            return "No network connection detected, please check your settings"
        case .invalidResponseJSON:
            return "Got an empty response, please try again later"
        case .invalidURL:
            return "Invalid URL, please contact support"
        case .other:
            return "Error, please contact support"
        }
    }
}
