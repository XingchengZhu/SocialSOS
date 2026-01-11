//
//  AudioManager.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI
import Combine
import AVFoundation
import UIKit

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    private func setupAudioSession(isCall: Bool) {
        do {
            let session = AVAudioSession.sharedInstance()
            if isCall {
                try session.setCategory(.playAndRecord, options: [])
                try session.overrideOutputAudioPort(.none)
            } else {
                try session.setCategory(.playback, mode: .default, options: [.duckOthers])
                try session.overrideOutputAudioPort(.speaker)
            }
            try session.setActive(true)
        } catch { print("音频配置失败: \(error)") }
    }
    
    func playRingtone() {
        setupAudioSession(isCall: false)
        guard let url = Bundle.main.url(forResource: "ringtone", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
            startVibration()
        } catch { print(error) }
    }
    
    func playVoiceScript() {
        stopAudio()
        setupAudioSession(isCall: true)
        guard let url = Bundle.main.url(forResource: "voice", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch { print(error) }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        stopVibration()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    private func startVibration() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    private func stopVibration() { timer?.invalidate(); timer = nil }
}
