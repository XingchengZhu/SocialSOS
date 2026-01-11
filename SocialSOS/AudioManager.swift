//
//  AudioManager.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import AVFoundation
import UIKit

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var feedbackGenerator: UINotificationFeedbackGenerator?
    private var timer: Timer?
    
    override private init() {
        super.init()
        setupAudioSession()
    }
    
    // 配置音频会话：确保静音键开启时也能通过扬声器播放铃声
    private func setupAudioSession() {
        do {
            // .playback 模式支持后台播放和静音下播放
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Setup Error: \(error)")
        }
    }
    
    // 播放铃声
    func playRingtone() {
        guard let url = Bundle.main.url(forResource: "ringtone", withExtension: "mp3") else {
            print("找不到 ringtone.mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 无限循环
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
            startVibration() // 开始震动
        } catch {
            print("播放失败: \(error)")
        }
    }
    
    // 播放通话录音 (接通后通过听筒播放 - 模拟真实通话)
    func playVoiceScript() {
        stopAudio() // 先停掉铃声
        
        guard let url = Bundle.main.url(forResource: "voice", withExtension: "mp3") else { return }
        
        do {
            // 尝试切换到听筒模式 (PlayAndRecord) - *注意：模拟器上无法测试听筒，真机有效*
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none) // .none 通常指听筒
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.volume = 0.8
            audioPlayer?.play()
        } catch {
            print("语音播放失败: \(error)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        stopVibration()
    }
    
    // 模拟来电震动
    private func startVibration() {
        timer?.invalidate()
        // 模拟断续震动
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error) // Error类型的震动比较长且明显
        }
    }
    
    private func stopVibration() {
        timer?.invalidate()
        timer = nil
    }
}
