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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(config)
                .preferredColorScheme(.dark) // 强制深色模式，符合“隐秘”调性
                .onReceive(NotificationManager.shared.triggerCallSubject) { _ in
                    // 收到通知点击事件，无论当前在哪里，强制切到来电
                    config.currentState = .ringing
                }
        }
    }
}
