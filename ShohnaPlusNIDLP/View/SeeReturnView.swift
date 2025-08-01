import SwiftUI

struct SeeReturnView: View {
    @EnvironmentObject var returnDataModel: ReturnDataModel
    @State private var searchText = ""
    @State private var selectedFilter = "الكل"
    @State private var isShowingNewAddView = false
    @Environment(\.dismiss) var dismiss
    
    let filterOptions = ["الكل", "قيد المعالجة", "المرفوضة"]
    
    var filteredItems: [ReturnInformation] {
        let filteredByStatus = returnDataModel.returnItems.filter {
            switch selectedFilter {
            case "قيد المعالجة": return $0.status == "Processing" || $0.status == "جيد"
            case "المرفوضة": return $0.status == "Rejected" || $0.status == "سيء"
            default: return true
            }
        }
        if searchText.isEmpty {
            return filteredByStatus
        } else {
            return filteredByStatus.filter { item in
                item.orderNumber.localizedCaseInsensitiveContains(searchText) ||
                item.origin.localizedCaseInsensitiveContains(searchText) ||
                item.destination.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Purple Background
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
                            
                            Text("الرجيع")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                isShowingNewAddView = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                    
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "3A1C71").opacity(0.7))
                            
                            TextField("البحث في الطلبات", text: $searchText)
                                .textFieldStyle(.plain)
                                .foregroundColor(Color(hex: "3A1C71"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .frame(height: 110)
                
                // Filter Buttons (Outside Purple Box)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterOptions, id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                            }) {
                                Text(filter)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedFilter == filter ? .white : Color(hex: "3A1C71"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedFilter == filter ? Color(hex: "3A1C71") : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                // Content List
                if filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("لا توجد طلبات")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("لم يتم العثور على طلبات مطابقة للبحث")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                ReturnItemCard(item: item)
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
        }
        .sheet(isPresented: $isShowingNewAddView) {
            NewAddView().environmentObject(returnDataModel)
        }
    }
}

// MARK: - ReturnItemCard
struct ReturnItemCard: View {
    let item: ReturnInformation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.orderNumber)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("\(item.origin) → \(item.destination)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                StatusBadge(status: getStatusText())
            }
            
            // Details Grid
            VStack(spacing: 12) {
                HStack {
                    DetailRow(title: "الوزن", value: item.weight)
                    Spacer()
                    DetailRow(title: "وقت الإرجاع", value: item.returnTime)
                }
                
                HStack {
                    DetailRow(title: "تاريخ الطلب", value: formatDate(item.orderDate))
                    Spacer()
                    if hasAIAnalysis() {
                        AIAnalysisBadge(item: item)
                    }
                }
            }
            
            // AI Analysis Section (if available)
            if hasAIAnalysis() {
                Divider()
                    .padding(.vertical, 4)
                
                AIAnalysisCard(item: item)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "3A1C71"),
                    Color(hex: "6A1B9A")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func getStatusText() -> String {
        if let status = item.aiAnalysisResult {
            switch status {
            case "جيد":
                return "جيد"
            case "سيء":
                return "سيء"
            default:
                return "قيد التحليل"
            }
        }
        return "في انتظار التحليل"
    }
    
    private func hasAIAnalysis() -> Bool {
        return item.aiAnalysisResult != nil
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ar_SA")
        return formatter.string(from: date)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(statusColor.opacity(0.1))
            )
    }
    
    private var statusColor: Color {
        switch status {
        case "جيد":
            return .green
        case "سيء":
            return .red
        case "قيد التحليل":
            return .orange
        default:
            return .gray
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

// MARK: - AI Analysis Badge
struct AIAnalysisBadge: View {
    let item: ReturnInformation
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 12))
                .foregroundColor(.white)
            
            Text("تحليل ذكي")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.2))
        )
    }
}

// MARK: - AI Analysis Card
struct AIAnalysisCard: View {
    let item: ReturnInformation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text("نتيجة التحليل الذكي")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if item.aiAnalysisResult == "جيد" || item.aiAnalysisResult == "سيء" {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        
                        Text("مكتمل")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("التقييم")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(getAnalysisText())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(getAnalysisColor())
                }
                
                Spacer()
                
                if item.aiAnalysisResult == "جيد" || item.aiAnalysisResult == "سيء" {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("الدقة")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("95%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func getAnalysisText() -> String {
        if let status = item.aiAnalysisResult {
            switch status {
            case "جيد":
                return "حالة ممتازة للشحنة"
            case "سيء":
                return "يحتاج إلى مراجعة"
            default:
                return "جاري المعالجة..."
            }
        }
        return "في انتظار التحليل..."
    }
    
    private func getAnalysisColor() -> Color {
        if let status = item.aiAnalysisResult {
            switch status {
            case "جيد":
                return .green
            case "سيء":
                return .red
            default:
                return .orange
            }
        }
        return .gray
    }
}

#Preview {
    SeeReturnView()
        .environmentObject(ReturnDataModel())
}



