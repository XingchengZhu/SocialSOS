//
//  NotificationManager.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import UserNotifications
import UIKit
import Combine

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    // 触发信号：通知点击后告诉 App 跳转
    let triggerCallSubject = PassthroughSubject<Void, Never>()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已获取")
            } else {
                print("通知权限被拒绝")
            }
        }
    }
    
    // MARK: - 核心方法 (新版)
    // 供 ContentView (Dashboard) 使用
    func scheduleCallNotification(after seconds: TimeInterval, contactName: String) {
        let content = UNMutableNotificationContent()
        content.title = contactName
        content.body = "正在呼叫..."
        content.sound = UNNotificationSound(named: UNNotificationSoundName("ringtone.mp3"))
        content.categoryIdentifier = "FAKE_CALL"
        
        // 触发器 (防止 0 秒导致崩溃，至少 0.1)
        let triggerTime = max(seconds, 0.1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        
        let request = UNNotificationRequest(identifier: "FakeCallTrigger", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 兼容方法 (修复报错)
    // 供 FakeCallView 使用 (连环 Call 功能)
    func scheduleFakeCallNotification(timeInterval: TimeInterval, contactName: String) {
        // 直接转发调用新方法
        scheduleCallNotification(after: timeInterval, contactName: contactName)
    }
    
    // 取消所有待定通知
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Delegate 方法
    
    // 处理通知点击事件 (App 在后台或锁屏时点击通知)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        triggerCallSubject.send()
        completionHandler()
    }
    
    // App 在前台时也显示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
}
