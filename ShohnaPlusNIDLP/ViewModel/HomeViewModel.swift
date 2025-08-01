import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var scrollOffset: CGFloat = 0
    @Published var recentShipments: [Shipment] = []
    @Published var isLoading: Bool = false

    var shipmentVM = ShipmentViewModel()

    init() {
        Task { await fetchRecentShipments() }
    }

    func fetchRecentShipments() async {
        isLoading = true
        await shipmentVM.fetchShipments()
        recentShipments = Array(shipmentVM.shipments.suffix(3))
        isLoading = false
    }
} 
