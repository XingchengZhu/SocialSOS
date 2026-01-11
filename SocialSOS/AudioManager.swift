//
//  AudioManager.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI      // 添加这个引用
import AVFoundation
import UIKit

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    override private init() {
        super.init()
    }
    
    // 配置音频会话
    private func setupAudioSession(isCall: Bool) {
        do {
            let session = AVAudioSession.sharedInstance()
            if isCall {
                // 通话模式：使用听筒 (Receiver)
                // .playAndRecord 允许录音和播放，通常用于通话
                // .allowBluetooth 允许蓝牙耳机
                try session.setCategory(.playAndRecord, options: [.allowBluetooth])
                try session.overrideOutputAudioPort(.none) // .none 默认指听筒
            } else {
                // 铃声模式：使用扬声器 (Speaker)
                // .playback 支持后台播放
                // .duckOthers 压低其他声音
                try session.setCategory(.playback, mode: .default, options: [.duckOthers])
                try session.overrideOutputAudioPort(.speaker)
            }
            try session.setActive(true)
        } catch {
            print("音频会话配置失败: \(error)")
        }
    }
    
    // 播放铃声 (扬声器)
    func playRingtone() {
        setupAudioSession(isCall: false) // 切换到扬声器模式
        
        guard let url = Bundle.main.url(forResource: "ringtone", withExtension: "mp3") else {
            print("❌ 错误：找不到 ringtone.mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 无限循环
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
            startVibration()
        } catch {
            print("铃声播放失败: \(error)")
        }
    }
    
    // 播放通话录音 (听筒)
    func playVoiceScript() {
        stopAudio() // 先停止铃声
        setupAudioSession(isCall: true) // 切换到听筒模式
        
        guard let url = Bundle.main.url(forResource: "voice", withExtension: "mp3") else {
            print("❌ 错误：找不到 voice.mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = 0 // 只播放一次
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            print("语音播放失败: \(error)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        stopVibration()
        // 尝试停用会话
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    // 模拟震动
    private func startVibration() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    private func stopVibration() {
        timer?.invalidate()
        timer = nil
    }
}
