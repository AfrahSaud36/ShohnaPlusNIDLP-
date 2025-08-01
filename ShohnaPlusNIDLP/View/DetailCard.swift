import SwiftUI

struct DetailCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Text(value)
                    .font(.headline)
                    .foregroundColor(.black)
                Image(systemName: icon)
                    .foregroundColor(.black)
            }
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
} 
