//
//  SettingsViewModel.swift
//  ShohnaPlusNIDLP
//
//  Created by Afrah Alharbi on 03/07/2025.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settings = Settings(isPushNotificationsEnabled: true, isEmailUpdatesEnabled: false)
    
    func togglePushNotifications() {
        settings.isPushNotificationsEnabled.toggle()
    }
    
    func toggleEmailUpdates() {
        settings.isEmailUpdatesEnabled.toggle()
    }
}
