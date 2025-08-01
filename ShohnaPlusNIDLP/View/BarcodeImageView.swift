import SwiftUI
import CoreImage.CIFilterBuiltins

struct BarcodeImageView: View {
    let trackingNumber: String
    
    var body: some View {
        Image(uiImage: generateBarcode(from: trackingNumber))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
    }
    
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
} 
