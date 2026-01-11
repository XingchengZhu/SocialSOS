//
//  FakeShutdownView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

struct FakeShutdownView: View {
    @EnvironmentObject var config: AppConfig
    @State private var showIcon = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if showIcon {
                Image(systemName: "battery.0").resizable().scaledToFit().frame(width: 80)
                    .foregroundColor(Color(red: 0.8, green: 0.1, blue: 0.1))
            }
        }
        .statusBarHidden(true)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation { showIcon = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showIcon = false } }
        }
        .onLongPressGesture(minimumDuration: 3) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            config.currentState = .dashboard
        }
    }
}
