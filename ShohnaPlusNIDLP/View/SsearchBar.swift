import SwiftUI

struct SsearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var showingScanner = false
    @State private var scannedCode = ""
    
    var body: some View {
        HStack {
            Button(action: {
                showingScanner = true
            }) {
                Image(systemName: "barcode.viewfinder")
                    .foregroundColor(.black)
            }
            ZStack(alignment: .trailing) {
                if text.isEmpty {
                    Text("ابحث عن رقم الشحنة")
                        .foregroundColor(.black.opacity(0.6))
                }
                TextField("", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.black)
                    .focused($isFocused)
                    .submitLabel(.search)
            }
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.black.opacity(0.5))
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .sheet(isPresented: $showingScanner) {
            BarcodeScannerView(scannedCode: $scannedCode)
        }
        .onChange(of: scannedCode) { newValue in
            if !newValue.isEmpty {
                text = newValue
            }
        }
    }
} 
