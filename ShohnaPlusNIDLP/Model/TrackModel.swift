import Foundation
import MapKit

struct MapPin: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let type: PinType
    
    enum PinType: Hashable {
        case start, end, shipment
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(title)
        hasher.combine(type)
    }
    
    static func == (lhs: MapPin, rhs: MapPin) -> Bool {
        return lhs.id == rhs.id &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude &&
               lhs.title == rhs.title &&
               lhs.type == rhs.type
    }
}

// MARK: - Real-Time Tracking Models
struct RealTimeTrackingInfo: Identifiable, Codable {
    let id = UUID()
    let trackingNumber: String
    var currentStatus: TrackingStatus
    var currentLocation: TrackingLocation
    let estimatedDeliveryTime: Date
    let orderDate: Date
    let driverInfo: DriverInfo?
    let trackingSteps: [TrackingStep]
    let isLive: Bool
    var lastUpdated: Date
}

struct TrackingStatus: Codable {
    let code: String
    let title: String
    let description: String
    let percentage: Double
    let isCompleted: Bool
    
    static let orderPlaced = TrackingStatus(
        code: "ORDER_PLACED",
        title: "تم تأكيد الطلب",
        description: "تم استلام طلبك وجاري التحضير",
        percentage: 0,
        isCompleted: true
    )
    
    static let preparing = TrackingStatus(
        code: "PREPARING",
        title: "جاري التحضير",
        description: "يتم تحضير الطلب في المصنع",
        percentage: 25,
        isCompleted: true
    )
    
    static let dispatched = TrackingStatus(
        code: "DISPATCHED",
        title: "خرج للتسليم",
        description: "الطلب في طريقه إليك",
        percentage: 60,
        isCompleted: true
    )
    
    static let nearby = TrackingStatus(
        code: "NEARBY",
        title: "قريب من الوصول",
        description: "السائق على بُعد أقل من 10 دقائق",
        percentage: 85,
        isCompleted: true
    )
    
    static let delivered = TrackingStatus(
        code: "DELIVERED",
        title: "تم التسليم",
        description: "تم تسليم الطلب بنجاح",
        percentage: 100,
        isCompleted: true
    )
}

struct TrackingLocation: Codable {
    let latitude: Double
    let longitude: Double
    let address: String
    let timestamp: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct DriverInfo: Codable {
    let id: String
    let name: String
    let phoneNumber: String
    let vehicleType: String
    let vehicleNumber: String
    let rating: Double
    let photoURL: String?
}

struct TrackingStep: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let timestamp: Date?
    let location: String?
    let isCompleted: Bool
    let isCurrentStep: Bool
}

// MARK: - Real-Time Update Models
struct TrackingUpdate: Codable {
    let trackingNumber: String
    let newLocation: TrackingLocation
    let newStatus: TrackingStatus?
    let message: String?
    let timestamp: Date
}

// MARK: - Delivery Time Estimation
struct DeliveryEstimation {
    let estimatedTime: Date
    let confidence: EstimationConfidence
    let factors: [String]
    
    enum EstimationConfidence {
        case high, medium, low
        
        var description: String {
            switch self {
            case .high: return "دقيق"
            case .medium: return "تقريبي"
            case .low: return "متغير"
            }
        }
    }
} 
