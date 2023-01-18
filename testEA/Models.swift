import Foundation

public struct MusicFestival: Codable {
    let name: String?
    let bands: [Band]
}

public struct Band: Codable {
    let name: String?
    let recordLabel: String?
}

public struct OutputBand: Hashable, Identifiable {
    let name: String
    var festivals: [String]
    
    public typealias ID = Int
    public var id: Int {
        return name.hash
    }
}

typealias MusicLabels = Dictionary<String, [OutputBand]>

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
