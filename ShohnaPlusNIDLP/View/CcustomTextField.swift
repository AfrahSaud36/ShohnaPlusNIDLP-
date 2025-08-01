import SwiftUI

struct CcustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(placeholder)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "666666"))
                .padding(.trailing, 5)
            HStack {
                TextField("", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "666666"))
                    .font(.system(size: 18))
                    .padding(.trailing, 15)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
} 
