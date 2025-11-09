//
//  ContentView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/3/25.
//


import SwiftUI

struct AudioRecorderView: View {
    @State private var viewModel = AudioRecorderViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Text(viewModel.isRecording ? "Recording..." : "Tap to Record")
                .font(.title2)
                .foregroundColor(viewModel.isRecording ? .red : .primary)
                .padding(.top, 40)
            
            Button {
                Task { await viewModel.toggleRecording() }
            } label: {
                Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(viewModel.isRecording ? .red : .blue)
            }
            
            if let url = viewModel.lastRecordingURL {
                VStack(spacing: 10) {
                    Text("Last recording: \(url.lastPathComponent)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Button {
                        Task { await viewModel.togglePlayback() }
                    } label: {
                        Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(viewModel.isPlaying ? .orange : .green)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AudioRecorderView()
}
