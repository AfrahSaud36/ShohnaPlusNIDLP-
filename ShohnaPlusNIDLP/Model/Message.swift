//  Message.swift
//  ShohnaChatbot
//
//  Created by Manar Alghamdi on 06/07/2025.
//


import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let role: String
    let message: String
}
