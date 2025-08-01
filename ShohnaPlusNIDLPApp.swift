import SwiftUI

@main
struct ShohnaPlusNIDLPApp: App {
    @StateObject private var shipmentVM = ShipmentViewModel()
    var body: some Scene {
        WindowGroup {
            // إذا كان هناك TabView أو Navigation رئيسي، مرر shipmentVM لكلا الواجهتين
            ContentView()
        }
    }
} 