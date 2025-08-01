import SwiftUI

struct ChatBotView: View {
    @StateObject private var viewModel = ChatbotViewModel()
    var shipmentVM: ShipmentViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("offWhite"),
                        Color.white.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Modern Header
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "3A1C71"),
                                        Color(hex: "6A1B9A")
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .ignoresSafeArea(edges: .top)
                            .frame(height: 110)

                        VStack(spacing: 8) {
                            HStack {
                                Button(action: {
                                    // Navigate back
                                }) {
                                    NavigationLink(destination: HomeView(shipmentVM: shipmentVM).navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 4) {
                                    Text("LOGI TECK")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(.green)
                                            .frame(width: 8, height: 8)
                                        
                                        Text("جاهز للمساعدة")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white.opacity(0.95))
                                    }
                                }
                                
                                Spacer()
                                
                                // Bot avatar
                                ZStack {
                                    Circle()
                                        .fill(.white.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image("cuterob")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 0)
                        }
                    }

                    // Chat area
                    ScrollView {
                        LazyVStack(spacing: 26) {
                            // Welcome message
                            if viewModel.chatHistory.isEmpty {
                                WelcomeMessageCard()
                                    .padding(.top, 20)
                            }
                            
                            ForEach(viewModel.chatHistory) { message in
                                MessageBubble(message: message)
                            }

                            if viewModel.isLoading {
                                TypingIndicator()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { _ in
                                hideKeyboard()
                            }
                    )

                    // Input area
                    ModernInputBar(
                        text: $viewModel.input,
                        isLoading: viewModel.isLoading,
                        onSend: viewModel.sendMessage
                    )
                }
            }
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

// MARK: - Welcome Message Card
struct WelcomeMessageCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // Bot avatar with enhanced design
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "6A1B9A").opacity(0.2),
                                Color(hex: "3A1C71").opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "6A1B9A").opacity(0.2), radius: 10, x: 0, y: 5)
                
                Image("cuterob")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
            }
            
            VStack(spacing: 12) {
                Text("أهلاً وسهلاً! 👋")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("أنا مساعدك الذكي لوجي")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "6A1B9A"))
                
                Text("اسألني أي سؤال وسأقوم بمساعدتك على الفور")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // Professional feature highlight
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "6A1B9A"))
                    
                    Text("مدعوم بالذكاء الاصطناعي")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "6A1B9A"))
                    
                    Text("متاح 24/7 لخدمتك")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, 8)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
}



// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if message.role == "CHATBOT" {
                // Bot avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: "6A1B9A").opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image("cuterob")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                
                // Bot message
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.message)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    Text("لوجي")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
                
                Spacer(minLength: 60)
            } else {
                Spacer(minLength: 60)
                
                // User message
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.message)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
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
                        .cornerRadius(18)
                        .shadow(color: Color(hex: "6A1B9A").opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Text("أنت")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                }
                
                // User avatar
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
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animatingDots = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Bot avatar
            ZStack {
                Circle()
                    .fill(Color(hex: "6A1B9A").opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image("cuterob")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            
            // Typing animation
                                    HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: 6, height: 6)
                        .scaleEffect(animatingDots ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animatingDots
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            Spacer(minLength: 60)
        }
        .onAppear {
            animatingDots = true
        }
    }
}

// MARK: - AI Input Bar
struct ModernInputBar: View {
    @Binding var text: String
    let isLoading: Bool
    let onSend: () -> Void
    @State private var isTyping = false
    @State private var showSuggestions = false
    
    let suggestions = ["ما هي حالة شحنتي؟", "كيف أتتبع الطلب؟", "أريد مساعدة في الشحن", "معلومات عن الأسعار"]
    
    var body: some View {
        VStack(spacing: 0) {
            // AI Suggestions Bar (appears when field is focused)
            if showSuggestions && text.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("اقتراحات سريعة")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                                    Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSuggestions = false
                                isTyping = false
                                hideKeyboard()
                            }
                        }) {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "6A1B9A"))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                SuggestionChip(text: suggestion) {
                                    text = suggestion
                                    showSuggestions = false
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 12)
                .background(Color(.systemGray6).opacity(0.5))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Elegant divider
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color(hex: "6A1B9A").opacity(0.1),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
                         // Enhanced input area
             VStack(spacing: 16) {
                 HStack(spacing: 16) {
                     // Smart input field
                     HStack(spacing: 12) {
                        // Input field with AI styling
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            isTyping ? 
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "3A1C71"),
                                                    Color(hex: "6A1B9A")
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ) : 
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.clear]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .frame(height: 48)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "6A1B9A"))
                                    .opacity(text.isEmpty ? 0.7 : 0)
                                    .animation(.easeInOut(duration: 0.3), value: text.isEmpty)
                                
                                TextField("اسأل لوجي أي شيء...", text: $text, axis: .vertical)
                                    .font(.body)
                                    .lineLimit(1...3)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            showSuggestions = true
                                            isTyping = true
                                        }
                                    }
                                    .onChange(of: text) { _ in
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            showSuggestions = false
                                            isTyping = !text.isEmpty
                                        }
                                    }
                            }
                            .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Enhanced Send button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                onSend()
                                showSuggestions = false
                                isTyping = false
                            }
                        }) {
                            ZStack {
                                // Animated background
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "3A1C71"),
                                                Color(hex: "6A1B9A"),
                                                Color(hex: "8E24AA")
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .scaleEffect(text.isEmpty ? 0.85 : 1.0)
                                    .shadow(
                                        color: Color(hex: "6A1B9A").opacity(text.isEmpty ? 0.2 : 0.4),
                                        radius: text.isEmpty ? 4 : 8,
                                        x: 0,
                                        y: text.isEmpty ? 2 : 4
                                    )
                                
                                // Loading or Send icon
                                Group {
                                    if isLoading {
                                        LoadingDots()
                                    } else {
                                        Image(systemName: "arrow.up")
                                            .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                                                 .disabled(text.isEmpty || isLoading)
                         .animation(.spring(response: 0.4, dampingFraction: 0.7), value: text.isEmpty)
                         .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isLoading)
                    }
                }
                
                // AI Status indicator
                if isLoading {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "6A1B9A"))
                        
                        Text("لوجي يفكر...")
                            .font(.caption)
                            .foregroundColor(Color(hex: "6A1B9A"))
                        
                        Spacer()
                    }
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            )
        }
    }
}

// MARK: - Suggestion Chip
struct SuggestionChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "6A1B9A"))
                
                Text(text)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}



// MARK: - Loading Dots
struct LoadingDots: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.white)
                    .frame(width: 4, height: 4)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - Helper Functions
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

#Preview {
    ChatBotView(shipmentVM: ShipmentViewModel())
}
