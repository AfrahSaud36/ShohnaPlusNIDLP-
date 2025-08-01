import SwiftUI

struct ShipmentCard: View {
    let shipment: Shipment
    
    var body: some View {
        NavigationLink(destination: ShipmentDetailView(shipment: shipment)) {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(width: 370, height: 85)
                .overlay(
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(hex: "666666"))
                        Spacer(minLength: 135)
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(shipment.trackingNumber)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .padding(.bottom, 5)
                            HStack(spacing: 4) {
                                Text(shipment.deliveryAddressFrom)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "666666"))
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.green)
                                Text(shipment.deliveryAddress)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "666666"))
                            }
                            .environment(\.layoutDirection, .leftToRight)
                            HStack(spacing: 5) {
                                Text(shipment.shipmentDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "666666"))
                                Image(systemName: "clock")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer(minLength: 5)
                        Circle()
                            .fill(Color(hex: "F5F5F5"))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image("shiplogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            )
                    }
                    .padding(.horizontal, 25)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 
