
import Foundation

struct ReturnInformation: Identifiable {
    let id: String
    var customerName: String
    var customerEmail: String
    var customerPhone: String
    var returnCode: String
    var orderNumber: String
    var returnDate: Date
    var orderDate: Date
    var productCondition: String
    var shippingInfo: String
    var imageData: [Data]
    var status: String 
    var notes: String
    var origin: String
    var destination: String
    var weight: String
    var returnTime: String
    var aiAnalysisResult: String?
    
    static func createNew() -> ReturnInformation {
        ReturnInformation(
            id: UUID().uuidString,
            customerName: "",
            customerEmail: "",
            customerPhone: "",
            returnCode: "",
            orderNumber: "",
            returnDate: Date(),
            orderDate: Date(),
            productCondition: "",
            shippingInfo: "",
            imageData: [],
            status: "Pending",
            notes: "",
            origin: "",
            destination: "",
            weight: "",
            returnTime: "",
            aiAnalysisResult: nil
        )
    }
} 
