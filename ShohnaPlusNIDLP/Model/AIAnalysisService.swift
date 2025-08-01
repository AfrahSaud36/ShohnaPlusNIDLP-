import Foundation
import UIKit
import CoreML
import Vision

class AIAnalysisService {
    static let shared = AIAnalysisService()
    private var model: VNCoreMLModel?
    
    private init() {
        setupModel()
    }
    
    private func setupModel() {
        do {
            if let modelURL = Bundle.main.url(forResource: "TrainAI", withExtension: "mlmodelc") {
                let model = try MLModel(contentsOf: modelURL)
                self.model = try VNCoreMLModel(for: model)
            } else {
                print("Error: Could not find TrainAI model in bundle")
            }
        } catch {
            print("Error setting up model: \(error)")
        }
    }
    
    private func analyzeWithModel(_ imageData: Data) async throws -> (isGood: Bool, confidence: Double) {
        guard let model = self.model else {
            throw NSError(domain: "AIAnalysisService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Model not initialized"])
        }
        guard let image = UIImage(data: imageData) else {
            throw NSError(domain: "AIAnalysisService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    continuation.resume(throwing: NSError(domain: "AIAnalysisService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No results from model"]))
                    return
                }
                let isGood = topResult.identifier.lowercased() == "good"
                let confidence = Double(topResult.confidence)
                continuation.resume(returning: (isGood, confidence))
            }
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func analyzeImage(_ imageData: Data) async throws -> (isGood: Bool, confidence: Double, details: String) {
        let (isGoodCondition, confidence) = try await analyzeWithModel(imageData)
        let details: String
        if isGoodCondition {
            details = confidence > 0.8 
                ? "حالة الشحنة جيدة - لا تحتاج إلى فحص إضافي (ثقة عالية: \(Int(confidence * 100))%)"
                : "حالة الشحنة جيدة - يفضل فحص إضافي للتأكد (ثقة متوسطة: \(Int(confidence * 100))%)"
        } else {
            details = confidence > 0.8
                ? "حالة الشحنة سيئة - تحتاج إلى فحص إضافي فوري (ثقة عالية: \(Int(confidence * 100))%)"
                : "حالة الشحنة سيئة - يرجى مراجعة تفصيلية (ثقة متوسطة: \(Int(confidence * 100))%)"
        }
        return (isGoodCondition, confidence, details)
    }
    
    func analyzeImages(_ images: [Data]) async throws -> String {
        var goodCount = 0
        var totalConfidence = 0.0
        for imageData in images {
            let (isGood, confidence, _) = try await analyzeImage(imageData)
            if isGood {
                goodCount += 1
            }
            totalConfidence += confidence
        }
        let averageConfidence = totalConfidence / Double(images.count)
        let isOverallGood = Double(goodCount) / Double(images.count) > 0.5
        if isOverallGood {
            return "جيد"
        } else {
            return "سيء"
        }
    }
} 