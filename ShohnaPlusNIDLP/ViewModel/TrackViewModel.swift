import Foundation
import MapKit
import SwiftUI
import CloudKit

@MainActor
class TrackViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedShipment: Shipment? = nil
    @Published var showTrackingView: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var shipments: [Shipment] = []
    @Published var progress: Double = 0.0
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753), span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
    @Published var fromCoordinate: CLLocationCoordinate2D? = nil
    @Published var toCoordinate: CLLocationCoordinate2D? = nil
    @Published var shipmentCoordinate: CLLocationCoordinate2D? = nil
    @Published var isLoading: Bool = false
    @Published var showMapError: Bool = false
    private var timer: Timer? = nil
    
    private var shipmentViewModel: ShipmentViewModel

    init() {
        
        self.shipmentViewModel = ShipmentViewModel()
    }

    // جلب الشحنات
    func fetchShipments() {
        Task {
            await shipmentViewModel.fetchShipments()
            self.shipments = shipmentViewModel.shipments
        }
    }

    func searchShipment() {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchText.isEmpty else {
            errorMessage = "يرجى إدخال رقم التتبع"
            showError = true
            return
        }
        
        // البحث في النظام القديم أولاً
        if let foundShipment = shipments.first(where: { $0.trackingNumber.localizedCaseInsensitiveContains(trimmedSearchText) }) {
            selectedShipment = foundShipment
            showTrackingView = true
        } 
        // البحث في نظام التتبع الجديد
        else if RealTimeTrackingService.shared.getTrackingInfo(trackingNumber: trimmedSearchText) != nil {
            // إنشاء shipment مؤقت للنظام القديم
            let tempShipment = Shipment(
                id: UUID().uuidString,
                trackingNumber: trimmedSearchText,
                recipientName: "المستلم",
                deliveryAddress: "موقع التسليم",
                deliveryAddressFrom: "موقع الإرسال",
                status: "قيد التتبع",
                shipmentDate: Date(),
                supplier: "المورد",
                notes: "تتبع في الوقت الفعلي",
                shippingCompany: "شركة الشحن",
                shippingType: "عادي",
                shippingCost: 0.0,
                orderSource: "التطبيق",
                paymentMethod: "نقدي"
            )
            selectedShipment = tempShipment
            showTrackingView = true
        } 
        else {
            errorMessage = "لم يتم العثور على شحنة برقم التتبع: \(trimmedSearchText)"
            showError = true
        }
    }
    
    func geocodeAddresses() {
        guard let shipment = selectedShipment else { return }
        isLoading = true
        showMapError = false
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(shipment.deliveryAddressFrom) { fromPlacemarks, fromError in
            if let fromCoord = fromPlacemarks?.first?.location?.coordinate {
                self.fromCoordinate = fromCoord
                self.shipmentCoordinate = fromCoord
                geocoder.geocodeAddressString(shipment.deliveryAddress) { toPlacemarks, toError in
                    self.isLoading = false
                    if let toCoord = toPlacemarks?.first?.location?.coordinate {
                        self.toCoordinate = toCoord
                        let midLat = (fromCoord.latitude + toCoord.latitude) / 2
                        let midLon = (fromCoord.longitude + toCoord.longitude) / 2
                        self.region.center = CLLocationCoordinate2D(latitude: midLat, longitude: midLon)
                        self.startSimulation()
                    } else {
                        self.showMapError = true
                    }
                }
            } else {
                self.isLoading = false
                self.showMapError = true
            }
        }
    }

    func startSimulation() {
        timer?.invalidate()
        progress = 0.0
        guard let from = fromCoordinate, let to = toCoordinate else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if self.progress < 1.0 {
                DispatchQueue.main.async {
                    self.progress += 0.001
                    let lat = from.latitude + (to.latitude - from.latitude) * self.progress
                    let lon = from.longitude + (to.longitude - from.longitude) * self.progress
                    self.shipmentCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                }
            } else {
                self.timer?.invalidate()
                self.shipmentCoordinate = to
            }
        }
    }
    
    func openInMaps() {
        guard let from = fromCoordinate, let to = toCoordinate else { return }
        let placemarkFrom = MKPlacemark(coordinate: from)
        let placemarkTo = MKPlacemark(coordinate: to)
        let mapItemFrom = MKMapItem(placemark: placemarkFrom)
        let mapItemTo = MKMapItem(placemark: placemarkTo)
        mapItemFrom.name = "من"
        mapItemTo.name = "إلى"
        MKMapItem.openMaps(with: [mapItemFrom, mapItemTo], launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    func resetTracking() {
        showTrackingView = false
        selectedShipment = nil
        fromCoordinate = nil
        toCoordinate = nil
        shipmentCoordinate = nil
        progress = 0.0
        timer?.invalidate()
    }
}
