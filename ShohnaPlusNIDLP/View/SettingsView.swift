//
//  SettingsView.swift
//  ShohnaPlusNIDLP
//
//  Created by Afrah Alharbi on 03/07/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Profile Settings")) {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    NavigationLink(destination: Text("Password Settings")) {
                        Label("Change Password", systemImage: "lock.rotation")
                    }
                }

                Section(header: Text("Notifications")) {
                    Toggle(isOn: $viewModel.settings.isPushNotificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell")
                    }
                    Toggle(isOn: $viewModel.settings.isEmailUpdatesEnabled) {
                        Label("Email Updates", systemImage: "envelope")
                    }
                }

                Section(header: Text("Preferences")) {
                    NavigationLink(destination: Text("Language Options")) {
                        Label("Language", systemImage: "globe")
                    }
                }

                Section {
                    Button(action: {
                        // Handle log out
                    }) {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .accentColor(Color("purple"))
    }
}

#Preview {
    SettingsView()
}
