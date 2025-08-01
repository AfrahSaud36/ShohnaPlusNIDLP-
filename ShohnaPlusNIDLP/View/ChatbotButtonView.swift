import SwiftUI

struct ChatbotButtonView: View {
    @State private var animateAI = true
    @State private var pulse = false
    @State private var rotate1 = false
    @State private var rotate2 = false
    @State private var rotate3 = false
    // Pulse animation toggle
    @State private var pulseAnimation = false
    var body: some View {
        ZStack {
     
            ForEach(0..<3) { i in
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.3, green: 0.1, blue: 0.6).opacity(0.5), // بنفسجي
                                Color.blue.opacity(0.4),
                                Color.white.opacity(0.7),
                                Color(red: 0.3, green: 0.1, blue: 0.6).opacity(0.5)
                            ]),
                            center: .center,
                            angle: .degrees(animateAI ? 360 : 0)
                        ),
                        lineWidth: CGFloat(4 - i)
                    )
                    .frame(width: CGFloat(54 + i*12), height: CGFloat(54 + i*12))
                    .blur(radius: CGFloat(i))
                    .rotationEffect(
                        Angle(degrees:
                            i == 0 ? (rotate1 ? 360 : 0) :
                            i == 1 ? (rotate2 ? -360 : 0) :
                            (rotate3 ? 720 : 0)
                        )
                    )
                    .animation(
                        Animation.linear(duration: Double(2.5 + Double(i))).repeatForever(autoreverses: false),
                        value: i == 0 ? rotate1 : i == 1 ? rotate2 : rotate3
                    )
            }
            // دائرة أساسية مع نبض متدرّج وإضاءة
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color(red: 0.3, green: 0.1, blue: 0.6)
                        ]),
                        center: .center,
                        startRadius: 2,
                        endRadius: 60
                    )
                )
                .frame(width: 54, height: 54)
                .scaleEffect(pulseAnimation ? 1.08 : 0.92)
                .shadow(color: Color(red: 0.3, green: 0.1, blue: 0.6).opacity(0.6), radius: 8)
                .animation(
                    Animation.easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                    value: pulseAnimation
                )

            // حلقة متوهجة خارجية
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 74, height: 74)
                .scaleEffect(pulseAnimation ? 1.4 : 1)
                .opacity(pulseAnimation ? 0 : 1)
                .blur(radius: 1)
                .animation(
                    Animation.easeOut(duration: 1.4).repeatForever(autoreverses: false),
                    value: pulseAnimation
                )

            // نص AI بتدرّج لوني وتأثير توهج
            Text("AI")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.clear)
                .overlay(
                    LinearGradient(
                        colors: [Color.white, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Text("AI")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    )
                )
                .shadow(color: Color.white.opacity(0.8), radius: 4)
                .rotationEffect(Angle(degrees: animateAI ? 360 : 0))
                .animation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false), value: animateAI)
        }
        .frame(width: 70, height: 70)
        .onAppear {
            animateAI = true
            pulse = true
            rotate1 = true
            rotate2 = true
            rotate3 = true
            pulseAnimation = true
        }
    }
}

struct ChatbotButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotButtonView()
    }
} 
