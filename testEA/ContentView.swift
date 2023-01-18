//
//  ContentView.swift
//  testEA
//
//  Created by Gerald Kim on 18/1/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: FestivalViewModel = FestivalViewModel()
    @State var alertType: APIError?
    
    var body: some View {
       VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .success(let labels):
                let labelNames = labels.map { $0.key }.sorted()
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
                                            Spacer().frame(width: 50)
                                            ForEach(band.festivals) { festival in
                                                Text(festival)
                                                    .font(.system(size: 10))
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
            case .failure(let error):
                EmptyView()
                    .onAppear {
                        alertType = error
                    }
            }
        }
//        Text("Hello World")
        .onAppear {
            Task {
                await viewModel.getLabels()
            }
        }
//        .alert(item: $alertType) { error in
//            Alert(title: Text("Network Error"),
//                  message: error.description,
//                  dismissButton: {
//                Button {
//                    Task {
//                        await viewModel.getLabels()
//                    }
//                } label: {
//                    Text("Try Again")
//                }
//
//            })
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
