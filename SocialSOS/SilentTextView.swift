//
//  SilentTextView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

struct SilentTextView: View {
    @EnvironmentObject var config: AppConfig
    let presets = ["救我狗命", "撤！", "去厕所集合", "别喝了", "老婆叫我回家"]
    @State private var currentText = "救我狗命"
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: { config.currentState = .dashboard }) {
                        Image(systemName: "xmark.circle.fill").font(.title).foregroundColor(.gray)
                    }
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(presets, id: \.self) { text in
                                Button(text) { currentText = text }
                                    .padding(8).background(Color.gray.opacity(0.3)).cornerRadius(12)
                            }
                        }
                    }
                }.padding().padding(.top, 40)
                Spacer()
                GeometryReader { geo in
                    Text(currentText)
                        .font(.system(size: 150, weight: .black)).foregroundColor(.white).fixedSize()
                        .offset(x: scrollOffset)
                        .onAppear {
                            scrollOffset = geo.size.width
                            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                                scrollOffset = -geo.size.width * 2
                            }
                        }
                        .rotationEffect(.degrees(90))
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                Spacer()
            }
        }
    }
}
