import SwiftUI
import PassKit
import UIKit



// MARK: - Apple Pay Controller
class ApplePayController: NSObject, ObservableObject, PKPaymentAuthorizationViewControllerDelegate {
    @Published var paymentStatus: PaymentStatus = .idle
    var onPaymentCompletion: ((Bool, Double) -> Void)?
    private var currentPaymentRequest: PKPaymentRequest?
    
    func presentApplePay(amount: Double, completion: @escaping (Bool, Double) -> Void) {
        self.onPaymentCompletion = completion
        
        guard PKPaymentAuthorizationViewController.canMakePayments() else {
            completion(false, 0)
            return
        }
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.Logi.NIDLP" // Your registered merchant ID
        request.supportedNetworks = [.visa, .masterCard, .amex, .mada]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "SA"
        request.currencyCode = "SAR"
        
        let paymentItem = PKPaymentSummaryItem(
            label: "شحن محفظة شهنا",
            amount: NSDecimalNumber(value: amount)
        )
        request.paymentSummaryItems = [paymentItem]
        
        // Store the payment request
        self.currentPaymentRequest = request
        
        let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
        authorizationViewController?.delegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            // Find the topmost view controller
            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(authorizationViewController!, animated: true)
        }
    }
    
    // MARK: - PKPaymentAuthorizationViewControllerDelegate
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        // Process the payment here
        processApplePayPayment(payment: payment) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    self?.paymentStatus = .success
                } else {
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    self?.paymentStatus = .failed
                }
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) { [weak self] in
            if let completion = self?.onPaymentCompletion {
                let success = self?.paymentStatus == .success
                let amount = success ? self?.currentPaymentRequest?.paymentSummaryItems.first?.amount.doubleValue ?? 0 : 0
                completion(success, amount)
            }
        }
    }
    
    private func processApplePayPayment(payment: PKPayment, completion: @escaping (Bool) -> Void) {
        // Here you would send the payment token to your backend server
        // For now, we'll simulate a successful payment
        
        // Convert payment token to base64 for sending to server
        let paymentData = payment.token.paymentData
        let paymentString = paymentData.base64EncodedString()
        
        // Simulate API call to your payment processor
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            // In a real implementation, you would:
            // 1. Send paymentString to your server
            // 2. Your server processes with payment gateway
            // 3. Return success/failure
            
            completion(true) // Simulating success
        }
    }
}

// MARK: - Payment Status Enum
enum PaymentStatus {
    case idle
    case processing
    case success
    case failed
}

struct ChargeView: View {
    @State private var selectedAmount: Double = 100.0
    @State private var customAmount: String = ""
    @State private var showingApplePaySheet = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isProcessingPayment = false
    @StateObject private var walletManager = WalletManager()
    @StateObject private var applePayController = ApplePayController()
    @Environment(\.dismiss) var dismiss
    
    let predefinedAmounts: [Double] = [50, 100, 200, 500, 1000]
    
