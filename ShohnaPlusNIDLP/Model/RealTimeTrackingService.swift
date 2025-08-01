
import Foundation
import MapKit
import Combine

extension Notification.Name {
    static let trackingLocationUpdated = Notification.Name("trackingLocationUpdated")
}

// MARK: - Real-Time Tracking Service
class RealTimeTrackingService: ObservableObject {
    @Published var activeTrackings: [String: RealTimeTrackingInfo] = [:]
    @Published var liveUpdates: [TrackingUpdate] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var updateTimers: [String: Timer] = [:]
    
    static let shared = RealTimeTrackingService()
    
    private init() {
        setupMockData()
    }
    
    // MARK: - Public Methods
    func startTracking(trackingNumber: String) -> RealTimeTrackingInfo? {
        if let tracking = activeTrackings[trackingNumber] {
            startRealTimeUpdates(for: trackingNumber)
            return tracking
        }
        return nil
    }
    
    func stopTracking(trackingNumber: String) {
        updateTimers[trackingNumber]?.invalidate()
        updateTimers.removeValue(forKey: trackingNumber)
    }
    
    func getTrackingInfo(trackingNumber: String) -> RealTimeTrackingInfo? {
        return activeTrackings[trackingNumber]
    }
    
    // MARK: - Real-Time Updates
    private func startRealTimeUpdates(for trackingNumber: String) {
        // إيقاف Timer السابق إذا كان موجوداً
        updateTimers[trackingNumber]?.invalidate()
        
        // إنشاء timer جديد للتحديثات كل 5 ثواني
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.simulateLocationUpdate(for: trackingNumber)
        }
        
