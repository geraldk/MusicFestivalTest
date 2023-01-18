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
    
    public func getLabels() async {
        do {
            let festivals = try await service.getFestivals()
            state = .success(result: sortFestivalsToLabels(festivals: festivals))
        } catch {
            if let apiError = error as? APIError {
                state = .failure(apiError)
            } else {
                state = .failure(APIError.other)
            }
        }
    }
    
    sdafsdaf
    // Can I make this more efficient by throwing things into Sets and merging?
    private func sortFestivalsToLabels(festivals: [MusicFestival]) -> MusicLabels {
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
                    if let index = recordLabels[recordLabel]?.firstIndex(where: { $0.name == bandName }) {
                        recordLabels[recordLabel]?[index].festivals.append(festivalName)
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
}
