
import Foundation

struct Order: Identifiable {
    let id: String
    let orderNumber: String
    let customerName: String
    let products: [String] // أسماء المنتجات المطلوبة
    let paymentMethod: String
    let store: String
    let city: String
    let senderAddress: String // عنوان المرسل الحقيقي
    let recipientAddress: String // عنوان المستلم الحقيقي
    let syncStatus: SyncStatus
    
    enum SyncStatus: String, Codable {
        case synced = "تم الرفع"
        case notSynced = "لم يتم الرفع"
    }
} 