    var body: some View {
        ZStack {
            Color("offWhite").ignoresSafeArea()
            
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
                    .clipShape(
                        RoundedCorner(
                            radius: 40,
                            corners: [.bottomLeft, .bottomRight]
                        )
                    )
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
                        }
                        .padding(.horizontal)
                        .padding(.top, 0)
                        
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Text("الرصيد الحالي")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                            
                            Text("﷼ \(String(format: "%.2f", walletManager.currentBalance))")
                                .foregroundColor(.white)
                                .font(.system(size: 32, weight: .bold))
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: 130)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount Selection
                        VStack(alignment: .trailing, spacing: 16) {
                            Text("اختر المبلغ")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .padding(.top, 10)
                            
                            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                                ForEach(predefinedAmounts, id: \.self) { amount in
                                    AmountButton(
                                        amount: amount,
                                        isSelected: selectedAmount == amount,
                                        action: { selectedAmount = amount }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            // Custom Amount
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("أو أدخل مبلغاً مخصصاً")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Text("ريال")
                                        .foregroundColor(.gray)
                                    
                                    TextField("0", text: $customAmount)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .font(.system(size: 18, weight: .medium))
                                        .onChange(of: customAmount) { newValue in
                                            if let amount = Double(newValue), amount > 0 {
                                                selectedAmount = amount
                                            }
                                        }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Charge Button
                        VStack(spacing: 16) {
                            HStack {
                                Text("﷼ \(String(format: "%.2f", selectedAmount))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Spacer()
                                Text("المبلغ المحدد")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                Task {
                                    await processPayment()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    if isProcessingPayment {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "applelogo")
                                            .font(.system(size: 20, weight: .medium))
                                    }
                                    
                                    Text(isProcessingPayment ? "جاري المعالجة..." : "ادفع بـ Apple Pay")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
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
                                .opacity(isProcessingPayment ? 0.7 : 1.0)
                            }
                            .padding(.horizontal)
                            .disabled(selectedAmount <= 0 || isProcessingPayment)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("تم الشحن بنجاح", isPresented: $showingSuccessAlert) {
            Button("حسناً") {
                dismiss()
            }
        } message: {
            Text("تم شحن محفظتك بمبلغ ﷼ \(String(format: "%.2f", selectedAmount)) بنجاح\nالرصيد الجديد: ﷼ \(String(format: "%.2f", walletManager.currentBalance))")
        }
        .alert("فشل في الدفع", isPresented: $showingErrorAlert) {
            Button("حسناً") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            setupPaymentNotifications()
        }
        .onDisappear {
            removePaymentNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UpdateWalletBalance"))) { notification in
            if let amount = notification.object as? Double {
                walletManager.addBalance(amount)
                showingSuccessAlert = true
                selectedAmount = 100.0
                customAmount = ""
                isProcessingPayment = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowPaymentError"))) { _ in
            errorMessage = "فشل في معالجة الدفع. يرجى المحاولة مرة أخرى."
            showingErrorAlert = true
            isProcessingPayment = false
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PaymentSuccess"))) { notification in
            if let userInfo = notification.userInfo,
               let amount = userInfo["amount"] as? Double {
                walletManager.addBalance(amount)
                showingSuccessAlert = true
                selectedAmount = 100.0
                customAmount = ""
                isProcessingPayment = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PaymentFailed"))) { _ in
            errorMessage = "فشل في معالجة الدفع عبر Apple Pay. يرجى المحاولة مرة أخرى."
            showingErrorAlert = true
            isProcessingPayment = false
        }
    }
    
    private func setupPaymentNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("PaymentSuccess"),
            object: nil,
            queue: .main
        ) { notification in
            if let userInfo = notification.userInfo,
               let amount = userInfo["amount"] as? Double {
                DispatchQueue.main.async {
                    // Handle payment success
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateWalletBalance"), object: amount)
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("PaymentFailed"),
            object: nil,
            queue: .main
        ) { notification in
            DispatchQueue.main.async {
                // Handle payment failure
                NotificationCenter.default.post(name: NSNotification.Name("ShowPaymentError"), object: nil)
            }
        }
    }
    
    private func removePaymentNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("PaymentSuccess"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("PaymentFailed"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UpdateWalletBalance"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShowPaymentError"), object: nil)
    }
    
    private func processPayment() async {
        isProcessingPayment = true
        await processApplePayPayment()
    }
    
    private func processApplePayPayment() async {
        await MainActor.run {
            applePayController.presentApplePay(amount: selectedAmount) { success, amount in
                DispatchQueue.main.async {
                    if success {
                        // Post success notification
                        NotificationCenter.default.post(
                            name: NSNotification.Name("PaymentSuccess"),
                            object: nil,
                            userInfo: ["amount": amount]
                        )
                    } else {
                        // Post failure notification
                        NotificationCenter.default.post(
                            name: NSNotification.Name("PaymentFailed"),
                            object: nil,
                            userInfo: ["error": "Apple Pay payment failed"]
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Payment Method Enum
enum PaymentMethod: CaseIterable {
    case applePay
    
    var title: String {
        switch self {
        case .applePay:
            return "Apple Pay"
        }
    }
    
    var icon: String {
        switch self {
        case .applePay:
            return "applelogo"
        }
    }
    
    var description: String {
        switch self {
        case .applePay:
            return "ادفع بسهولة وأمان"
        }
    }
}

// MARK: - Amount Button
struct AmountButton: View {
    let amount: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("﷼ \(String(format: "%.0f", amount))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .black)
                
                Text("ريال سعودي")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? 
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "3A1C71"),
                                Color(hex: "6A1B9A")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : 
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "6A1B9A").opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}

#Preview {
    ChargeView()
} 
