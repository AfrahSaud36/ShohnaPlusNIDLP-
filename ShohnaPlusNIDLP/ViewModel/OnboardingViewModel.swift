import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "O1",
            title: "Welcome to Shahana Plus!",
            subtitle: "AI-powered logistics that connect merchants with top shipping providers.",
            isLastPage: false
        ),
        OnboardingPage(
            imageName: "O2",
            title: "Real-Time AI Tracking",
            subtitle: "Stay informed with real-time package locations and smart delay predictions before they happen.",
            isLastPage: false
        ),
        OnboardingPage(
            imageName: "O3",
            title: "Smarter, Drone-Powered Deliveries",
            subtitle: "AI ensures reliable delivery by solving problems before they occur. With cutting-edge drone technology, enjoy faster, smarter, and more eco-friendly logistics — even in hard-to-reach areas.",
            isLastPage: false
        ),
        OnboardingPage(
            imageName: "O4",
            title: "AI-Powered Image Analysis",
            subtitle: "Automatically detect damaged shipments using AI image analysis on the returns page — speeding up inspections and improving classification accuracy.",
            isLastPage: true
        )
    ]
    
    func skipToLastPage() {
        currentPage = pages.count - 1
    }
    
    func goToNextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        }
    }
} 