//
//  Models.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI
import Combine

// App 的全局运行状态
enum AppState {
    case dashboard      // 首页
    case countingDown   // 可视化倒计时
    case ringing        // 正在响铃 (来电界面)
    case connected      // 通话中
    case fakeShutdown   // 模拟关机
    case silentText     // 静音弹幕
}

// 联系人配置
struct ContactProfile: Codable, Equatable {
    var name: String
    var avatarName: String
    var description: String // e.g. "移动电话"
}

// 全局配置单例
class AppConfig: ObservableObject {
    @Published var currentState: AppState = .dashboard
    
    // 连环呼叫开关
    @Published var isChainCallEnabled: Bool = false
    
    // 联系人信息 (自动保存到 UserDefaults)
    @Published var contact: ContactProfile {
        didSet { saveContact() }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "saved_contact"),
           let decoded = try? JSONDecoder().decode(ContactProfile.self, from: data) {
            self.contact = decoded
        } else {
            // 默认值
            self.contact = ContactProfile(
                name: "老板",
                avatarName: "Avatar",
                description: "移动电话"
            )
        }
    }
    
    private func saveContact() {
        if let encoded = try? JSONEncoder().encode(contact) {
            UserDefaults.standard.set(encoded, forKey: "saved_contact")
        }
    }
}
