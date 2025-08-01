
import SwiftUI

class ServiceManager: ObservableObject {
    @Published var requests: [ServiceRequest] = []
    
    var totalRequests: Int {
        return requests.count
    }
    
    var totalPrice: Double {
        return requests.reduce(0) { $0 + $1.service.price }
    }
    
    func addRequest(_ service: LogisticsService) {
        let request = ServiceRequest(service: service)
        requests.append(request)
    }
    
    func removeRequest(_ service: LogisticsService) {
        requests.removeAll { $0.service.id == service.id }
    }
    
    func completeOrder(_ order: ServiceRequest) {
        if let index = requests.firstIndex(where: { $0.id == order.id }) {
            requests[index].isCompleted = true
            requests[index].completionDate = Date()
        }
    }
} 
