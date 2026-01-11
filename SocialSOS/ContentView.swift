//
//  ContentView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

// 1. 主容器 (原 MainContainer，现改名为 ContentView)
// 负责根据状态切换显示不同的视图
struct ContentView: View {
    @EnvironmentObject var config: AppConfig
    
    var body: some View {
        ZStack {
            switch config.currentState {
            case .dashboard:
                DashboardView()
            case .countingDown:
                // 倒计时黑屏状态
                Color.black.ignoresSafeArea()
                    .overlay(Text("等待来电...").foregroundColor(.gray).font(.caption))
            case .ringing, .connected:
                FakeCallView()
            case .fakeShutdown:
                FakeShutdownView()
            }
        }
        .animation(.easeInOut, value: config.currentState)
    }
}

// 2. 首页 Dashboard
struct DashboardView: View {
    @EnvironmentObject var config: AppConfig
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 头部欢迎语
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Social SOS")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                            Text("你的社交安全气囊")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    // 功能卡片 1: 模拟来电
                    Button(action: {
                        startFakeCallSequence()
                    }) {
                        FeatureCard(
                            icon: "phone.circle.fill",
                            title: "模拟来电",
                            subtitle: "10秒后自动触发",
                            color: .green
                        )
                    }
                    
                    // 功能卡片 2: 模拟关机
                    Button(action: {
                        config.currentState = .fakeShutdown
                    }) {
                        FeatureCard(
                            icon: "battery.0",
                            title: "模拟没电",
                            subtitle: "点击黑屏，长按退出",
                            color: .red
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    // 开始模拟来电流程
    func startFakeCallSequence() {
        config.currentState = .countingDown
        
        // 倒计时 10 秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            // 只有当前还在倒计时状态才触发响铃（防止用户中途退出了）
            if config.currentState == .countingDown {
                config.currentState = .ringing
            }
        }
    }
}

// 3. 通用卡片组件
struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
