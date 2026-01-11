//
//  ContentView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var config: AppConfig
    
    var body: some View {
        ZStack {
            // 背景色控制
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            switch config.currentState {
            case .dashboard, .countingDown:
                // 将倒计时状态也合并在 DashboardView 里处理，实现平滑过渡
                DashboardView()
            case .ringing, .connected:
                FakeCallView()
            case .fakeShutdown:
                FakeShutdownView()
            case .silentText:
                SilentTextView()
            }
        }
        .animation(.easeInOut, value: config.currentState)
    }
}

struct DashboardView: View {
    @EnvironmentObject var config: AppConfig
    @Environment(\.scenePhase) var scenePhase // 监听 App 前后台状态
    
    // 倒计时相关状态
    @State private var timeRemaining: TimeInterval = 0
    @State private var totalDuration: TimeInterval = 10.0 // 默认倒计时时长
    @State private var timer: Timer?
    @State private var targetDate: Date? // 用于后台计时校准
    
    // 动画相关
    @State private var isCountingDown = false
    @State private var showSettings = false // 控制设置页
    
    var body: some View {
        NavigationView {
            ZStack {
                // 1. 正常仪表盘界面
                List {
                    // 头部信息
                    Section {
                        HStack(spacing: 15) {
                            Image(systemName: "person.crop.circle.fill") // 使用系统图标更稳妥
                                .resizable()
                                .foregroundColor(.gray)
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("当前伪装对象")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                // 修正点：使用 config.contact (Models.swift中的定义)
                                Text(config.contact.name)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                            
                            // 点击这里也可以去设置
                            Button(action: { showSettings = true }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("配置")
                    }
                    
                    // 模拟来电触发区
                    Section {
                        Button(action: {
                            startCountdown(duration: 10.0) // 10秒触发
                        }) {
                            ModernFeatureRow(
                                icon: "phone.badge.plus",
                                color: .green,
                                title: "快速触发 (10s)",
                                subtitle: "适合即兴脱身"
                            )
                        }
                        
                        Button(action: {
                            startCountdown(duration: 30.0) // 30秒触发
                        }) {
                            ModernFeatureRow(
                                icon: "timer",
                                color: .orange,
                                title: "延迟触发 (30s)",
                                subtitle: "预设逃离时间"
                            )
                        }
                        
                        // 自定义时间触发 (保留功能)
                        Button(action: {
                            startCountdown(duration: 60.0)
                        }) {
                            ModernFeatureRow(
                                icon: "clock.arrow.circlepath",
                                color: .blue,
                                title: "一分钟后 (60s)",
                                subtitle: "从容整理物品"
                            )
                        }
                    } header: {
                        Text("模拟来电")
                    }
                    
                    // 紧急伪装区
                    Section {
                        Button(action: {
                            config.currentState = .fakeShutdown
                        }) {
                            ModernFeatureRow(
                                icon: "power.circle.fill",
                                color: .red,
                                title: "模拟没电关机",
                                subtitle: "点击屏幕闪烁红电量"
                            )
                        }
                        
                        Button(action: {
                            config.currentState = .silentText
                        }) {
                            ModernFeatureRow(
                                icon: "captions.bubble.fill",
                                color: .purple,
                                title: "静音弹幕",
                                subtitle: "KTV/会议室专用"
                            )
                        }
                    } header: {
                        Text("紧急伪装")
                    }
                }
                .listStyle(.insetGrouped) // 现代 iOS 风格
                .navigationTitle("Social SOS")
                // 添加设置入口
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .blur(radius: isCountingDown ? 10 : 0) // 倒计时模糊背景
                .disabled(isCountingDown)
                
                // 2. 倒计时浮层 (覆盖在上面)
                if isCountingDown {
                    // 全屏遮罩，点击取消
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .onTapGesture {
                            cancelCountdown()
                        }
                    
                    VStack(spacing: 30) {
                        Text("即将来电")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        // 核心：倒计时显示逻辑
                        Text(formatTime(timeRemaining))
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText(value: timeRemaining)) // iOS 16 数字滚动动画
                        
                        Button(action: {
                            cancelCountdown()
                        }) {
                            Text("点击取消")
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Capsule().stroke(Color.white.opacity(0.3)))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
        }
        // 监听前后台切换
        .onChange(of: scenePhase) { newPhase in
            if isCountingDown {
                if newPhase == .background {
                    // 切到后台：记录目标时间，发送通知
                    print("App 进入后台，倒计时继续")
                    NotificationManager.shared.scheduleCallNotification(
                        after: timeRemaining,
                        contactName: config.contact.name
                    )
                } else if newPhase == .active {
                    // 切回前台：取消通知，校准时间
                    NotificationManager.shared.cancelNotifications()
                    if let target = targetDate {
                        let remaining = target.timeIntervalSinceNow
                        if remaining <= 0 {
                            // 如果回来时已经超时，直接看来电
                            triggerCall()
                        } else {
                            // 否则更新剩余时间
                            timeRemaining = remaining
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Logic
    
    func startCountdown(duration: TimeInterval) {
        // 设置状态
        withAnimation {
            isCountingDown = true
            config.currentState = .countingDown
        }
        
        // 初始化时间
        timeRemaining = duration
        totalDuration = duration
        targetDate = Date().addingTimeInterval(duration)
        
        // 开始高频计时器 (0.1秒刷新一次以支持一位小数)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                triggerCall()
            }
        }
    }
    
    func cancelCountdown() {
        timer?.invalidate()
        NotificationManager.shared.cancelNotifications()
        withAnimation {
            isCountingDown = false
            config.currentState = .dashboard
        }
    }
    
    func triggerCall() {
        timer?.invalidate()
        targetDate = nil
        isCountingDown = false // 结束倒计时 UI
        config.currentState = .ringing // 进入响铃
    }
    
    // 你的需求：大于10秒显示整数，小于10秒显示一位小数
    func formatTime(_ time: TimeInterval) -> String {
        let t = max(0, time)
        if t > 10.0 {
            return String(format: "%.0f", ceil(t)) // 整数 (向上取整体验更好)
        } else {
            return String(format: "%.1f", t) // 一位小数
        }
    }
}

// 提取出来的漂亮的列表行组件
struct ModernFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
