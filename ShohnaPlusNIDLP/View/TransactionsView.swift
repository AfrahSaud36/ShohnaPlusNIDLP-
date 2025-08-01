import SwiftUI

struct TransactionsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedFilter = "الكل"
    @State private var transactions: [Transaction] = []
    
    let filterOptions = ["الكل", "شحن", "دفع", "إرجاع"]
    
    var filteredTransactions: [Transaction] {
        if selectedFilter == "الكل" {
            return transactions
        }
        return transactions.filter { $0.type == selectedFilter }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
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
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Text("العمليات")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Empty space for balance
                            Color.clear.frame(width: 20)
                        }
                        .padding(.horizontal)
                        .padding(.top, 50)
                    }
                }
                .frame(height: 120)
                
                // Filter Tabs
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
                
                // Transactions List
                if filteredTransactions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("لا توجد عمليات")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("لم يتم العثور على عمليات مالية")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredTransactions) { transaction in
                                TransactionCard(transaction: transaction)
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
            .onAppear {
                loadTransactions()
            }
        }
    }
    
    private func loadTransactions() {
        // Sample transaction data
        transactions = [
            Transaction(id: "1", type: "شحن", amount: 500.00, date: Date(), description: "شحن المحفظة"),
            Transaction(id: "2", type: "دفع", amount: -150.00, date: Date().addingTimeInterval(-3600), description: "دفع رسوم شحنة"),
            Transaction(id: "3", type: "إرجاع", amount: 75.00, date: Date().addingTimeInterval(-7200), description: "إرجاع مبلغ")
        ]
    }
}

// MARK: - Transaction Model
struct Transaction: Identifiable, Codable {
    let id: String
    let type: String
    let amount: Double
    let date: Date
    let description: String
}

// MARK: - Transaction Card
struct TransactionCard: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Transaction Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(iconBackgroundColor)
            }
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text("\(transaction.amount > 0 ? "+" : "")﷼ \(String(format: "%.2f", transaction.amount))")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(transaction.amount > 0 ? .green : .red)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    private var iconName: String {
        switch transaction.type {
        case "شحن":
            return "plus.circle"
        case "دفع":
            return "minus.circle"
        case "إرجاع":
            return "arrow.uturn.backward.circle"
        default:
            return "doc.circle"
        }
    }
    
    private var iconBackgroundColor: Color {
        switch transaction.type {
        case "شحن":
            return .green
        case "دفع":
            return .red
        case "إرجاع":
            return .orange
        default:
            return .gray
        }
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
    TransactionsView()
} 
