//
//  AudioPlayerService.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/3/25.
//


import Foundation
import AVFoundation

actor AudioPlayerService: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    
    func play(url: URL) async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
        
        player = try AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.play()
        print("▶️ Playing audio from \(url.lastPathComponent)")
    }
    
    func stop() {
        player?.stop()
        player = nil
        print("⏹️ Playback stopped")
    }
    
    func isPlaying() -> Bool {
        player?.isPlaying ?? false
    }
}
