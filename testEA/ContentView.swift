//
//  ContentView.swift
//  testEA
//
//  Created by Gerald Kim on 18/1/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: FestivalViewModel = FestivalViewModel()
    
    var body: some View {
       VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.red))
            case .success(let labels):
                let labelNames = labels.map { $0.key }.sorted()
                if labelNames.count == 0 {
                    errorView(message: "Got empty response from server")
                } else {
                    ScrollView {
                        VStack {
                            ForEach(labelNames) { labelName in
                                VStack {
                                    Text(labelName)
                                        .font(.system(size: 24))
                                    ForEach(labels[labelName]!) { band in
                                        VStack {
                                            Text(band.name)
                                                .font(.system(size: 14))
                                            HStack {
                                                ForEach(band.festivals) { festival in
                                                    Group {
                                                        Text(festival)
                                                        Text("|")
                                                    }
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color.gray)
                                                }
                                            }.frame(maxWidth: .infinity)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                    }
                }
            case .failure(let error):
                errorView(message: error.description)
            }
        }
        .task { await viewModel.getLabels() }
    }
    
    @ViewBuilder
    func errorView(message: String) -> some View {
        VStack {
            Text("There was an error")
                .font(.title)
            Text(message)
            Button {
                Task {
                    await viewModel.getLabels()
                }
            } label: {
                Text("Try Again")
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
