import SwiftUI

struct OrdersManagementView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var serviceManager: ServiceManager
    @State private var selectedTab = "الكل"
    @State private var showingCompletionAlert = false
    @State private var orderToComplete: ServiceRequest?
    
    let tabs = ["الكل", "معلقة", "مكتملة"]
    
    var filteredOrders: [ServiceRequest] {
        switch selectedTab {
        case "معلقة":
            return serviceManager.requests.filter { !$0.isCompleted }
        case "مكتملة":
            return serviceManager.requests.filter { $0.isCompleted }
        default:
            return serviceManager.requests
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "3A1C71"),
                            Color(hex: "6A1B9A")
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Text("إدارة الطلبات")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Orders count badge
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Text("\(serviceManager.totalRequests)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                        
                        // Summary Info
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("إجمالي الطلبات")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(serviceManager.totalRequests)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 4) {
                                Text("القيمة الإجمالية")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("﷼ \(String(format: "%.2f", serviceManager.totalPrice))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .frame(height: 140)
                
                // Tab Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tabs, id: \.self) { tab in
                            Button(action: {
                                selectedTab = tab
                            }) {
                                Text(tab)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedTab == tab ? .white : Color(hex: "3A1C71"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedTab == tab ? Color(hex: "3A1C71") : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                // Orders List
                if filteredOrders.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("لا توجد طلبات")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("لم يتم العثور على طلبات في هذه الفئة")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredOrders) { order in
                                                                 ServiceRequestCard(
                                     order: order,
                                     serviceManager: serviceManager,
                                     onComplete: {
                                         orderToComplete = order
                                         showingCompletionAlert = true
                                     },
                                     onCancel: {
                                         serviceManager.removeRequest(order.service)
                                     }
                                 )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .alert("إتمام الطلب", isPresented: $showingCompletionAlert) {
                Button("إلغاء", role: .cancel) { }
                Button("إتمام") {
                    if let order = orderToComplete {
                        serviceManager.completeOrder(order)
                    }
                }
            } message: {
                Text("هل تريد إتمام هذا الطلب؟")
            }
        }
    }
}

// MARK: - Service Request Card
struct ServiceRequestCard: View {
    let order: ServiceRequest
    @ObservedObject var serviceManager: ServiceManager
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            // Order Header
            HStack {
                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: order.isCompleted ? "checkmark.circle.fill" : "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(order.isCompleted ? .green : .orange)
                    
                    Text(order.isCompleted ? "مكتمل" : "معلق")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(order.isCompleted ? .green : .orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(order.isCompleted ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                )
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(order.service.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                    
                    Text("رقم الطلب: #\(order.id.uuidString.prefix(8))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Order Details
            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    Spacer()
                    Text(order.service.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Spacer()
                    Text("تاريخ الطلب: \(formatDate(order.requestDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let completionDate = order.completionDate {
                    HStack {
                        Spacer()
                        Text("تاريخ الإتمام: \(formatDate(completionDate))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Service Features
            VStack(alignment: .trailing, spacing: 4) {
                ForEach(order.service.features.prefix(3), id: \.self) { feature in
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text(feature)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Order Actions and Price
            HStack {
                // Action Buttons
                if !order.isCompleted {
                    HStack(spacing: 8) {
                        Button {
                            onCancel()
                        } label: {
                            Text("إلغاء")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .cornerRadius(16)
                        }
                        
                        Button {
                            onComplete()
                        } label: {
                            Text("إتمام")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(16)
                        }
                    }
                } else {
                    Text("تم الإتمام")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(16)
                }
                
                Spacer()
                
                // Price and Time
                VStack(alignment: .trailing, spacing: 4) {
                    Text("﷼ \(String(format: "%.2f", order.service.price))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "3A1C71"))
                    
                    Text(order.service.estimatedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(order.isCompleted ? Color.green.opacity(0.3) : Color(.systemGray5), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ar_SA")
        return formatter.string(from: date)
    }
}

#Preview {
    let serviceManager = ServiceManager()
    // Add sample orders for preview
    let sampleService = LogisticsService(id: "1", name: "مثقاب كهربائي", description: "مثقاب كهربائي عالي الأداء", price: 250.00, image: "Icon2", category: "الأكثر طلباً", isPopular: true, estimatedTime: "24 ساعة", features: ["قوة عالية", "متعدد الاستخدامات", "ضمان سنتين"])
    serviceManager.addRequest(sampleService)
    return OrdersManagementView(serviceManager: serviceManager)
} 
