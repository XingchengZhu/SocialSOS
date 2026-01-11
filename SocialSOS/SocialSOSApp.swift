//
//  SocialSOSApp.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

@main
struct SocialSOSApp: App {
    @StateObject var config = AppConfig()
    
    init() {
        // App 启动时请求通知权限
        NotificationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(config)
                .preferredColorScheme(.dark) // 保持深色模式
                // 监听通知点击
                .onReceive(NotificationManager.shared.triggerCallSubject) { _ in
                    config.currentState = .ringing
                }
        }
    }
}
