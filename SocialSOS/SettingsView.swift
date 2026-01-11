//
//  SettingsView.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var config: AppConfig
    @Environment(\.presentationMode) var presentationMode
    
    let presets = [("老板", "移动电话"), ("老妈", "FaceTime 视频"), ("外卖", "刚刚"), ("老婆", "移动电话")]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("来电人伪装")) {
                    TextField("显示名称", text: $config.contact.name)
                    TextField("副标题", text: $config.contact.description)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(presets, id: \.0) { item in
                                Button(item.0) { config.contact.name = item.0; config.contact.description = item.1 }
                                    .padding(8).background(Color.blue.opacity(0.1)).cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(trailing: Button("完成") { presentationMode.wrappedValue.dismiss() })
        }
    }
}
