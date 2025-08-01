import SwiftUI

struct SupplyDetailView: View {
    let supply: Supply
    @ObservedObject var suppliesManager: SuppliesManager
    @Environment(\.dismiss) var dismiss
    @State private var quantity = 1
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .trailing, spacing: 20) {
                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Text("تفاصيل المنتج")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button {
                            // Share action
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Supply Image
                    Image(supply.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    
                    // Supply Info
                    VStack(alignment: .trailing, spacing: 16) {
                        // Name and Brand
                        VStack(alignment: .trailing, spacing: 8) {
                            Text(supply.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.trailing)
                            
                            Text("العلامة التجارية: \(supply.brand)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Description
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("الوصف")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(supply.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Specifications
                        VStack(alignment: .trailing, spacing: 12) {
                            Text("المواصفات")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .trailing, spacing: 8) {
                                ForEach(supply.specifications, id: \.self) { spec in
                                    HStack {
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.green)
                                        Text(spec)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        
                        // Price and Stock
                        VStack(alignment: .trailing, spacing: 8) {
                            HStack {
                                if supply.inStock {
                                    Text("متوفر")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                } else {
                                    Text("غير متوفر")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                Text("﷼ \(String(format: "%.2f", supply.price))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "3A1C71"))
                            }
                        }
                        
                        // Quantity Selector
                        if supply.inStock {
                            VStack(alignment: .trailing, spacing: 12) {
                                Text("الكمية")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Button {
                                        if quantity < supply.maxQuantity {
                                            quantity += 1
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(Color(hex: "3A1C71"))
                                            .clipShape(Circle())
                                    }
                                    .disabled(quantity >= supply.maxQuantity)
                                    
                                    Text("\(quantity)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                        .frame(minWidth: 60)
                                    
                                    Button {
                                        if quantity > supply.minQuantity {
                                            quantity -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(Color(hex: "3A1C71"))
                                            .clipShape(Circle())
                                    }
                                    .disabled(quantity <= supply.minQuantity)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Add to Cart Button
                    if supply.inStock {
                        VStack(spacing: 12) {
                            // Total Price
                            HStack {
                                Spacer()
                                Text("المجموع: ﷼ \(String(format: "%.2f", supply.price * Double(quantity)))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 20)
                            
                            // Add to Cart Button
                            Button {
                                suppliesManager.addToCart(supply, quantity: quantity)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "cart.badge.plus")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("إضافة إلى السلة")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
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
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .onAppear {
                quantity = supply.minQuantity
            }
        }
    }
}

#Preview {
    SupplyDetailView(
        supply: Supply(
            id: "1",
            name: "آلة طباعة حرارية",
            description: "آلة طباعة حرارية للفواتير والإيصالات عالية الجودة",
            price: 450.00,
            image: "Icon2",
            category: "مستلزمات مكتبية",
            brand: "Epson",
            specifications: ["طباعة حرارية", "سرعة عالية", "اتصال USB", "ضمان سنة"]
        ),
        suppliesManager: SuppliesManager()
    )
} 
