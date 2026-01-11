//
//  NotificationManager.swift
//  SocialSOS
//
//  Created by zhuxingcheng on 2026/1/11.
//

import Foundation
import UserNotifications
import Combine

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    let triggerCallSubject = PassthroughSubject<Void, Never>()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    func scheduleFakeCallNotification(timeInterval: TimeInterval, contactName: String) {
        let content = createContent(contactName: contactName)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleFakeCallNotification(at date: Date, contactName: String) {
        let content = createContent(contactName: contactName)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func createContent(contactName: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = contactName
        content.body = "来电..."
        content.sound = UNNotificationSound(named: UNNotificationSoundName("ringtone.mp3"))
        content.categoryIdentifier = "FAKE_CALL"
        return content
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.async { self.triggerCallSubject.send() }
        completionHandler()
    }
}
