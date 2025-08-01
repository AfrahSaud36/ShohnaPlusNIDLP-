import SwiftUI

struct SuppliesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCategory = "الكل"
    @StateObject private var suppliesManager = SuppliesManager()
    @State private var showingSupplyDetail = false
    @State private var selectedSupply: Supply?
    
    let categories = ["الكل", "مستلزمات مكتبية", "مواد التعبئة", "أنظمة الدفع", "أثاث تجاري", "لوازم أمنية", "أدوات تنظيف"]
    
    var filteredSupplies: [Supply] {
        let categoryFiltered = selectedCategory == "الكل" ? suppliesManager.supplies : suppliesManager.supplies.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { supply in
                supply.name.localizedCaseInsensitiveContains(searchText) ||
                supply.description.localizedCaseInsensitiveContains(searchText)
            }
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
                            
                      
                            
                            Spacer()
                            
                            Button {
                                // Shopping cart
                            } label: {
                                ZStack {
                                    Image(systemName: "cart")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    if suppliesManager.cartItems.count > 0 {
                                        Text("\(suppliesManager.cartItems.count)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .offset(x: 8, y: -8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "3A1C71").opacity(0.7))
                            
                            TextField("البحث في المستلزمات", text: $searchText)
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
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedCategory == category ? .white : Color(hex: "3A1C71"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedCategory == category ? Color(hex: "3A1C71") : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                // Supplies List
                if filteredSupplies.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("لا توجد مستلزمات")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("لم يتم العثور على مستلزمات مطابقة للبحث")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(filteredSupplies) { supply in
                                SupplyCard(supply: supply, suppliesManager: suppliesManager)
                                    .onTapGesture {
                                        selectedSupply = supply
                                        showingSupplyDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .background(Color(.systemBackground))
                }
                
                // Cart Summary
                if suppliesManager.cartItems.count > 0 {
                    CartSummaryBar(suppliesManager: suppliesManager)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSupplyDetail) {
                if let supply = selectedSupply {
                    SupplyDetailView(supply: supply, suppliesManager: suppliesManager)
                }
            }
        }
    }
}

// MARK: - Supply Model
struct Supply: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let image: String
    let category: String
    let brand: String
    let specifications: [String]
    let inStock: Bool
    let minQuantity: Int
    let maxQuantity: Int
    
    init(id: String, name: String, description: String, price: Double, image: String, category: String, brand: String, specifications: [String], inStock: Bool = true, minQuantity: Int = 1, maxQuantity: Int = 100) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.image = image
        self.category = category
        self.brand = brand
        self.specifications = specifications
        self.inStock = inStock
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
    }
}

// MARK: - Cart Item
struct CartItem: Identifiable, Codable {
    let id = UUID()
    let supply: Supply
    var quantity: Int
    
    var totalPrice: Double {
        supply.price * Double(quantity)
    }
}

// MARK: - Supplies Manager
class SuppliesManager: ObservableObject {
    @Published var supplies: [Supply] = []
    @Published var cartItems: [CartItem] = []
    
    var totalCartPrice: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var totalCartItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    init() {
        loadSupplies()
    }
    
    func addToCart(_ supply: Supply, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.supply.id == supply.id }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append(CartItem(supply: supply, quantity: quantity))
        }
    }
    
    func removeFromCart(_ supply: Supply) {
        cartItems.removeAll { $0.supply.id == supply.id }
    }
    
    func updateQuantity(_ supply: Supply, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.supply.id == supply.id }) {
            if quantity <= 0 {
                cartItems.remove(at: index)
            } else {
                cartItems[index].quantity = quantity
            }
        }
    }
    
    func getCartQuantity(for supply: Supply) -> Int {
        cartItems.first(where: { $0.supply.id == supply.id })?.quantity ?? 0
    }
    
    private func loadSupplies() {
        supplies = [
            // مستلزمات مكتبية
            Supply(id: "1", name: "آلة طباعة حرارية", description: "آلة طباعة حرارية للفواتير والإيصالات", price: 450.00, image: "Icon2", category: "مستلزمات مكتبية", brand: "Epson", specifications: ["طباعة حرارية", "سرعة عالية", "اتصال USB", "ضمان سنة"]),
            Supply(id: "2", name: "ماسح الباركود", description: "ماسح باركود لاسلكي عالي الدقة", price: 280.00, image: "Icon3", category: "مستلزمات مكتبية", brand: "Honeywell", specifications: ["لاسلكي", "مدى 100 متر", "بطارية طويلة المدى", "دقة عالية"]),
            Supply(id: "3", name: "ورق طباعة حراري", description: "لفات ورق طباعة حراري 80مم", price: 25.00, image: "Icon4", category: "مستلزمات مكتبية", brand: "Universal", specifications: ["عرض 80مم", "طول 50 متر", "جودة عالية", "مقاوم للبهتان"]),
            Supply(id: "4", name: "آلة حاسبة تجارية", description: "آلة حاسبة تجارية مع طباعة", price: 150.00, image: "Icon5", category: "مستلزمات مكتبية", brand: "Casio", specifications: ["طباعة الحسابات", "ذاكرة كبيرة", "عرض واضح", "متينة"]),
            
            // مواد التعبئة
            Supply(id: "5", name: "أكياس بلاستيكية", description: "أكياس بلاستيكية للتسوق مقاسات مختلفة", price: 35.00, image: "Icon2", category: "مواد التعبئة", brand: "EcoPack", specifications: ["مقاومة للتمزق", "صديقة للبيئة", "مقاسات متعددة", "1000 قطعة"]),
            Supply(id: "6", name: "صناديق كرتون", description: "صناديق كرتون للشحن والتخزين", price: 45.00, image: "Icon3", category: "مواد التعبئة", brand: "PackPro", specifications: ["مقاومة للرطوبة", "مقاسات مختلفة", "جودة عالية", "50 قطعة"]),
            Supply(id: "7", name: "شريط لاصق للتعبئة", description: "شريط لاصق شفاف للتعبئة والشحن", price: 15.00, image: "Icon4", category: "مواد التعبئة", brand: "TapeFix", specifications: ["لاصق قوي", "مقاوم للماء", "عرض 5 سم", "100 متر"]),
            Supply(id: "8", name: "فقاعات الحماية", description: "فقاعات هوائية لحماية البضائع", price: 60.00, image: "Icon5", category: "مواد التعبئة", brand: "BubbleWrap", specifications: ["حماية فائقة", "خفيف الوزن", "عرض 1 متر", "50 متر"]),
            
            // أنظمة الدفع
            Supply(id: "9", name: "جهاز نقاط البيع", description: "جهاز نقاط البيع متكامل مع شاشة لمس", price: 1200.00, image: "Icon2", category: "أنظمة الدفع", brand: "Square", specifications: ["شاشة لمس", "قارئ بطاقات", "طابعة مدمجة", "واي فاي"]),
            Supply(id: "10", name: "قارئ البطاقات", description: "قارئ بطاقات ائتمان محمول", price: 180.00, image: "Icon3", category: "أنظمة الدفع", brand: "PayPal", specifications: ["محمول", "بلوتوث", "بطارية طويلة", "آمن"]),
            Supply(id: "11", name: "درج النقود", description: "درج نقود إلكتروني للكاشير", price: 320.00, image: "Icon4", category: "أنظمة الدفع", brand: "CashDrawer", specifications: ["فتح إلكتروني", "5 أقسام للعملات", "قفل آمن", "متين"]),
            Supply(id: "12", name: "شاشة عرض للعملاء", description: "شاشة عرض السعر للعملاء", price: 250.00, image: "Icon5", category: "أنظمة الدفع", brand: "DisplayPro", specifications: ["عرض واضح", "أرقام كبيرة", "LED", "سهولة التركيب"]),
            
            // أثاث تجاري
            Supply(id: "13", name: "رفوف عرض معدنية", description: "رفوف عرض معدنية قابلة للتعديل", price: 380.00, image: "Icon2", category: "أثاث تجاري", brand: "MetalShelf", specifications: ["قابلة للتعديل", "مقاومة للصدأ", "حمولة عالية", "سهولة التركيب"]),
            Supply(id: "14", name: "كاونتر استقبال", description: "كاونتر استقبال عصري للمحلات", price: 850.00, image: "Icon3", category: "أثاث تجاري", brand: "ModernDesk", specifications: ["تصميم عصري", "مساحة تخزين", "خشب عالي الجودة", "لون أبيض"]),
            Supply(id: "15", name: "كراسي انتظار", description: "كراسي انتظار مريحة للعملاء", price: 220.00, image: "Icon4", category: "أثاث تجاري", brand: "ComfortSeat", specifications: ["مريحة", "مقاومة للبقع", "تصميم أنيق", "متينة"]),
            Supply(id: "16", name: "خزانة تخزين", description: "خزانة تخزين للمستندات والمعدات", price: 450.00, image: "Icon5", category: "أثاث تجاري", brand: "StoragePro", specifications: ["مساحة كبيرة", "أقفال آمنة", "أدراج متعددة", "معدن قوي"]),
            
            // لوازم أمنية
            Supply(id: "17", name: "كاميرا مراقبة", description: "كاميرا مراقبة عالية الدقة للمحلات", price: 320.00, image: "Icon2", category: "لوازم أمنية", brand: "SecureCam", specifications: ["دقة 4K", "رؤية ليلية", "تسجيل سحابي", "تنبيهات ذكية"]),
            Supply(id: "18", name: "جهاز إنذار", description: "جهاز إنذار ضد السرقة", price: 180.00, image: "Icon3", category: "لوازم أمنية", brand: "AlarmTech", specifications: ["حساسات متعددة", "تنبيه صوتي", "تحكم عن بعد", "بطارية احتياطية"]),
            Supply(id: "19", name: "خزنة أمان", description: "خزنة أمان للنقود والمستندات", price: 650.00, image: "Icon4", category: "لوازم أمنية", brand: "SafeBox", specifications: ["قفل رقمي", "مقاومة للحريق", "مساحة كبيرة", "تثبيت أرضي"]),
            Supply(id: "20", name: "بوابة أمنية", description: "بوابة أمنية للكشف عن المعادن", price: 1200.00, image: "Icon5", category: "لوازم أمنية", brand: "MetalDetect", specifications: ["كشف دقيق", "تنبيه صوتي", "سهولة التركيب", "تحكم في الحساسية"]),
            
            // أدوات تنظيف
            Supply(id: "21", name: "مكنسة كهربائية تجارية", description: "مكنسة كهربائية قوية للمحلات", price: 420.00, image: "Icon2", category: "أدوات تنظيف", brand: "CleanPro", specifications: ["قوة شفط عالية", "فلاتر قابلة للغسل", "خزان كبير", "عجلات متحركة"]),
            Supply(id: "22", name: "مواد تنظيف متعددة", description: "مجموعة مواد تنظيف للأرضيات والأسطح", price: 85.00, image: "Icon3", category: "أدوات تنظيف", brand: "CleanAll", specifications: ["آمنة للاستخدام", "رائحة منعشة", "فعالة ضد البكتيريا", "عبوات متعددة"]),
            Supply(id: "23", name: "ممسحة احترافية", description: "ممسحة احترافية للأرضيات", price: 45.00, image: "Icon4", category: "أدوات تنظيف", brand: "MopMaster", specifications: ["ألياف عالية الجودة", "مقبض قابل للتعديل", "سهولة الاستخدام", "قابلة للغسل"]),
            Supply(id: "24", name: "معقم اليدين", description: "معقم اليدين للعملاء والموظفين", price: 35.00, image: "Icon5", category: "أدوات تنظيف", brand: "HandClean", specifications: ["كحول 70%", "رائحة منعشة", "سريع الجفاف", "عبوة 5 لتر"])
        ]
    }
}

