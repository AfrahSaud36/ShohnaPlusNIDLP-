import Foundation
import SwiftUI

struct Subscription: Identifiable, Codable {
    let id = UUID()
    let name: String
    let arabicName: String
    let description: String
    let arabicDescription: String
    let price: Double
    let currency: String
    let duration: SubscriptionDuration
    let features: [String]
    let arabicFeatures: [String]
    let isPopular: Bool
    let color: String
    let icon: String
    let discountPercentage: Int?
    
    var formattedPrice: String {
        return String(format: "%.0f", price)
    }
    
    var durationText: String {
        switch duration {
        case .monthly:
            return "شهرياً"
        case .yearly:
            return "سنوياً"
        case .lifetime:
            return "مدى الحياة"
        }
    }
}

enum SubscriptionDuration: String, CaseIterable, Codable {
    case monthly = "monthly"
    case yearly = "yearly"
    case lifetime = "lifetime"
}

// Sample subscription data
extension Subscription {
    static let sampleSubscriptions: [Subscription] = [
        Subscription(
            name: "Basic Plan",
            arabicName: "الباقة الأولى",
            description: "For local store owners",
            arabicDescription: "مصممة لأصحاب المتاجر الذين يملكون منتجات ويرغبون في توصيلها للعملاء داخل المملكة",
            price: 49,
            currency: "ريال / شهر",
            duration: .monthly,
            features: [
                "Perfect for local sellers",
                "Direct and easy delivery to customers",
                "Quick subscription from within the app",
                "Simple and clear user interface"
            ],
            arabicFeatures: [
                "مثالية للبائعين المحليين",
                "توصيل مباشر وسهل للعملاء", 
                "اشتراك سريع من داخل التطبيق",
                "واجهة استخدام بسيطة وواضحة"
            ],
            isPopular: false,
            color: "3A1C71",
            icon: "location.fill",
            discountPercentage: nil
        ),
        
        Subscription(
            name: "Advanced Plan", 
            arabicName: "الباقة الثانية",
            description: "For international buyers",
            arabicDescription: "لمن قام بالشراء من مورد خارج السعودية ويبحث عن شركة شحن بحري موثوقة ومناسبة",
            price: 149,
            currency: "ريال / شهر", 
            duration: .monthly,
            features: [
                "Facilitates comparison of maritime shipping companies",
                "Company recommendations based on speed and cost",
                "Detailed information about each company",
                "Smart decision-making support"
            ],
            arabicFeatures: [
                "تسهّل مقارنة شركات الشحن البحري",
                "ترشيح الشركات بناءً على السرعة والتكلفة",
                "معلومات تفصيلية عن كل شركة", 
                "دعم اتخاذ القرار الذكي"
            ],
            isPopular: true,
            color: "6A1B9A",
            icon: "ship.fill",
            discountPercentage: nil
        ),
        
        Subscription(
            name: "Premium Plan",
            arabicName: "الباقة الشاملة", 
            description: "For beginners with no experience",
            arabicDescription: "مصممة للمبتدئين الذين لا يملكون خبرة، وتوفر كل ما يلزم للانطلاق في مجال التجارة",
            price: 299,
            currency: "ريال / شهر",
            duration: .monthly,
            features: [
                "List of best suppliers and factories inside and outside the Kingdom",
                "Display supplier ratings and information", 
                "Ability to negotiate within the app",
                "Direct connection with shipping companies, traders and customers",
                "Service fees calculated after completing the agreement"
            ],
            arabicFeatures: [
                "قائمة بأفضل الموردين والمصانع داخل وخارج المملكة",
                "عرض تقييمات ومعلومات الموردين",
                "إمكانية التفاوض والمناقشة داخل التطبيق",
                "ربط مباشر مع شركات الشحن والتجار والزبائن", 
                "رسوم خدمة تُحتسب بعد إتمام الاتفاق مع التاجر"
            ],
            isPopular: false,
            color: "B39DDB",
            icon: "crown.fill",
            discountPercentage: 15
        )
    ]
} 