//
//  ContentView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var config: AppConfig
    
    // 记录倒计时参数
    @State private var countdownTarget: Date = Date()
    @State private var countdownDuration: Double = 0
    
    var body: some View {
        ZStack {
            switch config.currentState {
            case .dashboard:
                DashboardView(
                    onStartForeground: { duration in
                        startCountdown(duration: duration)
                    }
                )
            case .countingDown:
                CountingDownView(targetTime: countdownTarget, totalDuration: countdownDuration)
            case .ringing, .connected:
                FakeCallView()
            case .fakeShutdown:
                FakeShutdownView()
            case .silentText:
                SilentTextView()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: config.currentState)
    }
    
    func startCountdown(duration: Double) {
        countdownDuration = duration
        countdownTarget = Date().addingTimeInterval(duration)
        config.currentState = .countingDown
        
        // 双重保险：Dispatch 作为兜底，防止 UI 层计时器误差
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if config.currentState == .countingDown {
                config.currentState = .ringing
            }
        }
    }
}

// 美化版 Dashboard
struct DashboardView: View {
    @EnvironmentObject var config: AppConfig
    @State private var showSettings = false
    
    var onStartForeground: (Double) -> Void
    
    enum TriggerMode { case interval, specificTime }
    @State private var triggerMode: TriggerMode = .interval
    @State private var customSeconds: Int = 10
    @State private var targetDate = Date().addingTimeInterval(60)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Social SOS")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("安全离场助手")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: { showSettings = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.15))
                                    .clipShape(Circle())
                            }
                            .sheet(isPresented: $showSettings) { SettingsView() }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // 核心控制卡片
                        VStack(spacing: 0) {
                            HStack {
                                Label("来电模拟", systemImage: "phone.badge.waveform.fill")
                                    .font(.headline)
                                Spacer()
                                Text(config.contact.name)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(6)
                            }
                            .padding()
                            
                            Divider()
                            
                            Toggle(isOn: $config.isChainCallEnabled) {
                                Text("连环夺命 Call")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .toggleStyle(SwitchToggleStyle(tint: .red))
                            
                            Divider().padding(.leading)
                            
                            Picker("", selection: $triggerMode) {
                                Text("倒计时").tag(TriggerMode.interval)
                                Text("定时触发").tag(TriggerMode.specificTime)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            
                            if triggerMode == .interval {
                                intervalControl
                            } else {
                                timePickerControl
                            }
                            
                            Divider()
                            
                            HStack(spacing: 0) {
                                Button(action: {
                                    let delay = calculateDelay()
                                    if delay > 0 { onStartForeground(delay) }
                                }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("前台等待")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.blue)
                                }
                                
                                Divider().frame(height: 30)
                                
                                Button(action: { startBackgroundSchedule() }) {
                                    HStack {
                                        Image(systemName: "lock.fill")
                                        Text("锁屏触发")
                                    }
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.green)
                                }
                            }
                            .background(Color.gray.opacity(0.05))
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        
                        // 工具网格
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            Button(action: { config.currentState = .fakeShutdown }) {
                                ToolCard(icon: "battery.0", title: "模拟关机", color: .red)
                            }
                            Button(action: { config.currentState = .silentText }) {
                                ToolCard(icon: "text.bubble.fill", title: "静音弹幕", color: .indigo)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                NotificationManager.shared.requestAuthorization()
            }
        }
    }
    
    var intervalControl: some View {
        VStack(spacing: 15) {
            Text("\(customSeconds) 秒")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Stepper("", value: $customSeconds, in: 5...3600, step: 5).labelsHidden()
            HStack(spacing: 12) {
                ForEach([10, 30, 60, 300], id: \.self) { sec in
                    Button(action: { customSeconds = sec }) {
                        Text("\(sec)s")
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(minWidth: 50)
                            .padding(.vertical, 8)
                            .background(customSeconds == sec ? Color.blue : Color.gray.opacity(0.1))
                            .foregroundColor(customSeconds == sec ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    var timePickerControl: some View {
        VStack {
            DatePicker("选择时刻", selection: $targetDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "zh_CN"))
            Text(timeDifferenceString(target: targetDate))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
        }
    }
    
    func timeDifferenceString(target: Date) -> String {
        let diff = target.timeIntervalSince(Date())
        return diff <= 0 ? "时间已过" : "将在 \(Int(diff)/60)分 后响铃"
    }
    
    func startBackgroundSchedule() {
        let delay = calculateDelay()
        guard delay > 0 else { return }
        NotificationManager.shared.scheduleFakeCallNotification(
            timeInterval: delay,
            contactName: config.contact.name
        )
    }
    
    func calculateDelay() -> TimeInterval {
        if triggerMode == .interval { return Double(customSeconds) }
        else {
            var date = targetDate
            if date < Date() { date = Calendar.current.date(byAdding: .day, value: 1, to: date)! }
            return date.timeIntervalSince(Date())
        }
    }
}

struct ToolCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .padding(10)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Text("点击立即触发")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