// MARK: - Supply Card
struct SupplyCard: View {
    let supply: Supply
    @ObservedObject var suppliesManager: SuppliesManager
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Supply Image
            Image(supply.image)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .cornerRadius(8)
            
            // Supply Info
            VStack(alignment: .trailing, spacing: 4) {
                Text(supply.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                
                Text(supply.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                
                HStack {
                    if !supply.inStock {
                        Text("غيرب متوفر")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Text("﷼ \(String(format: "%.2f", supply.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "3A1C71"))
                }
            }
            
            // Add to Cart Button
            Button {
                if suppliesManager.getCartQuantity(for: supply) > 0 {
                    suppliesManager.removeFromCart(supply)
                } else {
                    suppliesManager.addToCart(supply)
                }
            } label: {
                HStack {
                    Image(systemName: suppliesManager.getCartQuantity(for: supply) > 0 ? "checkmark" : "plus")
                        .font(.caption)
                    Text(suppliesManager.getCartQuantity(for: supply) > 0 ? "في السلة" : "إضافة")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(suppliesManager.getCartQuantity(for: supply) > 0 ? Color.green : Color(hex: "3A1C71"))
                )
            }
            .disabled(!supply.inStock)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - Cart Summary Bar
struct CartSummaryBar: View {
    @ObservedObject var suppliesManager: SuppliesManager
    
    var body: some View {
        HStack {
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(suppliesManager.totalCartItems) عنصر")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("﷼ \(String(format: "%.2f", suppliesManager.totalCartPrice))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button {
                // Checkout action
            } label: {
                Text("إتمام الطلب")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(25)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "3A1C71"),
                    Color(hex: "6A1B9A")
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

#Preview {
    SuppliesView()
} 
