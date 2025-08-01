
import SwiftUI

struct LogisticsService: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let image: String
    let category: String
    let isPopular: Bool
    let estimatedTime: String
    let features: [String]
    
    init(id: String, name: String, description: String, price: Double, image: String, category: String, isPopular: Bool, estimatedTime: String, features: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.image = image
        self.category = category
        self.isPopular = isPopular
        self.estimatedTime = estimatedTime
        self.features = features
    }
} 
