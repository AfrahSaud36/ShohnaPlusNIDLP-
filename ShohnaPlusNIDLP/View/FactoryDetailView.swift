import SwiftUI

struct FactoryDetailView: View {
    let factory: Factory
    @Environment(\.dismiss) var dismiss
    @StateObject private var cartManager = ProductCartManager()
    @State private var selectedCategory = "الكل"
    @State private var products: [Product] = []
    @State private var showCart = false
    
    let productCategories = ["الكل", "منتجات أساسية", "أدوات", "مواد خام", "مكونات"]
    
    var filteredProducts: [Product] {
        if selectedCategory == "الكل" {
            return products
        } else {
            return products.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Purple Header Card
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "3A1C71"), Color(hex: "6A1B9A")]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 120)
                    
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("رجوع")
                        
                        Spacer()
                        
                        Button(action: { showCart = true }) {
                            ZStack {
                                Image(systemName: "cart")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                                
                                if cartManager.totalItems > 0 {
                                    Text("\(cartManager.totalItems)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 18, height: 18)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 14, y: -14)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                }
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(productCategories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedCategory == category ? .white : Color(hex: "3A1C71"))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(selectedCategory == category ? Color(hex: "3A1C71") : Color(hex: "F0F0F0"))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)
                .padding(.bottom, 12)
                
                // Products List
                if filteredProducts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("لا توجد منتجات")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("لم يتم العثور على منتجات في هذه الفئة")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 50)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredProducts) { product in
                            ProductCard(product: product, cartManager: cartManager)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(hex: "F9F9F9"))
        .navigationBarHidden(true)
        .onAppear {
            loadProducts()
        }
        .sheet(isPresented: $showCart) {
            ProductCartView(cartManager: cartManager)
        }
    }
    
    private func loadProducts() {
        // Sample products data for the factory
        products = [
            Product(
                id: "p1",
                name: "مواد خام أساسية",
                description: "مواد خام عالية الجودة للاستخدام الصناعي",
                price: 150.0,
                imageName: "box.fill",
                category: "مواد خام",
                factoryId: factory.id,
                isAvailable: true,
                stockQuantity: 50
            ),
            Product(
                id: "p2",
                name: "أدوات التصنيع",
                description: "أدوات متخصصة للإنتاج والتصنيع",
                price: 350.0,
                imageName: "wrench.and.screwdriver.fill",
                category: "أدوات",
                factoryId: factory.id,
                isAvailable: true,
                stockQuantity: 25
            ),
            Product(
                id: "p3",
                name: "منتج نهائي A",
                description: "منتج جاهز للاستخدام والتوزيع",
                price: 250.0,
                imageName: "shippingbox.fill",
                category: "منتجات أساسية",
                factoryId: factory.id,
                isAvailable: true,
                stockQuantity: 100
            ),
            Product(
                id: "p4",
                name: "مكونات إلكترونية",
                description: "مكونات إلكترونية متقدمة للأجهزة",
                price: 450.0,
                imageName: "cpu.fill",
                category: "مكونات",
                factoryId: factory.id,
                isAvailable: false,
                stockQuantity: 0
            ),
            Product(
                id: "p5",
                name: "منتج نهائي B",
                description: "منتج متطور بتقنية حديثة",
                price: 500.0,
                imageName: "gearshape.fill",
                category: "منتجات أساسية",
                factoryId: factory.id,
                isAvailable: true,
                stockQuantity: 30
            ),
            Product(
                id: "p6",
                name: "أدوات القياس",
                description: "أدوات دقيقة لقياس المواصفات",
                price: 200.0,
                imageName: "ruler.fill",
                category: "أدوات",
                factoryId: factory.id,
                isAvailable: true,
                stockQuantity: 40
            )
        ]
    }
}

// MARK: - Product Card Component
struct ProductCard: View {
    let product: Product
    @ObservedObject var cartManager: ProductCartManager
    @State private var quantity = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Product Image
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "F0F0F0"))
                    .frame(height: 120)
                
                Image(systemName: product.imageName)
                    .font(.system(size: 30))
                    .foregroundColor(Color(hex: "3A1C71"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if !product.isAvailable {
                    Text("غير متوفر")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(product.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(product.formattedPrice)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "3A1C71"))
                    .padding(.top, 4)
            }
            
            if product.isAvailable {
                HStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Button(action: {
                            if quantity > 1 { quantity -= 1 }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: 28, height: 28)
                                .background(Color(hex: "F0F0F0"))
                                .clipShape(Circle())
                        }
                        
                        Text("\(quantity)")
                            .font(.system(size: 14, weight: .medium))
                        
                        Button(action: {
                            if quantity < product.stockQuantity { quantity += 1 }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Color(hex: "3A1C71"))
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        cartManager.addItem(product, quantity: quantity)
                        quantity = 1
                    }) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color(hex: "3A1C71"))
                            .cornerRadius(8)
                    }
                }
            } else {
                Text("غير متوفر حالياً")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Cart View
struct ProductCartView: View {
    @ObservedObject var cartManager: ProductCartManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if cartManager.items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("السلة فارغة")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("أضف منتجات إلى السلة للمتابعة")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(cartManager.items) { item in
                            ProductCartItemRow(item: item, cartManager: cartManager)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                    
                    // Total Section
                    VStack(spacing: 16) {
                        Divider()
                        
                        HStack {
                            Text("المجموع:")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(cartManager.formattedTotalPrice)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "3A1C71"))
                        }
                        
                        Button(action: {
                            // Handle checkout
                            cartManager.clearCart()
                            dismiss()
                        }) {
                            Text("إتمام الطلب")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "3A1C71"))
                                .cornerRadius(12)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("السلة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("إغلاق") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            cartManager.removeItem(cartManager.items[index])
        }
    }
}

// MARK: - Cart Item Row
struct ProductCartItemRow: View {
    let item: ProductCartItem
    @ObservedObject var cartManager: ProductCartManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "3A1C71").opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: item.product.imageName)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "3A1C71"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(item.product.formattedPrice)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Button(action: {
                        cartManager.updateQuantity(for: item, quantity: item.quantity - 1)
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    }
                    .disabled(item.quantity <= 1)
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 14, weight: .medium))
                        .frame(minWidth: 20)
                    
                    Button(action: {
                        cartManager.updateQuantity(for: item, quantity: item.quantity + 1)
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "3A1C71"))
                    }
                }
            }
            
            Spacer()
            
            Text(item.formattedTotalPrice)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "3A1C71"))
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    FactoryDetailView(factory: Factory(
        id: "1",
        name: "مصنع الرياض للصناعات",
        location: "الرياض",
        category: "صناعة",
        description: "مصنع متخصص في إنتاج المواد الصناعية عالية الجودة ويخدم السوق المحلي والإقليمي",
        capacity: "1000 وحدة/يوم",
        contact: "+966 11 123 4567",
        isActive: true
    ))
} 
