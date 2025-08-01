import Foundation
import CloudKit

@MainActor
class ShipmentViewModel: ObservableObject {
    @Published var shipments: [Shipment] = []
    @Published var error: String?
    @Published var isLoading = false
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.NIDLP.visopn.oo")
        self.publicDatabase = container.publicCloudDatabase
    }
    
    func saveShipment(_ shipment: Shipment) async {
        isLoading = true
        do {
            let record = shipment.toCKRecord()
            let savedRecord = try await publicDatabase.save(record)
            let savedShipment = Shipment.fromCKRecord(savedRecord)
            shipments.append(savedShipment)
            isLoading = false
        } catch {
            self.error = "خطأ في حفظ الشحنة: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func fetchShipments() async {
        isLoading = true
        do {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "Shipment", predicate: predicate)
            let result = try await publicDatabase.records(matching: query)
            let fetchedShipments = result.matchResults.compactMap { try? $0.1.get() }
                .map { Shipment.fromCKRecord($0) }
            self.shipments = fetchedShipments
            isLoading = false
        } catch {
            self.error = "خطأ في جلب الشحنات: \(error.localizedDescription)"
            isLoading = false
        }
    }
} 
