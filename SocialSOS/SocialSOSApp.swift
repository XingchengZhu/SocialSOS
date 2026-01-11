//
//  SocialSOSApp.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

@main
struct SocialSOSApp: App {
    // 1. 初始化全局配置 (Source of Truth)
    // 这里是整个 App 数据状态的源头
    @StateObject var config = AppConfig()
    
    var body: some Scene {
        WindowGroup {
            // 2. 将 config 注入到 ContentView
            // 确保后续所有界面都能访问到 config
            ContentView()
                .environmentObject(config)
                .preferredColorScheme(.dark) // 强制深色模式，符合“伪装”需求
        }
    }
}
