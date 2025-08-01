
import Foundation

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageName: String
    let category: String
    let factoryId: String
    let isAvailable: Bool
    let stockQuantity: Int
    
    var formattedPrice: String {
        return String(format: "%.2f ريال", price)
    }
}

// MARK: - Product Cart Item
struct ProductCartItem: Identifiable, Codable {
    let id = UUID()
    let product: Product
    var quantity: Int
    
    var totalPrice: Double {
        return product.price * Double(quantity)
    }
    
    var formattedTotalPrice: String {
        return String(format: "%.2f ريال", totalPrice)
    }
}

// MARK: - Product Cart Manager
class ProductCartManager: ObservableObject {
    @Published var items: [ProductCartItem] = []
    
    var totalItems: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var formattedTotalPrice: String {
        return String(format: "%.2f ريال", totalPrice)
    }
    
    func addItem(_ product: Product, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(ProductCartItem(product: product, quantity: quantity))
        }
    }
    
    func removeItem(_ item: ProductCartItem) {
        items.removeAll { $0.id == item.id }
    }
    
    func updateQuantity(for item: ProductCartItem, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        }
    }
    
    func clearCart() {
        items.removeAll()
    }
} 
