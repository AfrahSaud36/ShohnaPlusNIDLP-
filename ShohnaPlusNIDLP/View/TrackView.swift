import SwiftUI
import MapKit
import AVFoundation

struct TrackView: View {
    @StateObject private var vm = TrackViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("offWhite").ignoresSafeArea()
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
            VStack(spacing: 5) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left").foregroundColor(.white)
                    }.padding(.leading)
                    Spacer()
                    Text("تتبع الشحنة")
                        .font(.title2).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 20).padding(.trailing)
                }
                .frame(height: 50)
                .padding(.top, 0)
                TrackingSearchBar(text: $vm.searchText, onSearch: vm.searchShipment)
                    .padding(.top, -1)
                if vm.showTrackingView, let shipment = vm.selectedShipment {
                    VStack(spacing: 20) {
                        LiveTrackingView(vm: vm, shipment: shipment)
                        
                        // Real-Time Tracking Button
                        NavigationLink(destination: RealTimeTrackingView(trackingNumber: shipment.trackingNumber).navigationBarBackButtonHidden(true)) {
                            HStack {
                                Image(systemName: "dot.radiowaves.left.and.right")
                                    .font(.system(size: 16))
                                Text("التتبع المباشر الجديد")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.white)
                            .padding(16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "3A1C71"), Color(hex: "6A1B9A")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)
                    }
                    .transition(.opacity)
                } else {
                    VStack(spacing: 30) {
                        Spacer()
                        Image(systemName: "location.magnifyingglass")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "3A1C71").opacity(0.6))
                        VStack(spacing: 16) {
                            Text("تتبع شحنتك")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "3A1C71"))
                            Text("أدخل رقم التتبع في الأعلى لتتبع شحنتك ومعرفة موقعها الحالي")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        // أرقام تجريبية
                        VStack(spacing: 12) {
                            Text("أرقام تجريبية للاختبار:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(["R8282", "R8283", "R8284", "SHP001", "SHP002"], id: \.self) { number in
                                        Button(action: {
                                            vm.searchText = number
                                            vm.searchShipment()
                                        }) {
                                            Text(number)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color(hex: "3A1C71"))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color(hex: "3A1C71").opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer()
                    }
                    .transition(.opacity)
                }
                Spacer()
            }
        }
        .onAppear {
            Task { await vm.fetchShipments() }
        }
        .alert("خطأ", isPresented: $vm.showError) {
            Button("حسناً") { }
        } message: {
            Text(vm.errorMessage)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct TrackingSearchBar: View {
    @Binding var text: String
    let onSearch: () -> Void
    @State private var showingScanner = false

    var body: some View {
        HStack {
            HStack {
                Button(action: { showingScanner = true }) {
                    Image(systemName: "barcode.viewfinder").foregroundColor(.primary)
                }
                ZStack(alignment: .trailing) {
                    if text.isEmpty {
                        Text("ابحث عن رقم الشحنة").foregroundColor(.gray)
                    }
                    TextField("", text: $text)
                        .foregroundColor(.primary)
                        .onSubmit {
                            // استدعاء البحث عند الضغط على زر "return" فقط
                            onSearch()
                        }
                }
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingScanner) {
            TrackingBarcodeScannerView(scannedCode: $text)
        }
    }
}


struct TrackingBarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Environment(\.presentationMode) var presentationMode
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIViewController()
        let captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return controller }
        let videoInput: AVCaptureDeviceInput
        do { videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice) } catch { return controller }
        if (captureSession.canAddInput(videoInput)) { captureSession.addInput(videoInput) } else { return controller }
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417, .code128]
        } else { return controller }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = controller.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        controller.view.layer.addSublayer(previewLayer)
        DispatchQueue.global(qos: .userInitiated).async { captureSession.startRunning() }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: TrackingBarcodeScannerView
        init(_ parent: TrackingBarcodeScannerView) { self.parent = parent }
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                parent.scannedCode = stringValue
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct LiveTrackingView: View {
    @ObservedObject var vm: TrackViewModel
    let shipment: Shipment
    var annotationItems: [MapPin] {
        var pins: [MapPin] = []
        if let from = vm.fromCoordinate {
            pins.append(MapPin(coordinate: from, title: "من", type: .start))
        }
        if let to = vm.toCoordinate {
            pins.append(MapPin(coordinate: to, title: "إلى", type: .end))
        }
        if let shipmentLoc = vm.shipmentCoordinate {
            pins.append(MapPin(coordinate: shipmentLoc, title: "الشحنة", type: .shipment))
        }
        return pins
    }
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("رقم التتبع:").font(.caption).foregroundColor(.gray)
                            Text(shipment.trackingNumber).font(.headline).foregroundColor(.black)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("الحالة:").font(.caption).foregroundColor(.gray)
                            Text(shipment.status).font(.headline).foregroundColor(.green)
                        }
                    }
                    Divider()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("من:").font(.caption).foregroundColor(.gray)
                            Text(shipment.deliveryAddressFrom).font(.subheadline).foregroundColor(.black)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("إلى:").font(.caption).foregroundColor(.gray)
                            Text(shipment.deliveryAddress).font(.subheadline).foregroundColor(.black)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                if let from = vm.fromCoordinate, let to = vm.toCoordinate {
                    VStack(spacing: 12) {
                        Text("مسار الشحنة").font(.headline).foregroundColor(Color(hex: "3A1C71"))
                        Map(coordinateRegion: $vm.region, annotationItems: annotationItems) { pin in
                            MapAnnotation(coordinate: pin.coordinate) {
                                switch pin.type {
                                case .start:
                                    Image(systemName: "mappin.circle.fill").font(.title).foregroundColor(.blue).shadow(radius: 2)
                                case .end:
                                    Image(systemName: "mappin.circle.fill").font(.title).foregroundColor(.red).shadow(radius: 2)
                                case .shipment:
                                    Image(systemName: "box.truck.fill").font(.title).foregroundColor(Color(hex: "3A1C71")).padding(8).background(Color.white).clipShape(Circle()).shadow(radius: 3)
                                }
                            }
                        }
                        .frame(height: 250)
                        .cornerRadius(16)
                        Button(action: vm.openInMaps) {
                            Label("افتح المسار في الخريطة", systemImage: "map")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "3A1C71"), Color(hex: "6A1B9A")]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(12)
                        }
                    }
                } else if vm.isLoading {
                    VStack(spacing: 16) {
                        ProgressView("جاري تحميل الخريطة...")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "3A1C71")))
                        Text("جاري تحديد المواقع...").font(.caption).foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                } else if vm.showMapError {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle").font(.system(size: 40)).foregroundColor(.orange)
                        Text("تعذر تحديد الموقع").font(.headline).foregroundColor(.orange)
                        Text("تأكد من صحة العناوين المدخلة").font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 40)
        .onAppear { vm.geocodeAddresses() }
        .onDisappear { vm.resetTracking() }
    }
} 
#Preview {
    NavigationView {
        TrackView()
    }
}
