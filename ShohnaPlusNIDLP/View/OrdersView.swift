import SwiftUI
import Combine
import UIKit

struct OrdersView: View {
    @StateObject private var orderVM = OrderViewModel()
    @State private var showAddOrderPage = false
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    @ObservedObject var shipmentVM: ShipmentViewModel
    @State private var navigateToShipments = false
    
    var filteredOrders: [Order] {
        if searchText.isEmpty {
            return orderVM.orders
        } else {
            return orderVM.orders.filter { order in
                order.orderNumber.localizedCaseInsensitiveContains(searchText) ||
                order.customerName.localizedCaseInsensitiveContains(searchText) ||
                order.store.localizedCaseInsensitiveContains(searchText) ||
                order.city.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func removeOrder(_ order: Order) {
        orderVM.orders.removeAll { $0.id == order.id }
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
                        Text("الطلبات")
                            .font(.title2).fontWeight(.bold).foregroundColor(.white)
                        Spacer()
                        Button(action: { showAddOrderPage = true }) {
                            Image(systemName: "plus.circle.fill").foregroundColor(.white)
                        }.padding(.trailing)
                    }
                    .frame(height: 50)
                    .padding(.top, 0)
                    SsearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 2)
                    if orderVM.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .frame(maxHeight: .infinity)
                    } else if filteredOrders.isEmpty {
                        VStack(spacing: 30) {
                            Spacer()
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 80))
                                .foregroundColor(Color(hex: "3A1C71").opacity(0.6))
                            VStack(spacing: 16) {
                                Text("لا توجد طلبات")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "3A1C71"))
                                Text("أضف طلبًا جديدًا عبر الزر (+) في الأعلى")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 9) {
                                ForEach(filteredOrders) { order in
                                    NavigationLink(destination: OrderDetailView(order: order, onMoveToShipment: {
                                        navigateToShipments = true
                                    }, shipmentVM: shipmentVM)) {
                                        OrderCard(order: order)
                                    }
                                }
                            }
                            .padding()
                            .padding(.top, 20)
                        }
                    }
                }

                NavigationLink(
                    destination: ShipmentsView(shipmentVM: shipmentVM),
                    isActive: $navigateToShipments
                ) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddOrderPage) {
                AddOrderView { newOrder in
                    Task {
                        await orderVM.saveOrder(newOrder)
                    }
                }
            }
            .task {
                await orderVM.fetchOrders()
            }
        }
    }
}

struct OrderCard: View {
    let order: Order
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.white)
            .frame(width: 370, height: 85)
            .overlay(
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "666666"))
                    Spacer(minLength: 135)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(order.orderNumber)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .padding(.bottom, 5)
                        HStack(spacing: 4) {
                            Text(order.senderAddress)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "666666"))
                            Image(systemName: "arrow.right")
                                .foregroundColor(.green)
                            Text(order.recipientAddress)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "666666"))
                        }
                        .environment(\.layoutDirection, .leftToRight)
                        HStack(spacing: 5) {
                            Text(order.customerName)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "666666"))
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.black)
                        }
                    }
                    Spacer(minLength: 5)
                    Circle()
                        .fill(Color(hex: "F5F5F5"))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image("drone")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        )
                }
                .padding(.horizontal, 25)
            )
            .buttonStyle(PlainButtonStyle())
    }
}

