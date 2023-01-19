//
//  testEATests.swift
//  testEATests
//
//  Created by Gerald Kim on 18/1/2023.
//

import XCTest
@testable import testEA

final class testEATests: XCTestCase {
    let festivals = [
        MusicFestival(name: "Coachella", bands: [
            Band(name: "Black Keys", recordLabel: "Glassnote Records"),
            Band(name: "Tame Impala", recordLabel: "Dirty Hit"),
            Band(name: "Lana Del Rey", recordLabel: "Dirty Hit")]),
        MusicFestival(name: "Lollapalooza", bands: [
            Band(name: "The Strokes", recordLabel: "RCA Records"),
            Band(name: "Twenty One Pilots", recordLabel: "Fueled By Ramen"),
            Band(name: "The Chainsmokers", recordLabel: "Columbia Records"),
            Band(name: "The 1975", recordLabel: "Dirty Hit")]),
        MusicFestival(name: "Bonnaroo", bands: [
            Band(name: "Mumford & Sons", recordLabel: "Glassnote Records"),
            Band(name: "The 1975", recordLabel: "Dirty Hit"),
            Band(name: "Post Malone", recordLabel: "Republic Records")])
    ]
    
    func testExample() throws {
        
        let viewModel = FestivalViewModel()
        let labels = viewModel.sortFestivalsToLabels(festivals: festivals)
        XCTAssertEqual(labels.keys.sorted(), ["Columbia Records", "Dirty Hit", "Fueled By Ramen", "Glassnote Records", "RCA Records", "Republic Records"])
        
        // Dirty Hit should have 3 bands
        XCTAssertEqual(labels["Dirty Hit"]?.count, 3)
        
        // The 1975 should have 2 festivals
        XCTAssertEqual(labels["Dirty Hit"]?.last?.festivals.count, 2)
        
    }

    func testPerformanceExample() throws {
        let viewModel = FestivalViewModel()
        self.measure { //
            // Put the code you want to measure the time of here.
            _ = viewModel.sortFestivalsToLabelsV2(festivals: festivals)
        }
    }
}
