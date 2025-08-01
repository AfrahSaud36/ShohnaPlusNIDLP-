
import Foundation
import SwiftUI
import Combine

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = Subscription.sampleSubscriptions
    @Published var selectedSubscription: Subscription?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingPurchaseSheet = false
    @Published var showingSuccessAlert = false
    @Published var currentUserSubscription: Subscription?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSubscriptions()
        loadCurrentUserSubscription()
    }
    
    // MARK: - Public Methods
    
    func selectSubscription(_ subscription: Subscription) {
        selectedSubscription = subscription
        showingPurchaseSheet = true
    }
    
    func purchaseSubscription(_ subscription: Subscription) {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            // Simulate success
            self.currentUserSubscription = subscription
            self.isLoading = false
            self.showingPurchaseSheet = false
            self.showingSuccessAlert = true
            
            // Save to UserDefaults for persistence
            self.saveCurrentSubscription(subscription)
        }
    }
    
    func cancelSubscription() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            self.currentUserSubscription = nil
            self.isLoading = false
            
            // Remove from UserDefaults
            UserDefaults.standard.removeObject(forKey: "currentSubscription")
        }
    }
    
    func restorePurchases() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Simulate restore process
            self.loadCurrentUserSubscription()
            self.isLoading = false
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSubscriptions() {
        // In a real app, this would load from API
        subscriptions = Subscription.sampleSubscriptions
    }
    
    private func loadCurrentUserSubscription() {
        // Load from UserDefaults or API
        if let data = UserDefaults.standard.data(forKey: "currentSubscription"),
           let subscription = try? JSONDecoder().decode(Subscription.self, from: data) {
            currentUserSubscription = subscription
        }
    }
    
    private func saveCurrentSubscription(_ subscription: Subscription) {
        if let data = try? JSONEncoder().encode(subscription) {
            UserDefaults.standard.set(data, forKey: "currentSubscription")
        }
    }
    
    // MARK: - Computed Properties
    
    var hasActiveSubscription: Bool {
        return currentUserSubscription != nil
    }
    
    var activeSubscriptionName: String {
        return currentUserSubscription?.arabicName ?? "لا يوجد اشتراك"
    }
    
    var subscriptionsByPopularity: [Subscription] {
        return subscriptions.sorted { lhs, rhs in
            if lhs.isPopular && !rhs.isPopular {
                return true
            } else if !lhs.isPopular && rhs.isPopular {
                return false
            } else {
                return lhs.price < rhs.price
            }
        }
    }
    
    func getSubscriptionStatus(for subscription: Subscription) -> SubscriptionStatus {
        if let current = currentUserSubscription, current.id == subscription.id {
            return .active
        } else if hasActiveSubscription {
            return .unavailable
        } else {
            return .available
        }
    }
    
    func getDiscountedPrice(for subscription: Subscription) -> Double {
        guard let discount = subscription.discountPercentage else {
            return subscription.price
        }
        
        let discountAmount = subscription.price * (Double(discount) / 100.0)
        return subscription.price - discountAmount
    }
    
    func getFormattedDiscountedPrice(for subscription: Subscription) -> String {
        let discountedPrice = getDiscountedPrice(for: subscription)
        return String(format: "%.0f", discountedPrice)
    }
    
    // MARK: - Analytics
    
    func trackSubscriptionViewed(_ subscription: Subscription) {
        // Track analytics event
        print("Subscription viewed: \(subscription.name)")
    }
    
    func trackSubscriptionSelected(_ subscription: Subscription) {
        // Track analytics event
        print("Subscription selected: \(subscription.name)")
    }
    
    func trackPurchaseCompleted(_ subscription: Subscription) {
        // Track analytics event
        print("Purchase completed: \(subscription.name)")
    }
}

enum SubscriptionStatus {
    case available
    case active
    case unavailable
    
    var displayText: String {
        switch self {
        case .available:
            return "متاح"
        case .active:
            return "نشط"
        case .unavailable:
            return "غير متاح"
        }
    }
    
    var color: Color {
        switch self {
        case .available:
            return .blue
        case .active:
            return .green
        case .unavailable:
            return .gray
        }
    }
}

// MARK: - Extensions

extension SubscriptionViewModel {
    func getRecommendedSubscription() -> Subscription? {
        return subscriptions.first { $0.isPopular }
    }
    
    func getBasicSubscription() -> Subscription? {
        return subscriptions.min { $0.price < $1.price }
    }
    
    func getPremiumSubscription() -> Subscription? {
        return subscriptions.max { $0.price < $1.price }
    }
}
