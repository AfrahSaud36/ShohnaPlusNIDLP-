
import SwiftUI

struct ServiceRequest: Identifiable, Codable {
    let id: UUID
    let service: LogisticsService
    let requestDate: Date
    var completionDate: Date?
    var isCompleted: Bool
    
    init(service: LogisticsService, requestDate: Date = Date()) {
        self.id = UUID()
        self.service = service
        self.requestDate = requestDate
        self.completionDate = nil
        self.isCompleted = false
    }
    
    mutating func complete() {
        isCompleted = true
        completionDate = Date()
    }
} 
