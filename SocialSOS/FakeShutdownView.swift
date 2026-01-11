//
//  FakeShutdownView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

struct FakeShutdownView: View {
    @EnvironmentObject var config: AppConfig
    
    // 控制空电池图标的显示
    @State private var showLowBatteryIcon = false
    // 记录长按是否完成
    @State private var isLongPressing = false
    
    var body: some View {
        ZStack {
            // 1. 全黑背景 (忽略安全区域，铺满全屏)
            Color.black.ignoresSafeArea()
            
            // 2. 模拟没电图标 (默认隐藏，点击屏幕时闪现)
            if showLowBatteryIcon {
                Image(systemName: "battery.0")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .foregroundColor(Color(red: 0.8, green: 0.1, blue: 0.1)) // 没电的红色
                    .transition(.opacity)
            }
            
            // 提示用户如何退出的隐藏文字 (仅在长按时微微显示，作为开发调试或引导)
            if isLongPressing {
                VStack {
                    Spacer()
                    Text("保持按住退出...")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.bottom, 50)
                }
            }
        }
        // 3. 隐藏状态栏 (关键点：让顶部时间电量消失)
        .statusBarHidden(true)
        // 4. 交互逻辑
        .contentShape(Rectangle()) // 确保整个黑屏区域都能响应手势
        .onTapGesture {
            // 点击屏幕：闪现红色电池图标 2秒
            withAnimation {
                showLowBatteryIcon = true
            }
            // 延迟隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showLowBatteryIcon = false
                }
            }
        }
        // 5. 长按 3 秒退出 (安全出口)
        .onLongPressGesture(minimumDuration: 3, pressing: { isPressing in
            // 正在按住时的状态变化
            withAnimation {
                isLongPressing = isPressing
            }
        }) {
            // 长按结束，执行退出
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            config.currentState = .dashboard
        }
    }
}
