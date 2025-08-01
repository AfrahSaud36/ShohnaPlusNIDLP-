import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @StateObject private var subscriptionVM = SubscriptionViewModel()
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var animateAI = true
    var shipmentVM: ShipmentViewModel

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomLeading) {
                
                VStack(spacing: 0) {
                    ZStack {
                        Color("offWhite").ignoresSafeArea()
                        ScrollView {
                            VStack(spacing: 6) {
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 30)
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
                                        .frame(height: 270)
                                        .clipShape(
                                            RoundedCorner(
                                                radius: 40,
                                                corners: [.bottomLeft, .bottomRight]
                                            )
                                        )
                                        .shadow(color: Color(hex: "B39DDB").opacity(0.3), radius: 8, x: 0, y: 4)
                                        .overlay(
                                            RoundedCorner(
                                                radius: 40,
                                                corners: [.bottomLeft, .bottomRight]
                                            )
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                        .ignoresSafeArea(edges: .top)

                                    VStack(alignment: .center, spacing: 16) {
                                        HStack {
                                            Spacer()
                                            Text("هلا أفراح")
                                                .foregroundColor(.white)
                                                .font(.headline)

                                            NavigationLink(destination: SettingsView()) {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.top, 60)

                                        Text("1500.00 sr")
                                            .foregroundColor(.white)
                                            .font(.system(size: 28))
                                            .bold()
                                            .multilineTextAlignment(.center)

                                        HStack(spacing: 30) {
                                            NavigationLink(destination: TransactionsView().navigationBarBackButtonHidden(true)) {
                                                CircleButton(title: "العمليات", icon: "doc.text")
                                                    .font(.system(size: 28))
                                            }

                                            NavigationLink(destination: ChargeView().navigationBarBackButtonHidden(true)) {
                                                CircleButton(title: "اشحن الآن", icon: "plus")
                                                    .font(.system(size: 28))
                                            }
                                        }
                                    }
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxHeight: .infinity, alignment: .center)
                                    .padding()
                                }

                                VStack(alignment: .trailing, spacing: 20) {
                                    // Packages section
                                    HStack {
                                        Spacer()
                                        Text("الباقات")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 15)
                                    
                                    // Subscription card
                                    NavigationLink(destination: SubscriptionView().navigationBarBackButtonHidden(true)) {
                                        SubscriptionServiceCard(subscriptionVM: subscriptionVM)
                                    }
                                    .buttonStyle(ServiceButtonStyle())
                                    .simultaneousGesture(TapGesture().onEnded {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                    })
                                    .padding(.horizontal, 20)
                                    .padding(.top, -15)
                                    
                                    HStack {
                                        Spacer()
                                        Text("الخدمات")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, -6)

                                    // Services in Rajhi Bank style
                                    VStack(spacing: 16) {
                                        // First Row
                                        HStack(spacing: 16) {
                                            NavigationLink(destination: TrackView().navigationBarBackButtonHidden(true)) {
                                                RajhiServiceCard(title: "التتبع", icon: "location.magnifyingglass")
                                            }
                                            .buttonStyle(ServiceButtonStyle())
                                            .simultaneousGesture(TapGesture().onEnded {
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                            })
                                            
                                            NavigationLink(destination: SeeReturnView().navigationBarBackButtonHidden(true)) {
                                                RajhiServiceCard(title: "الرجيع", icon: "arrow.uturn.backward")
                                            }
                                            .buttonStyle(ServiceButtonStyle())
                                            .simultaneousGesture(TapGesture().onEnded {
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                            })
                                            
                                            NavigationLink(destination: FactoriesView().navigationBarBackButtonHidden(true)) {
                                                RajhiServiceCard(title: "المصانع", icon: "hammer.fill")
                                            }
                                            .buttonStyle(ServiceButtonStyle())
                                            .simultaneousGesture(TapGesture().onEnded {
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                            })
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        // Second Row
                                        HStack(spacing: 16) {
                                            NavigationLink(destination: SuppliesView().navigationBarBackButtonHidden(true)) {
                                                RajhiServiceCard(title: "المستلزمات", icon: "cube.box.fill")
                                            }
                                            .buttonStyle(ServiceButtonStyle())
                                            .simultaneousGesture(TapGesture().onEnded {
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                            })

                                            NavigationLink(destination: ShipmentsView(shipmentVM: shipmentVM).navigationBarBackButtonHidden(true)) {
                                                RajhiServiceCard(title: "الشحنات", icon: "shippingbox.fill")
                                            }
                                            .buttonStyle(ServiceButtonStyle())
                                            .simultaneousGesture(TapGesture().onEnded {
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                            })

                                            NavigationLink(destination: OrdersView(shipmentVM: shipmentVM).navigationBarBackButtonHidden(true)) {
                                                RajhiServiceCard(title: "الطلبات", icon: "doc.text.fill")
                                            }
                                            .buttonStyle(ServiceButtonStyle())
                                            .simultaneousGesture(TapGesture().onEnded {
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                            })
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }

                                RecentOrdersSection(vm: vm, shipmentVM: shipmentVM)
                            }
                            .padding(.top, -80)
                        }
                    }
                }
                // زر الذكاء الاصطناعي
                NavigationLink(destination: ChatBotView(shipmentVM: shipmentVM).navigationBarBackButtonHidden(true)) {
                    ChatbotButtonView()
                        .frame(width: 38, height: 48)
                }
                .padding(.bottom, 18)
                .padding(.leading, 26)
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct RecentOrdersSection: View {
    @ObservedObject var vm: HomeViewModel
    var shipmentVM: ShipmentViewModel

    var body: some View {
        VStack(alignment: .trailing, spacing: 40) {
            HStack {
                NavigationLink(destination: ShipmentsView(shipmentVM: shipmentVM).navigationBarBackButtonHidden(true)) {
                    Text("مشاهدة الكل")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "7E57C2"))
                }
                Spacer()
                Text("الطلبات الأخيرة")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.top, 20)
            .padding(.bottom, -21)

            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                VStack(spacing: 24) {
                    ForEach(vm.recentShipments) { shipment in
                        NavigationLink(destination: ShipmentDetailView(shipment: shipment)) {
                            ShipmentCard(shipment: shipment)
                                .frame(width: 370, height: 70)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - CircleButton
struct CircleButton: View {
    let title: String
    let icon: String

    var body: some View {
        VStack {
            Circle()
                .fill(Color.white)
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "7E57C2"))
                )
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 11, weight: .medium))
        }
    }
}

// MARK: - iOS Standards Compliant Service Card
struct RajhiServiceCard: View {
    let title: String
    let icon: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
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
                    .frame(height: 100)
                    .shadow(
                        color: colorScheme == .dark ? 
                            Color.black.opacity(0.4) : 
                            Color(hex: "B39DDB").opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                VStack(spacing: 8) {
                    // Icon with proper accessibility
                    Image(systemName: icon)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .accessibilityHidden(true)
                    
                    // Title with Dynamic Type support
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
        }

        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}



// MARK: - Service Button Style
struct ServiceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Subscription Service Card
struct SubscriptionServiceCard: View {
    @ObservedObject var subscriptionVM: SubscriptionViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "5E35B1"),
                            Color(hex: "7E57C2"),
                            Color(hex: "9575CD")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 95)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color(hex: "5E35B1").opacity(0.4),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            
            HStack(spacing: 16) {
                // Left section - Arrow and Status
                VStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    if subscriptionVM.hasActiveSubscription {
                        Text("نشط")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "3A1C71"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                    }
                }
                
                Spacer()
                
                // Right section - Content and Icon
                HStack(spacing: 12) {
                    // Content section
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(subscriptionVM.hasActiveSubscription ? "باقتي الحالية" : "الاشتراكات")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(subscriptionVM.hasActiveSubscription ? 
                             "باقة \(subscriptionVM.activeSubscriptionName)" : 
                             "اختر الباقة المناسبة لاحتياجاتك")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                    
                    // Icon section
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                        
                        Image(systemName: "crown.fill")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        
                        if subscriptionVM.hasActiveSubscription {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 18, height: 18)
                                .offset(x: 18, y: -18)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "5E35B1"), lineWidth: 2)
                                        .frame(width: 18, height: 18)
                                        .offset(x: 18, y: -18)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color(hex: "5E35B1"))
                                        .offset(x: 18, y: -18)
                                )
                                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(subscriptionVM.hasActiveSubscription ? "باقتي الحالية - \(subscriptionVM.activeSubscriptionName)" : "الاشتراكات")
        .accessibilityAddTraits(.isButton)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(shipmentVM: ShipmentViewModel())
            .environmentObject(ReturnDataModel())
    }
}

