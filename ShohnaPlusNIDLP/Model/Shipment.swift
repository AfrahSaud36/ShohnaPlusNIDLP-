
import Foundation
import CloudKit
import SwiftUI

struct Shipment: Identifiable {
    let id: String
    let trackingNumber: String
    let recipientName: String
    let deliveryAddress: String
    let deliveryAddressFrom: String
    let status: String
    let shipmentDate: Date
    let supplier: String
    let notes: String
    let shippingCompany: String
    let shippingType: String
    let shippingCost: Double
    let orderSource: String
    let paymentMethod: String
    
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Shipment")
        record["trackingNumber"] = trackingNumber
        record["recipientName"] = recipientName
        record["deliveryAddress"] = deliveryAddress
        record["deliveryAddressFrom"] = deliveryAddressFrom
        record["status"] = status
        record["shipmentDate"] = shipmentDate
        record["supplier"] = supplier
        record["notes"] = notes
        record["shippingCompany"] = shippingCompany
        record["shippingType"] = shippingType
        record["shippingCost"] = shippingCost
        record["orderSource"] = orderSource
        record["paymentMethod"] = paymentMethod
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> Shipment {
        return Shipment(
            id: record.recordID.recordName,
            trackingNumber: record["trackingNumber"] as? String ?? "",
            recipientName: record["recipientName"] as? String ?? "",
            deliveryAddress: record["deliveryAddress"] as? String ?? "",
            deliveryAddressFrom: record["deliveryAddressFrom"] as? String ?? "",
            status: record["status"] as? String ?? "",
            shipmentDate: record["shipmentDate"] as? Date ?? Date(),
            supplier: record["supplier"] as? String ?? "",
            notes: record["notes"] as? String ?? "",
            shippingCompany: record["shippingCompany"] as? String ?? "",
            shippingType: record["shippingType"] as? String ?? "",
            shippingCost: record["shippingCost"] as? Double ?? 0.0,
            orderSource: record["orderSource"] as? String ?? "",
            paymentMethod: record["paymentMethod"] as? String ?? ""
        )
    }
} 
