//
//  Models.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI
import Combine  // <--- 新增：显式引入 Combine 框架，彻底解决报错

// App 的全局运行状态
enum AppState {
    case dashboard      // 首页
    case countingDown   // 倒计时等待中 (黑屏)
    case ringing        // 正在响铃 (来电界面)
    case connected      // 通话中
    case fakeShutdown   // 模拟关机/没电
}

// 模拟联系人的数据模型
struct ContactProfile {
    let name: String
    let avatarName: String
    let description: String // e.g. "移动电话"
}

// 全局配置单例
class AppConfig: ObservableObject {
    @Published var currentState: AppState = .dashboard
    
    // 默认配置：模拟一个“老板”的来电
    let defaultContact = ContactProfile(
        name: "老板",
        avatarName: "Avatar", // 确保 Assets 里有这个名字的图片
        description: "移动电话"
    )
}
