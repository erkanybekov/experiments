//
//  ImageFetchView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/28/25.
//


import SwiftUI

struct ImageFetchView: View {
    @StateObject private var vm = ImageFetchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // image
                processImage
                
                if let date = vm.lastFetchDate {
                    Text("Last fetch: \(date.formatted(date: .omitted, time: .standard))")
                }
                
                Button(vm.isScheduled ? "Scheduled" : "Schedule Fetch") {
                    vm.scheduleImageFetch()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .disabled(vm.isScheduled)
                
                Spacer()
            }
            .task {
                await vm.fetchImage()
            }
            .padding()
            .navigationTitle("BG Task Image Fetch")
        }
    }
    
    @ViewBuilder
    private var processImage: some View {
        if let imageURL = vm.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 200)
        } else {
            Text("No image fetched yet")
                .foregroundStyle(.secondary)
        }
    }
}


#Preview {
    ImageFetchView()
}
