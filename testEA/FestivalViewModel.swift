import Foundation

enum ViewState<T> {
    case loading
    case success(result: T)
    case failure(APIError)
}

public class FestivalViewModel: ObservableObject {
    private let service: NetworkServiceType
    @Published var state: ViewState<MusicLabels> = .loading
    
    public init(service: NetworkServiceType = NetworkService()) {
        self.service = service
    }
    
    @MainActor
    public func getLabels() async {
        do {
            let festivals = try await service.getFestivals()
            state = .success(result: sortFestivalsToLabelsV2(festivals: festivals))
        } catch {
            if let apiError = error as? APIError {
                state = .failure(apiError)
            } else {
                state = .failure(APIError.other)
            }
        }
    }
    
    // This is faster but misses the same band in different labels
    func sortFestivalsToLabels(festivals: [MusicFestival]) -> MusicLabels {
        var recordLabels: MusicLabels = [:]
        
        for festival in festivals {
            guard let festivalName = festival.name else { continue }
            for band in festival.bands {
                guard let bandName = band.name,
                      let recordLabel = band.recordLabel else { continue }
                // If record label doesn't exist, create a new one
                if !recordLabels.keys.contains(recordLabel) {
                    recordLabels[recordLabel] = [OutputBand(name: bandName,
                                                                 festivals: [festivalName])]
                } else {
                    // If record label and band exist, add festival to band
                    let indexes = recordLabels[recordLabel]?
                        .enumerated()
                        .filter{$1.name == bandName}.map{$0.offset}
                    if let indexes = indexes, indexes.count > 0  {
                        for index in indexes {
                            recordLabels[recordLabel]?[index].festivals.append(festivalName)
                        }
                    } else { // If band doesn't exist, add new band
                        recordLabels[recordLabel]?.append(OutputBand(name: bandName,
                                                                          festivals: [festivalName]))
                    }
                }
            }
        }
        var sortedBands: MusicLabels = [:]
        for (label, bands) in recordLabels {
            sortedBands[label] = bands.sorted { $0.name < $1.name }
        }
        return sortedBands
    }
    
//  Twice as slow as V1 but more correct
    func sortFestivalsToLabelsV2(festivals: [MusicFestival]) -> MusicLabels {
        var labelBand: [String: Set<String>] = [:]
        var bandFestival: [String: Set<String>] = [:]
        for festival in festivals {
            for band in festival.bands {
                guard let labelName = band.recordLabel, let bandName = band.name, let festivalName = festival.name else { continue }
                if labelBand[labelName] == nil { labelBand[labelName] = [] }
                if bandFestival[bandName] == nil { bandFestival[bandName] = [] }
                labelBand[labelName]?.insert(bandName)
                bandFestival[bandName]?.insert(festivalName)
            }
        }

        var output: [String: [OutputBand]] = [:]
        for labelName in labelBand.keys {
            let bands = bandFestival.filter { labelBand[labelName]!.contains($0.key) }
            output[labelName] = bands.map { OutputBand(name: $0.key, festivals: $0.value.sorted()) }
        }
        return output
    }
}
