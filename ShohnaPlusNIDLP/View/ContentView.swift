

//
//  ContentView.swift
//  oo
//
//  Created by Afrah Alharbi on 01/06/2025.
//

import SwiftUI

struct ContentView: View {
    var shipmentVM: ShipmentViewModel = ShipmentViewModel()
    var body: some View {
        OnboardingView(shipmentVM: shipmentVM)
    }
}

#Preview {
    ContentView(shipmentVM: ShipmentViewModel()).environmentObject(ReturnDataModel())
}