        updateTimers[trackingNumber] = timer
    }
    
    private func simulateLocationUpdate(for trackingNumber: String) {
        guard var tracking = activeTrackings[trackingNumber] else { return }
        
        // محاكاة تحديث الموقع
        let currentLocation = tracking.currentLocation
        let progress = tracking.currentStatus.percentage / 100.0
        
        // إضافة حركة عشوائية صغيرة للموقع
        let latOffset = Double.random(in: -0.001...0.001)
        let lonOffset = Double.random(in: -0.001...0.001)
        
        let newLocation = TrackingLocation(
            latitude: currentLocation.latitude + latOffset,
            longitude: currentLocation.longitude + lonOffset,
            address: currentLocation.address,
            timestamp: Date()
        )
        
        tracking.currentLocation = newLocation
        tracking.lastUpdated = Date()
        
        // تحديث الحالة بناءً على التقدم
        let oldStatus = tracking.currentStatus
        if progress < 1.0 {
            let newProgress = min(progress + 0.02, 1.0) // تقليل سرعة التقدم
            let newStatus = updateStatusBasedOnProgress(newProgress)
            
            // إرسال إشعار عند تغيير الحالة
            if oldStatus.code != newStatus.code {
                TrackingNotificationService.shared.scheduleStatusUpdateNotification(
                    trackingNumber: trackingNumber,
                    status: newStatus
                )
            }
            
            tracking.currentStatus = newStatus
        }
        
        // تحديث البيانات في القاموس
        DispatchQueue.main.async {
            self.activeTrackings[trackingNumber] = tracking
            
            // إرسال notification لتحديث الخريطة
            NotificationCenter.default.post(name: .trackingLocationUpdated, object: tracking)
        }
        
        // إضافة تحديث للقائمة
        let update = TrackingUpdate(
            trackingNumber: trackingNumber,
            newLocation: newLocation,
            newStatus: nil,
            message: generateRandomUpdateMessage(),
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.liveUpdates.insert(update, at: 0)
            if self.liveUpdates.count > 50 {
                self.liveUpdates.removeLast()
            }
        }
    }
    
    private func updateStatusBasedOnProgress(_ progress: Double) -> TrackingStatus {
        switch progress {
        case 0.0..<0.3:
            return .preparing
        case 0.3..<0.7:
            return .dispatched
        case 0.7..<0.95:
            return .nearby
        case 0.95...1.0:
            return .delivered
        default:
            return .orderPlaced
        }
    }
    
    private func generateRandomUpdateMessage() -> String {
        let messages = [
            "الطلب في الطريق إليك",
            "السائق يقترب من موقعك",
            "تم تحديث موقع الشحنة",
            "الطلب يسير وفقاً للجدول الزمني",
            "السائق على الطريق السريع",
            "متوقع الوصول خلال دقائق"
        ]
        return messages.randomElement() ?? "تحديث الموقع"
    }
    
    // MARK: - Mock Data Setup
    private func setupMockData() {
        let sampleTrackings = [
            // أرقام تتبع واقعية
            createMockTracking(
                trackingNumber: "R8282",
                status: .dispatched,
                location: TrackingLocation(
                    latitude: 24.7136,
                    longitude: 46.6753,
                    address: "الرياض، شارع الملك فهد",
                    timestamp: Date()
                ),
                driverName: "أحمد محمد",
                vehicleType: "شاحنة صغيرة"
            ),
            createMockTracking(
                trackingNumber: "R8283",
                status: .nearby,
                location: TrackingLocation(
                    latitude: 21.4858,
                    longitude: 39.1925,
                    address: "جدة، شارع المدينة المنورة",
                    timestamp: Date()
                ),
                driverName: "سالم العتيبي",
                vehicleType: "فان"
            ),
            createMockTracking(
                trackingNumber: "R8284",
                status: .preparing,
                location: TrackingLocation(
                    latitude: 26.4207,
                    longitude: 50.0888,
                    address: "الدمام، الكورنيش الشرقي",
                    timestamp: Date()
                ),
                driverName: "محمد الغامدي",
                vehicleType: "شاحنة متوسطة"
            ),
            createMockTracking(
                trackingNumber: "R8285",
                status: .delivered,
                location: TrackingLocation(
                    latitude: 24.4539,
                    longitude: 39.5940,
                    address: "المدينة المنورة، شارع الملك عبدالعزيز",
                    timestamp: Date()
                ),
                driverName: "خالد الأحمدي",
                vehicleType: "دراجة نارية"
            ),
            createMockTracking(
                trackingNumber: "SHP001",
                status: .nearby,
                location: TrackingLocation(
                    latitude: 25.3548,
                    longitude: 49.5834,
                    address: "الخبر، طريق الملك فهد",
                    timestamp: Date()
                ),
                driverName: "عبدالله الزهراني",
                vehicleType: "فان"
            ),
            createMockTracking(
                trackingNumber: "SHP002",
                status: .dispatched,
                location: TrackingLocation(
                    latitude: 18.2465,
                    longitude: 42.5506,
                    address: "أبها، شارع الملك فيصل",
                    timestamp: Date()
                ),
                driverName: "فهد عسيري",
                vehicleType: "شاحنة صغيرة"
            ),
            // أرقام التتبع القديمة للتوافق
            createMockTracking(
                trackingNumber: "TRK001",
                status: .dispatched,
                location: TrackingLocation(
                    latitude: 24.7136,
                    longitude: 46.6753,
                    address: "الرياض، حي الملز",
                    timestamp: Date()
                ),
                driverName: "يوسف المطيري",
                vehicleType: "شاحنة متوسطة"
            ),
            createMockTracking(
                trackingNumber: "TRK002",
                status: .preparing,
                location: TrackingLocation(
                    latitude: 21.4858,
                    longitude: 39.1925,
                    address: "جدة، حي البلد",
                    timestamp: Date()
                ),
                driverName: "نواف الحربي",
                vehicleType: "فان"
            )
        ]
        
        for tracking in sampleTrackings {
            activeTrackings[tracking.trackingNumber] = tracking
        }
    }
    
    private func createMockTracking(
        trackingNumber: String,
        status: TrackingStatus,
        location: TrackingLocation,
        driverName: String,
        vehicleType: String
    ) -> RealTimeTrackingInfo {
        let driver = DriverInfo(
            id: UUID().uuidString,
            name: driverName,
            phoneNumber: "+966 50 123 4567",
            vehicleType: vehicleType,
            vehicleNumber: "أ ب ج \(Int.random(in: 100...999))",
            rating: Double.random(in: 4.2...5.0),
            photoURL: nil
        )
        
        let steps = [
            TrackingStep(
                title: "تم تأكيد الطلب",
                description: "تم استلام طلبك وتأكيده",
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
                location: "مركز الطلبات",
                isCompleted: true,
                isCurrentStep: false
            ),
            TrackingStep(
                title: "جاري التحضير",
                description: "يتم تحضير منتجاتك",
                timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
                location: "المصنع",
                isCompleted: true,
                isCurrentStep: false
            ),
            TrackingStep(
                title: "خرج للتسليم",
                description: "الطلب مع السائق",
                timestamp: Calendar.current.date(byAdding: .minute, value: -30, to: Date()),
                location: location.address,
                isCompleted: status.percentage >= 60,
                isCurrentStep: status.code == "DISPATCHED"
            ),
            TrackingStep(
                title: "قريب من الوصول",
                description: "السائق على بُعد دقائق",
                timestamp: nil,
                location: "موقعك",
                isCompleted: status.percentage >= 85,
                isCurrentStep: status.code == "NEARBY"
            ),
            TrackingStep(
                title: "تم التسليم",
                description: "تم تسليم الطلب بنجاح",
                timestamp: nil,
                location: "موقعك",
                isCompleted: status.percentage >= 100,
                isCurrentStep: false
            )
        ]
        
        return RealTimeTrackingInfo(
            trackingNumber: trackingNumber,
            currentStatus: status,
            currentLocation: location,
            estimatedDeliveryTime: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date(),
            orderDate: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
            driverInfo: driver,
            trackingSteps: steps,
            isLive: true,
            lastUpdated: Date()
        )
    }
} 