struct AddOrderView: View {
    @Environment(\.dismiss) var dismiss
    @State private var orderNumber = ""
    @State private var customerName = ""
    @State private var productsText = ""
    @State private var paymentMethod = ""
    @State private var store = ""
    @State private var city = ""
    @State private var senderAddress = "" // عنوان المرسل
    @State private var recipientAddress = "" // عنوان المستلم
    var onSave: (Order) -> Void
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("رقم الطلب")) {
                    TextField("رقم الطلب", text: $orderNumber)
                }
                Section(header: Text("اسم العميل")) {
                    TextField("اسم العميل", text: $customerName)
                }
                Section(header: Text("المنتجات المطلوبة (افصل بينها بفاصلة)", comment: "products")) {
                    TextField("مثال: منتج 1, منتج 2", text: $productsText)
                }
                Section(header: Text("طريقة الدفع")) {
                    TextField("طريقة الدفع", text: $paymentMethod)
                }
                Section(header: Text("المتجر")) {
                    TextField("اسم المتجر أو المنصة", text: $store)
                }
                Section(header: Text("المدينة")) {
                    TextField("المدينة", text: $city)
                }
                Section(header: Text("عنوان المرسل")) {
                    TextField("عنوان المرسل التفصيلي", text: $senderAddress)
                }
                Section(header: Text("عنوان المستلم")) {
                    TextField("عنوان المستلم التفصيلي", text: $recipientAddress)
                }
            }
            .navigationTitle("إضافة طلب جديد")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LinearGradient(gradient: Gradient(colors: [Color(hex: "3A1C71"), Color(hex: "6A1B9A")]), startPoint: .bottom, endPoint: .top), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إلغاء") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("حفظ") {
                        let products = productsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        let newOrder = Order(
                            id: UUID().uuidString,
                            orderNumber: orderNumber,
                            customerName: customerName,
                            products: products,
                            paymentMethod: paymentMethod,
                            store: store,
                            city: city,
                            senderAddress: senderAddress,
                            recipientAddress: recipientAddress,
                            syncStatus: .notSynced
                        )
                        onSave(newOrder)
                        dismiss()
                    }
                    .disabled(orderNumber.isEmpty || customerName.isEmpty || productsText.isEmpty || paymentMethod.isEmpty || store.isEmpty || city.isEmpty || senderAddress.isEmpty || recipientAddress.isEmpty)
                }
            }
        }
    }
}

struct OrderDetailView: View {
    let order: Order
    var onMoveToShipment: (() -> Void)? = nil
    @State private var isMoved = false
    @State private var showSuccessAlert = false
    @Environment(\.dismiss) var dismiss
    @State private var showingShipmentSheet = false
    @ObservedObject var shipmentVM: ShipmentViewModel

    var body: some View {
        ZStack {
            // Background colors
            Color("offWhite").ignoresSafeArea()
            
            // Purple header background
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
                    .frame(height: 120)
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            
            VStack(spacing: 0) {
                // Header content
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text("تفاصيل الطلب")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 20).padding(.trailing)
                }
                .frame(height: 50)
                .padding(.top, 0)
                
                // Content
                ScrollView {
                    VStack(spacing: 15) {
                        DetailCard(title: "رقم الطلب", value: order.orderNumber, icon: "number")
                        DetailCard(title: "اسم العميل", value: order.customerName, icon: "person.fill")
                        DetailCard(title: "المتجر", value: order.store, icon: "building.2")
                        DetailCard(title: "المدينة", value: order.city, icon: "mappin.and.ellipse")
                        DetailCard(title: "عنوان المرسل", value: order.senderAddress, icon: "arrow.up.right.square.fill")
                        DetailCard(title: "عنوان المستلم", value: order.recipientAddress, icon: "location.fill")
                        DetailCard(title: "طريقة الدفع", value: order.paymentMethod, icon: "creditcard")
                        DetailCard(title: "حالة المزامنة", value: order.syncStatus.rawValue, icon: "icloud.and.arrow.up")
                        if !order.products.isEmpty {
                            DetailCard(title: "المنتجات المطلوبة", value: order.products.joined(separator: ", "), icon: "cart.fill")
                        }
                        if !isMoved {
                            Button(action: {
                                showingShipmentSheet = true
                            }) {
                                Text("جاهز للشحن")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "3A1C71"), Color(hex: "6A1B9A")]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(12)
                            }
                            .padding(.top, 20)
                        } else {
                            Text("تم نقل الطلب إلى الشحنات!")
                                .foregroundColor(.green)
                                .font(.headline)
                                .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingShipmentSheet) {
            ShipmentDataEntrySheet(shipmentVM: shipmentVM, order: order)
        }
        .alert("تمت إضافة الشحنة بنجاح!", isPresented: $showSuccessAlert) {
            Button("حسناً") {
                dismiss()
                onMoveToShipment?()
            }
        }
    }
    

}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView(shipmentVM: ShipmentViewModel())
    }
} 
 
