import Foundation
import UserNotifications
import SwiftUI

// MARK: - Tracking Notification Service
class TrackingNotificationService: ObservableObject {
    static let shared = TrackingNotificationService()
    
    @Published var hasPermission = false
    @Published var notifications: [TrackingNotification] = []
    
    private init() {
        checkNotificationPermission()
    }
    
    // MARK: - Permission Management
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Notification Methods
    func scheduleStatusUpdateNotification(trackingNumber: String, status: TrackingStatus) {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "تحديث حالة الطلب"
        content.body = "\(status.title) - رقم التتبع: \(trackingNumber)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(trackingNumber)_\(status.code)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        // إضافة إشعار محلي
        let notification = TrackingNotification(
            id: UUID().uuidString,
            trackingNumber: trackingNumber,
            title: "تحديث حالة الطلب",
            message: status.title,
            type: .statusUpdate,
            timestamp: Date(),
            isRead: false
        )
        
        DispatchQueue.main.async {
            self.notifications.insert(notification, at: 0)
            if self.notifications.count > 20 {
                self.notifications.removeLast()
            }
        }
    }
    
    func scheduleDeliveryNotification(trackingNumber: String, estimatedTime: Date) {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "قريب من الوصول!"
        content.body = "سيصل طلبك خلال 10 دقائق تقريباً"
        content.sound = .default
        
        let timeInterval = max(estimatedTime.timeIntervalSinceNow - 600, 60) // 10 دقائق قبل الوصول
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "\(trackingNumber)_delivery", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func markAsRead(notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
        }
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
}

// MARK: - Tracking Notification Model
struct TrackingNotification: Identifiable, Codable {
    let id: String
    let trackingNumber: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
    
    enum NotificationType: String, Codable {
        case statusUpdate = "status_update"
        case locationUpdate = "location_update"
        case deliveryAlert = "delivery_alert"
        case generalUpdate = "general_update"
        
        var icon: String {
            switch self {
            case .statusUpdate: return "checkmark.circle"
            case .locationUpdate: return "location"
            case .deliveryAlert: return "bell"
            case .generalUpdate: return "info.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .statusUpdate: return .green
            case .locationUpdate: return .blue
            case .deliveryAlert: return .orange
            case .generalUpdate: return .gray
            }
        }
    }
}

// MARK: - Notification Badge View
struct NotificationBadgeView: View {
    @StateObject private var notificationService = TrackingNotificationService.shared
    
    var unreadCount: Int {
        notificationService.notifications.filter { !$0.isRead }.count
    }
    
    var body: some View {
        ZStack {
            Image(systemName: "bell")
                .font(.system(size: 18))
                .foregroundColor(.primary)
            
            if unreadCount > 0 {
                Text("\(unreadCount)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 16, height: 16)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 8, y: -8)
            }
        }
    }
}

// MARK: - Notifications List View
struct NotificationsListView: View {
    @StateObject private var notificationService = TrackingNotificationService.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notificationService.notifications) { notification in
                    NotificationRowView(notification: notification)
                        .onTapGesture {
                            notificationService.markAsRead(notificationId: notification.id)
                        }
                }
                .onDelete(perform: deleteNotifications)
            }
            .navigationTitle("الإشعارات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("مسح الكل") {
                        notificationService.clearAllNotifications()
                    }
                    .disabled(notificationService.notifications.isEmpty)
                }
            }
        }
    }
    
    private func deleteNotifications(offsets: IndexSet) {
        notificationService.notifications.remove(atOffsets: offsets)
    }
}

struct NotificationRowView: View {
    let notification: TrackingNotification
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.type.icon)
                .font(.system(size: 16))
                .foregroundColor(notification.type.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(notification.message)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(formatTimestamp(notification.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
        .opacity(notification.isRead ? 0.7 : 1.0)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: date)
    }
} 
