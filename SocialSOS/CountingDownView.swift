//
//  CountingDownView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI
import Combine

struct CountingDownView: View {
    @EnvironmentObject var config: AppConfig
    @Environment(\.scenePhase) var scenePhase
    
    let targetTime: Date
    let totalDuration: Double
    
    @State private var timeRemaining: Double = 0
    @State private var progress: Double = 1.0
    
    // 自动连接的计时器
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                Spacer()
                
                // 倒计时圆环
                ZStack {
                    Circle().stroke(lineWidth: 15).opacity(0.1).foregroundColor(.white)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                        .stroke(
                            LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round)
                        )
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear(duration: 0.1), value: progress)
                        .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 0)
                    
                    // 智能数字显示
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText(countsDown: true))
                }
                .frame(width: 260, height: 260)
                
                VStack(spacing: 10) {
                    Text("救援正在赶来...")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    Text("预计到达: \(targetTime.formatted(date: .omitted, time: .standard))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 取消按钮
                Button(action: { cancelRescue() }) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                        Text("取消救援")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(Color.red.opacity(0.8))
                    .clipShape(Capsule())
                    .shadow(color: .red.opacity(0.4), radius: 10, y: 5)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            updateTime()
            scheduleBackgroundNotification()
        }
        .onReceive(timer) { _ in updateTime() }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active { updateTime() }
        }
    }
    
    func formatTime(_ time: Double) -> String {
        if time > 10.0 { return String(format: "%.0f", ceil(time)) }
        else { return String(format: "%.1f", max(0, time)) }
    }
    
    func updateTime() {
        let remaining = targetTime.timeIntervalSince(Date())
        if remaining <= 0 {
            timeRemaining = 0
            progress = 0
        } else {
            timeRemaining = remaining
            progress = remaining / totalDuration
        }
    }
    
    func cancelRescue() {
        config.currentState = .dashboard
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func scheduleBackgroundNotification() {
        let remaining = targetTime.timeIntervalSince(Date())
        if remaining > 0 {
            NotificationManager.shared.scheduleFakeCallNotification(
                timeInterval: remaining,
                contactName: config.contact.name
            )
        }
    }
}
