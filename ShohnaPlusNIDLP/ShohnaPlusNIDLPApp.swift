//
//  ShohnaPlusNIDLPApp.swift
//  ShohnaPlusNIDLP
//
//  Created by Afrah Alharbi on 03/07/2025.
//

import SwiftUI

@main
struct ShohnaPlusNIDLPApp: App {
    @StateObject var returnDataModel = ReturnDataModel()
    @StateObject var shipmentVM = ShipmentViewModel()

    var body: some Scene {
        WindowGroup {
            OnboardingView(shipmentVM: shipmentVM)
                .environmentObject(returnDataModel)
        }
    }
}
