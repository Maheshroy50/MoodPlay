import SwiftUI
// MARK: - Reusable Colors
let salmonBackgroundColor = Color(red: 255/255, green: 192/255, blue: 184/255)
let pinkContourLineColor = Color(red: 242/255, green: 120/255, blue: 107/255)


// MARK: - Animated Lottie Background
struct AnimatedBackground: View {
    var body: some View {
        ZStack {
            // Soft vertical gradient matching MoodPlay tones
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 255/255, green: 222/255, blue: 235/255), Color(red: 207/255, green: 228/255, blue: 255/255)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}


// MARK: - Main Background View
struct WelcomeBackgroundView: View {
    var body: some View {
        ZStack {
            BackgroundLayer()
            
            VStack {
                Spacer()
            }
            .overlay(
                VStack {
                    LoginContent()
                        .padding(.bottom, 60) // Adjust this value to fine-tune position
                },
                alignment: .bottom
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Background Layer
struct BackgroundLayer: View {
    var body: some View {
        ZStack {
            // Background gradient layer
            AnimatedBackground()
                .ignoresSafeArea()

            // Slightly reduce the white overlay to reveal the background better
            Color.white.opacity(0.25)
                .ignoresSafeArea()

            WhiteWaveShape()
                .fill(Color.white)
                .ignoresSafeArea()
                .overlay(
                    ContourLinesShape()
                        .stroke(pinkContourLineColor, lineWidth: 2)
                        .ignoresSafeArea()
                )
        }
    }
}

// MARK: - Static Login Content Layer
struct LoginContent: View {
    var body: some View {
        VStack {
            Text("Login Buttons Here")
                .padding()
        }
    }
}


// MARK: - Custom Shape for the White Wave
struct WhiteWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start from mid-left edge
        path.move(to: CGPoint(x: rect.minX, y: rect.height * 0.45))
        
        // Curve across the screen to create the top boundary of the shape
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.35),
                      control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.2),
                      control2: CGPoint(x: rect.width * 0.8, y: rect.height * 0.55))
        
        // Add lines to the bottom corners to close the shape
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}


// MARK: - Custom Shape for the Topographic Contour Lines
struct ContourLinesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Each "move" and "addCurve" creates one of the pink lines.
        // These are approximations of the lines in your image.
        
        // Line 1 (Top-most)
        path.move(to: CGPoint(x: rect.minX, y: rect.height * 0.5))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.4),
                      control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.25),
                      control2: CGPoint(x: rect.width * 0.8, y: rect.height * 0.6))

        // Line 2
        path.move(to: CGPoint(x: rect.minX, y: rect.height * 0.65))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.55),
                      control1: CGPoint(x: rect.width * 0.25, y: rect.height * 0.5),
                      control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.75))
        
        // Line 3 (Middle)
        path.move(to: CGPoint(x: rect.minX, y: rect.height * 0.85))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.75),
                      control1: CGPoint(x: rect.width * 0.2, y: rect.height * 0.75),
                      control2: CGPoint(x: rect.width * 0.6, y: rect.height * 0.9))
        
        // Line 4 (Bottom-most)
        path.move(to: CGPoint(x: rect.minX, y: rect.height * 1.05))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.95),
                      control1: CGPoint(x: rect.width * 0.25, y: rect.height * 1),
                      control2: CGPoint(x: rect.width * 0.55, y: rect.height * 1.05))
        
        return path
    }
}


// MARK: - Preview
#Preview {
    WelcomeBackgroundView()
}
