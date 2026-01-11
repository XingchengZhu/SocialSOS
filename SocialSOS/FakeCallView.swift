//
//  FakeCallView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

struct FakeCallView: View {
    @EnvironmentObject var config: AppConfig
    @State private var callDuration: TimeInterval = 0
    @State private var timer: Timer?
    
    // 获取屏幕尺寸，用于适配布局
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            // 背景：可以是高斯模糊的壁纸
            Color.black.ignoresSafeArea()
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.3), .black]), startPoint: .top, endPoint: .bottom)
                )
            
            VStack {
                if config.currentState == .ringing {
                    incomingCallView // 响铃界面
                } else if config.currentState == .connected {
                    activeCallView   // 通话中界面
                }
            }
            .padding(.top, 50)
        }
        .onAppear {
            if config.currentState == .ringing {
                AudioManager.shared.playRingtone()
            }
        }
    }
    
    // MARK: - 状态 1: 来电中界面
    var incomingCallView: some View {
        VStack(spacing: 20) {
            // 顶部信息
            VStack(spacing: 8) {
                Image(systemName: "person.circle.fill") // 这里的图片应该换成真实头像
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                
                Text(config.defaultContact.name)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(.white)
                
                Text(config.defaultContact.description)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 60)
            
            Spacer()
            
            // 底部接听/挂断按钮区域
            HStack(spacing: 60) {
                // 拒绝按钮
                VStack(spacing: 8) {
                    Button(action: {
                        stopCall()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.title)
                            .frame(width: 70, height: 70)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    Text("拒绝")
                        .foregroundColor(.white)
                }
                
                // 接听按钮
                VStack(spacing: 8) {
                    Button(action: {
                        answerCall()
                    }) {
                        Image(systemName: "phone.fill")
                            .font(.title)
                            .frame(width: 70, height: 70)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    Text("接听")
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 80)
        }
    }
    
    // MARK: - 状态 2: 通话中界面
    var activeCallView: some View {
        VStack {
            // 通话信息
            VStack(spacing: 8) {
                Text(config.defaultContact.name)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text(timeString(from: callDuration))
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 40)
            
            Spacer()
            
            // 功能网格 (静音、键盘等 - 仅展示，无功能)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 30) {
                ForEach(callActions, id: \.self) { item in
                    VStack(spacing: 5) {
                        Image(systemName: item.icon)
                            .font(.system(size: 30))
                            .frame(width: 65, height: 65)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                        Text(item.label)
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // 挂断按钮
            Button(action: {
                stopCall()
            }) {
                Image(systemName: "phone.down.fill")
                    .font(.largeTitle)
                    .frame(width: 80, height: 80)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            startTimer()
        }
    }
    
    // MARK: - 逻辑处理
    func answerCall() {
        withAnimation {
            config.currentState = .connected
        }
        AudioManager.shared.playVoiceScript()
    }
    
    func stopCall() {
        AudioManager.shared.stopAudio()
        timer?.invalidate()
        withAnimation {
            config.currentState = .dashboard
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            callDuration += 1
        }
    }
    
    // 时间格式化 00:00
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 网格按钮数据
    let callActions = [
        (icon: "mic.slash.fill", label: "静音"),
        (icon: "circle.grid.3x3.fill", label: "键盘"),
        (icon: "speaker.wave.3.fill", label: "免提"),
        (icon: "plus", label: "添加通话"),
        (icon: "video.fill", label: "FaceTime"),
        (icon: "person.crop.circle", label: "通讯录")
    ]
}
