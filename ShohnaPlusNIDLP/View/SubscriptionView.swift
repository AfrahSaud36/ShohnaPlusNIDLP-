import SwiftUI
import UIKit

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var showFooter = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F8F9FA"),
                        Color(hex: "E1E7F7")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with back button
                    headerWithBackButton
                    
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Header section
                            headerSection
                            
                            // Subscription cards - Horizontal scroll
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    ForEach(viewModel.subscriptions) { subscription in
                                        SubscriptionCard(
                                            subscription: subscription,
                                            isSelected: viewModel.selectedSubscription?.id == subscription.id
                                        ) {
                                            viewModel.selectSubscription(subscription)
                                        }
                                        .frame(width: 280) // Fixed width for horizontal scrolling
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            // Footer section
                            footerSection
                                .opacity(showFooter ? 1 : 0)
                                .offset(y: showFooter ? 0 : 30)
                                .animation(.easeOut(duration: 0.8).delay(0.3), value: showFooter)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
    
            .alert("تم الاشتراك بنجاح!", isPresented: $viewModel.showingSuccessAlert) {
                Button("حسناً") { }
            } message: {
                Text("تم تفعيل اشتراكك في باقة \(viewModel.selectedSubscription?.arabicName ?? "")")
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                    showFooter = true
                }
            }
            .alert("تنبيه", isPresented: $showAlert) {
                Button("حسناً") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Contact Methods
    private func openPhoneCall() {
        guard let url = URL(string: "tel://0506025451") else { 
            showErrorAlert("تعذر فتح تطبيق الهاتف")
            return 
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showErrorAlert("تطبيق الهاتف غير متاح على هذا الجهاز")
        }
    }
    
    private func openWhatsApp() {
        // Format: Saudi Arabia country code +966, removing first 0 from number
        let phoneNumber = "9660506025451"
        let message = "السلام عليكم، أرغب في الاستفسار عن باقات الاشتراك"
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: "https://wa.me/\(phoneNumber)?text=\(encodedMessage)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback to App Store if WhatsApp is not installed
            guard let appStoreURL = URL(string: "https://apps.apple.com/app/whatsapp-messenger/id310633997") else { return }
            UIApplication.shared.open(appStoreURL)
        }
    }
    
    private func openEmail() {
        let subject = "استفسار عن باقات الاشتراك"
        let body = "السلام عليكم،\n\nأرغب في الاستفسار عن باقات الاشتراك المتاحة.\n\nشكراً لكم"
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: "mailto:afrahsaud36@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openWhatsAppHelp() {
        // Format: Saudi Arabia country code +966, removing first 0 from number
        let phoneNumber = "9660506025451"
        let message = "السلام عليكم، أحتاج مساعدة في اختيار الباقة المناسبة لي من باقات الاشتراك المتاحة"
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: "https://wa.me/\(phoneNumber)?text=\(encodedMessage)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback to App Store if WhatsApp is not installed
            guard let appStoreURL = URL(string: "https://apps.apple.com/app/whatsapp-messenger/id310633997") else { return }
            UIApplication.shared.open(appStoreURL)
        }
    }
    
    private func showErrorAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private var headerWithBackButton: some View {
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
                
                Text("الباقات")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for balance
                Color.clear.frame(width: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 5)
        }
        .frame(height: 60)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
        ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "3A1C71"),
                                Color(hex: "6A1B9A")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "3A1C71").opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Title and description
            VStack(spacing: 8) {
                Text("اختر الباقة المناسبة لك")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("باقات مصممة خصيصاً لتلبية احتياجاتك في الشحن واللوجستيات")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var footerSection: some View {
        VStack(spacing: 24) {
            // Enhanced Features Section
            VStack(spacing: 20) {
                // Header with icon
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "3A1C71"),
                                        Color(hex: "6A1B9A")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("جميع الباقات تشمل")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("مميزات حصرية مع كل اشتراك")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Enhanced Feature Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    EnhancedFeatureCard(
                        icon: "lock.shield.fill",
                        title: "أمان متقدم",
                        description: "تشفير آمن لجميع المعاملات",
                        color: "4CAF50"
                    )
                    
                    EnhancedFeatureCard(
                        icon: "arrow.clockwise.circle.fill",
                        title: "تحديثات مجانية",
                        description: "تحديثات مستمرة ومجانية",
                        color: "2196F3"
                    )
                    
                    EnhancedFeatureCard(
                        icon: "headphones.circle.fill",
                        title: "دعم 24/7",
                        description: "دعم فني على مدار الساعة",
                        color: "FF9800"
                    )
                    
                    EnhancedFeatureCard(
                        icon: "shield.checkered.fill",
                        title: "ضمان الاسترداد",
                        description: "ضمان استرداد المال خلال 30 يوماً",
                        color: "9C27B0"
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color(hex: "3A1C71").opacity(0.1), radius: 15, x: 0, y: 8)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "3A1C71").opacity(0.2),
                                    Color(hex: "6A1B9A").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .padding(.horizontal, 16)
            
            // Enhanced Support Section
            VStack(spacing: 16) {
                // FAQ Button
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    // Open WhatsApp with help message
                    openWhatsAppHelp()
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "3A1C71"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("هل تحتاج مساعدة في الاختيار؟")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("تواصل مع فريق الدعم المختص")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "3A1C71"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "3A1C71").opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "3A1C71").opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Quick Contact Options
                HStack(spacing: 12) {
                    QuickContactButton(
                        icon: "phone.fill",
                        text: "اتصال",
                        color: "4CAF50"
                    ) {
                        openPhoneCall()
                    }
                    
                    QuickContactButton(
                        icon: "message.fill",
                        text: "واتساب",
                        color: "25D366"
                    ) {
                        openWhatsApp()
                    }
                    
                    QuickContactButton(
                        icon: "envelope.fill",
                        text: "إيميل",
                        color: "2196F3"
                    ) {
                        openEmail()
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct SubscriptionCard: View {
    let subscription: Subscription
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(
                        color: isSelected ? Color(hex: subscription.color).opacity(0.3) : Color.black.opacity(0.08),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 6 : 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color(hex: subscription.color) : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .scaleEffect(isSelected ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                
                VStack(spacing: 0) {
                    // Header section with popular badge
                    ZStack {
                        if subscription.isPopular {
                            HStack {
                                Spacer()
                                popularBadge
                                    .offset(x: -8, y: -8)
                            }
                        }
                        
                        headerContent
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    // Features section
                    featuresSection
                        .padding(.horizontal, 20)
                    
                    // Price and CTA section
                    priceSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var popularBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .bold))
            Text("الأكثر شعبية")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: subscription.color),
                            Color(hex: subscription.color).opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .shadow(color: Color(hex: subscription.color).opacity(0.4), radius: 4, x: 0, y: 2)
    }
    
    private var headerContent: some View {
        VStack(spacing: 16) {
            // Icon and discount
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: subscription.color).opacity(0.15))
                        .frame(width: 55, height: 55)
                    
                    Image(systemName: subscription.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(hex: subscription.color))
                }

                Spacer()
                
                if let discount = subscription.discountPercentage {
                    VStack(spacing: 2) {
                        Text("خصم")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                        Text("\(discount)%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                    )
                }
            }
            
            // Title and description
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(subscription.arabicName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack {
                    Text(subscription.arabicDescription)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    Spacer()
                }
            }
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(subscription.arabicFeatures.prefix(4).enumerated()), id: \.offset) { index, feature in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: subscription.color))
                    
                    Text(feature)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Spacer()
                }
            }
            
            if subscription.arabicFeatures.count > 4 {
                HStack {
                    Text("+ \(subscription.arabicFeatures.count - 4) مميزة أخرى")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: subscription.color))
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 16)
    }
    
    private var priceSection: some View {
        VStack(spacing: 16) {
            // Price
            HStack(alignment: .bottom, spacing: 6) {
                Text(subscription.formattedPrice)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(subscription.currency)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(subscription.durationText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            
            // CTA Button
            HStack {
                Text("اختيار هذه الباقة")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: subscription.color),
                        Color(hex: subscription.color).opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "3A1C71"))
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct EnhancedFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: String
    @State private var isPressed = false
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: color))
            }
            
            // Content
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: color).opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color(hex: color).opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .scaleEffect(isPressed ? 0.95 : (isVisible ? 1.0 : 0.8))
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3)), value: isVisible)
        .onTapGesture {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

struct QuickContactButton: View {
    let icon: String
    let text: String
    let color: String
    let action: () -> Void
    @State private var isPressed = false
    @State private var bounceEffect = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    action()
                }
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: color).opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: color))
                }
                
                Text(text)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: color).opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: color).opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : (bounceEffect ? 1.05 : 1.0))
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: bounceEffect)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...1.0)) {
                withAnimation {
                    bounceEffect = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        bounceEffect = false
                    }
                }
            }
        }
    }
}

struct PurchaseSheet: View {
    let subscription: Subscription
    let viewModel: SubscriptionViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: subscription.color).opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: subscription.icon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(Color(hex: subscription.color))
                    }
                    
                    Text("تأكيد الاشتراك")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("باقة \(subscription.arabicName)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Price summary
                VStack(spacing: 16) {
                    HStack {
                        Text("السعر:")
                        Spacer()
                        Text("\(subscription.formattedPrice) \(subscription.currency)")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    HStack {
                        Text("الفترة:")
                        Spacer()
                        Text(subscription.durationText)
                    }
                    
                    if let discount = subscription.discountPercentage {
                        HStack {
                            Text("الخصم:")
                            Spacer()
                            Text("\(discount)%")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                Spacer()

                // Purchase button
                Button(action: {
                    viewModel.purchaseSubscription(subscription)
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        
                        Text(viewModel.isLoading ? "جاري المعالجة..." : "تأكيد الاشتراك")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                        .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                        .background(
                        viewModel.isLoading ? 
                        Color.gray : Color(hex: subscription.color)
                    )
                        .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("إلغاء") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
            .preferredColorScheme(.light)
    }
}
