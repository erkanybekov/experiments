//
//  AudioRecorderViewModel.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/3/25.
//


import SwiftUI

@Observable
final class AudioRecorderViewModel {
    private(set) var isRecording = false
    private(set) var isPlaying = false
    private(set) var lastRecordingURL: URL?
    
    private let recorderService = AudioRecorderService()
    private let playerService = AudioPlayerService()
    
    func toggleRecording() async {
        if isRecording {
            await stopRecording()
        } else {
            await startRecording()
        }
    }
    
    func togglePlayback() async {
        guard let url = lastRecordingURL else {
            print("⚠️ No recording available to play.")
            return
        }
        
        if isPlaying {
            await stopPlayback()
        } else {
            await startPlayback(url: url)
        }
    }
    
    // MARK: - Recording
    private func startRecording() async {
        do {
            let allowed = await recorderService.requestPermission()
            guard allowed else {
                print("❌ Microphone access denied")
                return
            }
            
            try await recorderService.startRecording()
            isRecording = true
        } catch {
            print("⚠️ Failed to start recording: \(error)")
        }
    }
    
    private func stopRecording() async {
        await recorderService.stopRecording()
        lastRecordingURL = await recorderService.currentRecordingURL
        isRecording = false
        print("✅ Recording saved at \(lastRecordingURL?.absoluteString ?? "nil")")
    }
    
    // MARK: - Playback
    private func startPlayback(url: URL) async {
        do {
            try await playerService.play(url: url)
            isPlaying = true
        } catch {
            print("⚠️ Failed to start playback: \(error)")
        }
    }
    
    private func stopPlayback() async {
        await playerService.stop()
        isPlaying = false
    }
}
