import SwiftUI

struct FactoriesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory = "الكل"
    @State private var searchText = ""
    @State private var factories: [Factory] = []
    
    let categories = ["الكل", "صناعة", "تجميع", "تعبئة"]
    
    var filteredFactories: [Factory] {
        var result = factories
        
        // Filter by category
        if selectedCategory != "الكل" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { 
                $0.name.contains(searchText) || 
                $0.location.contains(searchText) ||
                $0.description.contains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with integrated search
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
                            .accessibilityLabel("رجوع")
                            
                            Spacer()
                            
                            Text("المصانع")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Empty space for balance
                            Color.clear.frame(width: 30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "3A1C71").opacity(0.7))
                            
                            TextField("البحث في المصانع...", text: $searchText)
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
                .frame(height: 120)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Spacer()
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedCategory == category ? .white : Color(hex: "3A1C71"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedCategory == category ? Color(hex: "3A1C71") : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                
                // Factories List
                if filteredFactories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "building.2")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("لا توجد مصانع")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("لم يتم العثور على مصانع في هذه الفئة")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredFactories) { factory in
                                NavigationLink(destination: FactoryDetailView(factory: factory).navigationBarBackButtonHidden(true)) {
                                    HungerStationFactoryCard(factory: factory)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                loadFactories()
            }
        }
    }
    
    private func loadFactories() {
        // Sample factory data
        factories = [
            Factory(
                id: "1",
                name: "مصنع الرياض للصناعات",
                location: "الرياض",
                category: "صناعة",
                description: "مصنع متخصص في إنتاج المواد الصناعية",
                capacity: "1000 وحدة/يوم",
                contact: "+966 11 123 4567",
                isActive: true
            ),
            Factory(
                id: "2",
                name: "مصنع جدة للتجميع",
                location: "جدة",
                category: "تجميع",
                description: "مصنع متخصص في تجميع المنتجات الإلكترونية",
                capacity: "500 وحدة/يوم",
                contact: "+966 12 234 5678",
                isActive: true
            ),
            Factory(
                id: "3",
                name: "مصنع الدمام للتعبئة",
                location: "الدمام",
                category: "تعبئة",
                description: "مصنع متخصص في تعبئة وتغليف المنتجات",
                capacity: "2000 وحدة/يوم",
                contact: "+966 13 345 6789",
                isActive: false
            ),
            Factory(
                id: "4",
                name: "مصنع النادة للبلاستيك",
                location: "الرياض",
                category: "صناعة",
                description: "إنتاج منتجات بلاستيكية عالية الجودة",
                capacity: "1500 وحدة/يوم",
                contact: "+966 11 987 6543",
                isActive: true
            ),
            Factory(
                id: "5",
                name: "مصنع خلدون للمواد الغذائية",
                location: "مكة المكرمة",
                category: "تعبئة",
                description: "تعبئة وتغليف المواد الغذائية",
                capacity: "3000 وحدة/يوم",
                contact: "+966 12 456 7890",
                isActive: true
            ),
            Factory(
                id: "6",
                name: "مصنع ترانزيت للنقل",
                location: "جدة",
                category: "تجميع",
                description: "تجميع قطع غيار السيارات والنقل",
                capacity: "800 وحدة/يوم",
                contact: "+966 12 111 2222",
                isActive: true
            ),
            Factory(
                id: "7",
                name: "مصنع شهير للمنسوجات",
                location: "القصيم",
                category: "صناعة",
                description: "إنتاج الأقمشة والمنسوجات",
                capacity: "1200 وحدة/يوم",
                contact: "+966 16 333 4444",
                isActive: false
            ),
            Factory(
                id: "8",
                name: "مصنع ديمة للكيماويات",
                location: "الجبيل",
                category: "صناعة",
                description: "إنتاج المواد الكيماوية الصناعية",
                capacity: "2500 وحدة/يوم",
                contact: "+966 13 555 6666",
                isActive: true
            ),
            Factory(
                id: "9",
                name: "مصنع المدينة المتقدم",
                location: "المدينة المنورة",
                category: "تجميع",
                description: "تجميع الأجهزة الإلكترونية المتقدمة",
                capacity: "600 وحدة/يوم",
                contact: "+966 14 777 8888",
                isActive: true
            ),
            Factory(
                id: "10",
                name: "مصنع قلفة للمعادن",
                location: "الطائف",
                category: "صناعة",
                description: "تشكيل وتصنيع المعادن",
                capacity: "900 وحدة/يوم",
                contact: "+966 12 999 0000",
                isActive: true
            ),
            Factory(
                id: "11",
                name: "مصنع الخبر للتعبئة",
                location: "الخبر",
                category: "تعبئة",
                description: "تعبئة المنتجات الاستهلاكية",
                capacity: "1800 وحدة/يوم",
                contact: "+966 13 123 9876",
                isActive: false
            ),
            Factory(
                id: "12",
                name: "مصنع أبها للصناعات الخشبية",
                location: "أبها",
                category: "صناعة",
                description: "تصنيع الأثاث والمنتجات الخشبية",
                capacity: "700 وحدة/يوم",
                contact: "+966 17 246 8135",
                isActive: true
            ),
            Factory(
                id: "13",
                name: "مصنع حائل للتجميع المتطور",
                location: "حائل",
                category: "تجميع",
                description: "تجميع المعدات الصناعية المتطورة",
                capacity: "400 وحدة/يوم",
                contact: "+966 16 369 2580",
                isActive: true
            )
        ]
    }
}

// MARK: - Factory Model
struct Factory: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let category: String
    let description: String
    let capacity: String
    let contact: String
    let isActive: Bool
}

// MARK: - Simplified Factory Card
struct HungerStationFactoryCard: View {
    let factory: Factory
    
    var body: some View {
        HStack(spacing: 12) {
            // Arrow (Left side)
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            // Factory Info (Right side)
            VStack(alignment: .trailing, spacing: 6) {
                HStack {
                    // Status Badge
                    Text(factory.isActive ? "نشط" : "غير نشط")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(factory.isActive ? Color.green : Color.red)
                        )
                    
                    Spacer()
                    
                    Text(factory.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                // Location and Category
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text(factory.category)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Image(systemName: "tag.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Text(factory.location)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Capacity
                HStack(spacing: 4) {
                    Text(factory.capacity)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Image(systemName: "speedometer")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            // Factory Image/Icon (Right side)
            ZStack {
                Circle()
                    .fill(Color(hex: "3A1C71").opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "3A1C71"))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Statistics Card Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        FactoriesView()
    }
} 
