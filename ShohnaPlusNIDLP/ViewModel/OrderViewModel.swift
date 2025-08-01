import Foundation
import CloudKit

@MainActor
class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var error: String?
    @Published var isLoading = false
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.NIDLP.visopn.oo")
        self.publicDatabase = container.publicCloudDatabase
    }
    
    func saveOrder(_ order: Order) async {
        isLoading = true
        do {
            let record = orderToCKRecord(order)
            let savedRecord = try await publicDatabase.save(record)
            let savedOrder = orderFromCKRecord(savedRecord)
            orders.append(savedOrder)
            isLoading = false
        } catch {
            self.error = "خطأ في حفظ الطلب: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func fetchOrders() async {
        isLoading = true
        do {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "Order", predicate: predicate)
            let result = try await publicDatabase.records(matching: query)
            let fetchedOrders = result.matchResults.compactMap { try? $0.1.get() }
                .map { orderFromCKRecord($0) }
            self.orders = fetchedOrders
            isLoading = false
        } catch {
            self.error = "خطأ في جلب الطلبات: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - CKRecord Conversion
    private func orderToCKRecord(_ order: Order) -> CKRecord {
        let record = CKRecord(recordType: "Order")
        record["orderNumber"] = order.orderNumber as CKRecordValue
        record["customerName"] = order.customerName as CKRecordValue
        record["products"] = order.products as NSArray
        record["paymentMethod"] = order.paymentMethod as CKRecordValue
        record["store"] = order.store as CKRecordValue
        record["city"] = order.city as CKRecordValue
        record["senderAddress"] = order.senderAddress as CKRecordValue
        record["recipientAddress"] = order.recipientAddress as CKRecordValue
        record["syncStatus"] = order.syncStatus.rawValue as CKRecordValue
        return record
    }
    
    private func orderFromCKRecord(_ record: CKRecord) -> Order {
        return Order(
            id: record.recordID.recordName,
            orderNumber: record["orderNumber"] as? String ?? "",
            customerName: record["customerName"] as? String ?? "",
            products: record["products"] as? [String] ?? [],
            paymentMethod: record["paymentMethod"] as? String ?? "",
            store: record["store"] as? String ?? "",
            city: record["city"] as? String ?? "",
            senderAddress: record["senderAddress"] as? String ?? "",
            recipientAddress: record["recipientAddress"] as? String ?? "",
            syncStatus: Order.SyncStatus(rawValue: record["syncStatus"] as? String ?? "لم يتم الرفع") ?? .notSynced
        )
    }

    // MARK: - Delete Order from CloudKit
    func deleteOrder(_ order: Order) async {
        guard !order.id.isEmpty else { return }
        do {
            let recordID = CKRecord.ID(recordName: order.id)
            try await publicDatabase.deleteRecord(withID: recordID)
            await MainActor.run {
                self.orders.removeAll { $0.id == order.id }
            }
        } catch {
            await MainActor.run {
                self.error = "خطأ في حذف الطلب: \(error.localizedDescription)"
            }
        }
    }
} 