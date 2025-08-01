//
//  ChatViewModel.swift
//  ShohnaChatbot
//
//  Created by Manar Alghamdi on 06/07/2025.
//


import Foundation
import SwiftUI

class ChatbotViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var chatHistory: [Message] = []
    @Published var isLoading: Bool = false

    func sendMessage() {
        let userMsg = Message(role: "USER", message: input)
        chatHistory.append(userMsg)
        input = ""
        isLoading = true

        CohereAPI.shared.sendMessage(userMsg.message, chatHistory: chatHistory) { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let text = response {
                    let botMsg = Message(role: "CHATBOT", message: text)
                    self?.chatHistory.append(botMsg)
                } else {
                    self?.chatHistory.append(Message(role: "CHATBOT", message: "حدث خطأ."))
                }
            }
        }
    }
}



class CohereAPI {
    static let shared = CohereAPI()
    private init() {}

    func sendMessage(_ userMessage: String, chatHistory: [Message], completion: @escaping (String?) -> Void) {
        let apiKeys = [
            "ZM5qpBwp8MXtDCg17XyQbGfSF3a6wEWkZHmEbvJR",
            "SECOND_API_KEY",
            "THIRD_API_KEY"
        ]

        tryNextAPI(from: apiKeys, index: 0, userMessage: userMessage, chatHistory: chatHistory, completion: completion)
    }

    private func tryNextAPI(from keys: [String], index: Int, userMessage: String, chatHistory: [Message], completion: @escaping (String?) -> Void) {
        guard index < keys.count else {
            completion("كل المفاتيح فشلت. الرجاء المحاولة لاحقًا.")
            return
        }

        let apiKey = keys[index]
        guard let url = URL(string: "https://api.cohere.ai/v1/chat") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "model": "command-r-plus",
            "message": userMessage,
            "temperature": 0.7,
            "chat_history": [
                [
                    "role": "SYSTEM",
                    "message": """
                    أنت مساعد ذكي. لا تجيب إلا على الأسئلة المتعلقة بالمواضيع التالية فقط:
                    - أفضل شركات الشحن
                    - أرخص شركات الشحن
                    - عن المنصة، ما هي؟
                    - ما الذي تتميز به المنصة؟
                    - الخدمات التي نقدمها
                    - أسعار الشحن

                    إذا تم سؤالك عن أي شيء خارج هذه المواضيع، قل فقط: "هذا خارج خبرتي."
                    """
                ]
            ] + chatHistory.map { ["role": $0.role, "message": $0.message] }
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion("تعذر تجهيز الطلب.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let text = json["text"] as? String {
                completion(text)
            } else {
                print("🔁 Trying next key due to error or bad response: \(error?.localizedDescription ?? "unknown")")
                self.tryNextAPI(from: keys, index: index + 1, userMessage: userMessage, chatHistory: chatHistory, completion: completion)
            }
        }.resume()
    }
}

