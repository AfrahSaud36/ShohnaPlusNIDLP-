import SwiftUI
import UIKit

struct ShipmentDetailView: View {
    let shipment: Shipment
    @Environment(\.dismiss) var dismiss
    @State private var showingShareSheet = false
    @State private var barcodeImage: UIImage? = nil
    @State private var shareImage: UIImage? = nil
    @State private var selectedSupplier: String = ""
    @State private var selectedStatus: String = ""
    @State private var additionalNotes: String = ""
    
    // Sample suppliers/factories
    let suppliers = ["مصنع الرياض", "مصنع جدة", "مورد الشرقية", "مورد الغربية"]
    let statusOptions = ["قيد المعالجة", "تم الشحن", "تم التوصيل"]
    
    var body: some View {
        ZStack {
            Color("offWhite").ignoresSafeArea()
            VStack(spacing: 0) {
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
                        .frame(height: 150)
                        .ignoresSafeArea(edges: .top)
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                        }
                        .padding(.leading)
                        Spacer()
                        Text("تفاصيل الشحنة")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            // التقط صورة لكل تفاصيل الشحنة
                            let image = detailsSnapshot().snapshot()
                            shareImage = image
                            showingShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, -40)
                }
                detailsSnapshot()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ShareSheet(activityItems: [image])
            } else {
                Text("لا توجد صورة للمشاركة")
            }
        }
    }

    // نسخة من دالة توليد الباركود من BarcodeImageView
    func generateBarcode(from string: String) -> UIImage {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgimg = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgimg)
                }
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }

    // View يحتوي كل تفاصيل الشحنة (للسنابشوت)
    @ViewBuilder
    func detailsSnapshot() -> some View {
        ScrollView {
            VStack(spacing: 15) {
                BarcodeImageView(trackingNumber: shipment.trackingNumber)
                    .frame(height: 100)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                VStack(alignment: .trailing, spacing: 15) {
                    DetailCard(title: "رقم التتبع", value: shipment.trackingNumber, icon: "barcode")
                    DetailCard(title: "اسم المستلم", value: shipment.recipientName, icon: "person.fill")
                    DetailCard(title: "العنوان", value: shipment.deliveryAddress, icon: "location.fill")
                    DetailCard(title: "عنوان المرسل", value: shipment.deliveryAddressFrom, icon: "arrow.up.right.square.fill")
                    DetailCard(title: "شركة الشحن", value: shipment.shippingCompany, icon: "truck")
                    DetailCard(title: "تكلفة الشحن", value: String(format: "%.2f", shipment.shippingCost), icon: "creditcard")
                    DetailCard(title: "مصدر الطلب", value: shipment.orderSource, icon: "cart")
                    DetailCard(title: "طريقة الدفع", value: shipment.paymentMethod, icon: "banknote")
                    DetailCard(title: "الحالة", value: shipment.status, icon: "shippingbox.fill")
                    DetailCard(
                        title: "تاريخ الشحنة",
                        value: shipment.shipmentDate.formatted(date: .long, time: .shortened),
                        icon: "calendar"
                    )
                    DetailCard(title: "المورد أو المصنع", value: shipment.supplier, icon: "building.2")
                    if !shipment.notes.isEmpty {
                        DetailCard(title: "ملاحظات إضافية", value: shipment.notes, icon: "note.text")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
            }
        }
    }
}

// snapshot extension
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
