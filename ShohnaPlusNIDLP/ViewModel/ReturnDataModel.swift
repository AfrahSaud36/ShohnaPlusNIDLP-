import Foundation
import Combine

class ReturnDataModel: ObservableObject {
    @Published var returnItems: [ReturnInformation] = []
    @Published var isAnalyzing: Bool = false
    
    init() {
        returnItems = []
    }
    
    func analyzeReturnImages(for returnId: String) async {
        guard let index = returnItems.firstIndex(where: { $0.id == returnId }) else { return }
        await MainActor.run {
            isAnalyzing = true
            returnItems[index].aiAnalysisResult = "جاري تحليل الصور..."
        }
        do {
            let result = try await AIAnalysisService.shared.analyzeImages(returnItems[index].imageData)
            await MainActor.run {
                returnItems[index].aiAnalysisResult = result
                if result == "جيد" {
                    returnItems[index].status = "Processing"
                } else if result == "سيء" {
                    returnItems[index].status = "Rejected"
                }
                isAnalyzing = false
            }
        } catch {
            await MainActor.run {
                returnItems[index].aiAnalysisResult = "حدث خطأ أثناء تحليل الصور"
                isAnalyzing = false
            }
        }
    }
} 
