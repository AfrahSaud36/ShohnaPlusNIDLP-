import SwiftUI

struct ShipmentsView: View {
    @ObservedObject var shipmentVM: ShipmentViewModel
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    var filteredShipments: [Shipment] {
        let shippedStatuses = ["تم الشحن", "جاري التوصيل", "تم التوصيل"]
        let shipped = shipmentVM.shipments.filter { shippedStatuses.contains($0.status) }
        if searchText.isEmpty {
            return shipped
        } else {
            return shipped.filter { shipment in
                shipment.trackingNumber.localizedCaseInsensitiveContains(searchText) ||
                shipment.recipientName.localizedCaseInsensitiveContains(searchText) ||
                shipment.deliveryAddress.localizedCaseInsensitiveContains(searchText) ||
                shipment.deliveryAddressFrom.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("offWhite").ignoresSafeArea()
                VStack(spacing: 0) {
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
                        .frame(height: 180)
                        .ignoresSafeArea(edges: .top)
                    Spacer()
                }
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left").foregroundColor(.white)
                        }.padding(.leading)
                        Spacer()
                        Text("الشحنات")
                            .font(.title2).fontWeight(.bold).foregroundColor(.white)
                        Spacer()
                        // Removed add button
                        Color.clear.frame(width: 30).padding(.trailing)
                    }
                    .frame(height: 50)
                    .padding(.top, 0)
                    SsearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 2)
                    if shipmentVM.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .frame(maxHeight: .infinity)
                    } else if filteredShipments.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.7))
                            Text(searchText.isEmpty ? "لا توجد شحنات" : "لا توجد نتائج للبحث")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 9) {
                                ForEach(filteredShipments) { shipment in
                                    NavigationLink(destination: ShipmentDetailView(shipment: shipment)) {
                                        ShipmentCard(shipment: shipment)
                                    }
                                }
                            }
                            .padding()
                            .padding(.top, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("خطأ", isPresented: .constant(shipmentVM.error != nil)) {
                Button("حسناً", role: .cancel) { shipmentVM.error = nil }
            } message: {
                if let error = shipmentVM.error {
                    Text(error)
                }
            }
            .task {
                await shipmentVM.fetchShipments()
            }
        }
    }
}

#Preview {
    NavigationView {
        ShipmentsView(shipmentVM: ShipmentViewModel())
    }
}
