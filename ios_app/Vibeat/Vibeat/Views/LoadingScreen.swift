import SwiftUI
import Combine

struct LoadingScreen: View {
    @State private var steamOffset1 = CGFloat(0)
    @State private var steamOffset2 = CGFloat(0)
    @State private var steamOpacity1 = Double(0.8)
    @State private var steamOpacity2 = Double(0.5)
    
    @State private var activeMessage = "Polishing the cloche..."
    private let statusMessages = [
        "Analyzing player coordinates...",
        "Querying Swiggy Dineout API...",
        "Resolving travel matrix centroids...",
        "Calculating vector vibe embeddings...",
        "Sifting through HDFC card discount rules...",
        "Finalizing the 3D podium reveal..."
    ]
    
    let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image("texture_linen_table")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Animated Steam Puffs + Clochey Mascot
                ZStack {
                    // Steam Puff 1 (Rising bubble)
                    Circle()
                        .fill(Color.inkPaper.opacity(0.15))
                        .frame(width: 24, height: 24)
                        .blur(radius: 4)
                        .offset(x: -15, y: -70 + steamOffset1)
                        .opacity(steamOpacity1)
                    
                    // Steam Puff 2 (Rising bubble)
                    Circle()
                        .fill(Color.inkPaper.opacity(0.1))
                        .frame(width: 32, height: 32)
                        .blur(radius: 6)
                        .offset(x: 20, y: -80 + steamOffset2)
                        .opacity(steamOpacity2)
                    
                    // Clochey Mascot (Thinking State)
                    Image("clochey_thinking")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 180)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 8)
                }
                .onAppear {
                    // Loop steam animations
                    withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        steamOffset1 = -80
                        steamOpacity1 = 0.0
                    }
                    withAnimation(Animation.linear(duration: 2.8).repeatForever(autoreverses: false).delay(0.6)) {
                        steamOffset2 = -90
                        steamOpacity2 = 0.0
                    }
                }
                
                // Status Messages with Crossfade transition
                Text(activeMessage)
                    .font(.editorialSubheader(size: 18))
                    .foregroundColor(.inkPaper.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .id(activeMessage)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .onReceive(timer) { _ in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            activeMessage = statusMessages.randomElement() ?? "Gathering coordinates..."
                        }
                    }
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoadingScreen()
}
