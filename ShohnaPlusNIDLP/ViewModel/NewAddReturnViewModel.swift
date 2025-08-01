import Foundation
import PhotosUI
import SwiftUI

class NewAddReturnViewModel: ObservableObject {
    @Published var orderNumber: String = ""
    @Published var returnDate: Date = Date()
    @Published var productCondition: String = ""
    @Published var shippingInfo: String = ""
    @Published var origin: String = ""
    @Published var destination: String = ""
    @Published var weight: String = ""
    @Published var orderDate: Date = Date()
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var selectedImages: [Image] = []
    @Published var loadedImageData: [Data] = []
    let imageLimit = 5

    func handleSelectedItemsChange() {
        selectedImages = []
        loadedImageData = []
        for item in selectedItems {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data?):
                    if let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.selectedImages.append(Image(uiImage: uiImage))
                        }
                    }
                    self.loadedImageData.append(data)
                case .success(nil):
                    print("No data received for the image.")
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        }
    }

    func createReturnInformation() -> ReturnInformation {
        ReturnInformation(
            id: UUID().uuidString,
            customerName: "",
            customerEmail: "",
            customerPhone: "",
            returnCode: "",
            orderNumber: orderNumber,
            returnDate: returnDate,
            orderDate: orderDate,
            productCondition: productCondition,
            shippingInfo: shippingInfo,
            imageData: loadedImageData,
            status: "Pending",
            notes: "",
            origin: origin,
            destination: destination,
            weight: weight,
            returnTime: Date().formatted(date: .abbreviated, time: .shortened),
            aiAnalysisResult: "تحليل الذكاء الاصطناعي قيد المعالجة..."
        )
    }

    func reset() {
        orderNumber = ""
        returnDate = Date()
        productCondition = ""
        shippingInfo = ""
        origin = ""
        destination = ""
        weight = ""
        orderDate = Date()
        selectedItems = []
        selectedImages = []
        loadedImageData = []
    }
} 
