//
//  FakeCallView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

struct CallActionItem: Hashable {
    let icon: String
    let label: String
}

struct FakeCallView: View {
    @EnvironmentObject var config: AppConfig
    @State private var callDuration: TimeInterval = 0
    @State private var timer: Timer?
    
    let callActions = [
        CallActionItem(icon: "mic.slash.fill", label: "静音"),
        CallActionItem(icon: "circle.grid.3x3.fill", label: "键盘"),
        CallActionItem(icon: "speaker.wave.3.fill", label: "免提"),
        CallActionItem(icon: "plus", label: "添加通话"),
        CallActionItem(icon: "video.fill", label: "FaceTime"),
        CallActionItem(icon: "person.crop.circle", label: "通讯录")
    ]
    
    var body: some View {
        ZStack {
            // 磨砂背景
            ZStack {
                Color(red: 0.1, green: 0.15, blue: 0.2)
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            .ignoresSafeArea()
            .overlay(.ultraThinMaterial)
            
            VStack {
                if config.currentState == .ringing { incomingCallView }
                else if config.currentState == .connected { activeCallView }
            }
        }
        .onAppear {
            if config.currentState == .ringing { AudioManager.shared.playRingtone() }
            UIDevice.current.isProximityMonitoringEnabled = true
        }
        .onDisappear {
            UIDevice.current.isProximityMonitoringEnabled = false
            AudioManager.shared.stopAudio()
            timer?.invalidate()
        }
    }
    
    var incomingCallView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.5))
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                    .padding(.bottom, 10)
                Text(config.contact.name)
                    .font(.system(size: 36, weight: .thin))
                    .foregroundColor(.white)
                Text(config.contact.description)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
            HStack(spacing: 0) {
                VStack(spacing: 6) {
                    Image(systemName: "clock.fill").font(.title2)
                    Text("提醒我").font(.caption)
                }
                .frame(maxWidth: .infinity).foregroundColor(.white)
                VStack(spacing: 6) {
                    Image(systemName: "message.fill").font(.title2)
                    Text("信息").font(.caption)
                }
                .frame(maxWidth: .infinity).foregroundColor(.white)
            }
            .padding(.bottom, 60)
            HStack(spacing: 0) {
                VStack(spacing: 12) {
                    Button(action: { stopCall() }) {
                        Image(systemName: "phone.down.fill").font(.system(size: 32))
                            .frame(width: 72, height: 72).background(Color.red).foregroundColor(.white).clipShape(Circle())
                    }
                    Text("拒绝").font(.subheadline).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 12) {
                    Button(action: { answerCall() }) {
                        Image(systemName: "phone.fill").font(.system(size: 32))
                            .frame(width: 72, height: 72).background(Color.green).foregroundColor(.white).clipShape(Circle())
                    }
                    Text("接听").font(.subheadline).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 50)
        }
    }
    
    var activeCallView: some View {
        VStack {
            Spacer().frame(height: 50)
            VStack(spacing: 8) {
                Text(config.contact.name).font(.system(size: 28, weight: .regular)).foregroundColor(.white)
                Text(timeString(from: callDuration)).font(.system(size: 20, weight: .light)).foregroundColor(.white)
            }
            Spacer()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 25) {
                ForEach(callActions, id: \.self) { item in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.white.opacity(0.15)).frame(width: 72, height: 72)
                            Image(systemName: item.icon).font(.system(size: 30)).foregroundColor(.white)
                        }
                        Text(item.label).font(.caption).foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 30)
            Spacer()
            Button(action: { stopCall() }) {
                Image(systemName: "phone.down.fill").font(.system(size: 36))
                    .frame(width: 72, height: 72).background(Color.red).foregroundColor(.white).clipShape(Circle())
            }
            .padding(.bottom, 50)
        }
        .onAppear { startTimer() }
    }
    
    func answerCall() { withAnimation { config.currentState = .connected }; AudioManager.shared.playVoiceScript() }
    func stopCall() {
        AudioManager.shared.stopAudio(); timer?.invalidate()
        if config.isChainCallEnabled { scheduleNextCall() }
        else { withAnimation { config.currentState = .dashboard } }
    }
    func scheduleNextCall() {
        withAnimation { config.currentState = .dashboard }
        NotificationManager.shared.scheduleFakeCallNotification(timeInterval: 60, contactName: config.contact.name)
    }
    func startTimer() { timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in callDuration += 1 } }
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60; let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
