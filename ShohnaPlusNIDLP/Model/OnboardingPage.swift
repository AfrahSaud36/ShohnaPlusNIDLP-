import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
    let isLastPage: Bool
} 