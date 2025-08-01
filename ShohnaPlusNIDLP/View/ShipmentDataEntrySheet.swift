import SwiftUI

struct ShipmentDataEntrySheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var shipmentVM: ShipmentViewModel
    let order: Order
    @State private var showSuccessAlert = false
    @State private var navigateToShipments = false
    
    @State private var trackingNumber: String = ""
    @State private var recipientName: String = ""
    @State private var deliveryAddress: String = ""
    @State private var deliveryAddressFrom: String = ""
    @State private var shippingCompany: String = ""
    @State private var shippingType: String = ""
    @State private var shippingCost: String = ""
    @State private var supplier: String = ""
    @State private var notes: String = ""
    @State private var status: String = "تم الشحن"
    
    let shippingCompanies = ["شركة الشحن السعودية", "أرامكس", "دي إتش إل", "فيديكس", "يو بي إس", "شركة الشحن المحلية"]
    let shippingTypes = ["بري", "جوي", "بحري", "سريع"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("معلومات الشحنة").foregroundColor(Color(hex: "3A1C71"))) {
                    TextField("رقم التتبع", text: $trackingNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("اسم المستلم", text: $recipientName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("عنوان المستلم", text: $deliveryAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("عنوان المرسل", text: $deliveryAddressFrom)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("تفاصيل الشحن").foregroundColor(Color(hex: "3A1C71"))) {
                    Picker("شركة الشحن", selection: $shippingCompany) {
                        Text("اختر شركة الشحن").tag("")
                        ForEach(shippingCompanies, id: \.self) { company in
                            Text(company).tag(company)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("نوع الشحن", selection: $shippingType) {
                        Text("اختر نوع الشحن").tag("")
                        ForEach(shippingTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("تكلفة الشحن", text: $shippingCost)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                    TextField("المورد أو المصنع", text: $supplier)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("ملاحظات إضافية").foregroundColor(Color(hex: "3A1C71"))) {
                    TextField("ملاحظات (اختياري)", text: $notes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("تعبئة بيانات الشحنة")
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
                        saveShipment()
                    }
                    .disabled(trackingNumber.isEmpty || recipientName.isEmpty || deliveryAddress.isEmpty || deliveryAddressFrom.isEmpty || shippingCompany.isEmpty || shippingType.isEmpty || shippingCost.isEmpty)
                }
            }
            .onAppear {
                // تعبئة البيانات من الطلب
                trackingNumber = order.orderNumber
                recipientName = order.customerName
                deliveryAddress = order.recipientAddress
                deliveryAddressFrom = order.senderAddress
                supplier = order.store
                notes = "تم التحويل من الطلب: \(order.products.joined(separator: ", "))"
            }
            .alert("تمت إضافة الشحنة بنجاح!", isPresented: $showSuccessAlert) {
                Button("حسناً") {
                    dismiss()
                    navigateToShipments = true
                }
            }
            .background(
                NavigationLink(
                    destination: ShipmentsView(shipmentVM: shipmentVM),
                    isActive: $navigateToShipments
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    private func saveShipment() {
        let cost = Double(shippingCost) ?? 0.0
        
        let newShipment = Shipment(
            id: UUID().uuidString,
            trackingNumber: trackingNumber,
            recipientName: recipientName,
            deliveryAddress: deliveryAddress,
            deliveryAddressFrom: deliveryAddressFrom,
            status: status,
            shipmentDate: Date(),
            supplier: supplier,
            notes: notes,
            shippingCompany: shippingCompany,
            shippingType: shippingType,
            shippingCost: cost,
            orderSource: order.store,
            paymentMethod: order.paymentMethod
        )
        
        Task {
            await shipmentVM.saveShipment(newShipment)
            showSuccessAlert = true
        }
    }
} 