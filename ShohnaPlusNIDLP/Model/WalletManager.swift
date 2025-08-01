import SwiftUI

class WalletManager: ObservableObject {
    @Published var currentBalance: Double = 0.0
    
    init() {
        loadBalance()
    }
    
    func addBalance(_ amount: Double) {
        currentBalance += amount
        saveBalance()
    }
    
    func deductBalance(_ amount: Double) -> Bool {
        if currentBalance >= amount {
            currentBalance -= amount
            saveBalance()
            return true
        }
        return false
    }
    
    private func saveBalance() {
        UserDefaults.standard.set(currentBalance, forKey: "wallet_balance")
    }
    
    private func loadBalance() {
        currentBalance = UserDefaults.standard.double(forKey: "wallet_balance")
    }
} 
