import SwiftUI

// MARK: - Mathematically Perfect Ticket Shape
struct TicketStubShape: Shape {
    var cutoutRatio: CGFloat = 0.55 // Y location of the side notches
    var cutoutRadius: CGFloat = 12.0 // Radius of the side notches
    var cornerRadius: CGFloat = 14.0 // Inward vintage corner radius
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        let cutoutY = h * cutoutRatio
        
        // 1. Move to start point: top edge, just after the top-left curve
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // 2. Top border line
        path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))
        
        // 3. Top-Right inward corner arc (centered at the actual corner)
        path.addArc(
            center: CGPoint(x: w, y: 0),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 90),
            clockwise: true // In SwiftUI, clockwise: true draws counter-clockwise in Cartesian terms (180 -> 90)
        )
        
        // 4. Upper right border line
        path.addLine(to: CGPoint(x: w, y: cutoutY - cutoutRadius))
        
        // 5. Right edge inward notch arc (centered on the right edge)
        path.addArc(
            center: CGPoint(x: w, y: cutoutY),
            radius: cutoutRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 90),
            clockwise: true // 270 -> 180 -> 90 (curves inward to the left)
        )
        
        // 6. Lower right border line
        path.addLine(to: CGPoint(x: w, y: h - cornerRadius))
        
        // 7. Bottom-Right inward corner arc (centered at bottom-right corner)
        path.addArc(
            center: CGPoint(x: w, y: h),
            radius: cornerRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 180),
            clockwise: true // 270 -> 180
        )
        
        // 8. Bottom border line
        path.addLine(to: CGPoint(x: cornerRadius, y: h))
        
        // 9. Bottom-Left inward corner arc (centered at bottom-left corner)
        path.addArc(
            center: CGPoint(x: 0, y: h),
            radius: cornerRadius,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 270),
            clockwise: true // 0 -> 270
        )
        
        // 10. Lower left border line
        path.addLine(to: CGPoint(x: 0, y: cutoutY + cutoutRadius))
        
        // 11. Left edge inward notch arc (centered on the left edge)
        path.addArc(
            center: CGPoint(x: 0, y: cutoutY),
            radius: cutoutRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 270),
            clockwise: true // 90 -> 0 -> 270 (curves inward to the right)
        )
        
        // 12. Upper left border line
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // 13. Top-Left inward corner arc (centered at top-left corner)
        path.addArc(
            center: CGPoint(x: 0, y: 0),
            radius: cornerRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 0),
            clockwise: true // 90 -> 0
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Double-Border Ticket Modifier
struct TicketStubModifier: ViewModifier {
    var cutoutRatio: CGFloat = 0.55
    var cutoutRadius: CGFloat = 12.0
    var cornerRadius: CGFloat = 14.0
    
    func body(content: Content) -> some View {
        content
            .background(
                TicketStubShape(cutoutRatio: cutoutRatio, cutoutRadius: cutoutRadius, cornerRadius: cornerRadius)
                    .fill(Color.inkPaper)
                    .overlay(
                        // Distressed paper texture overlay
                        Image("texture_recycled_paper")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blendMode(.multiply)
                            .opacity(0.12)
                    )
            )
            // Clip content to the perfect shape bounds so nothing cuts out of the curved edges
            .clipShape(TicketStubShape(cutoutRatio: cutoutRatio, cutoutRadius: cutoutRadius, cornerRadius: cornerRadius))
            .overlay(
                // 1. Thin Outer Border
                TicketStubShape(cutoutRatio: cutoutRatio, cutoutRadius: cutoutRadius, cornerRadius: cornerRadius)
                    .stroke(Color.carbonInk.opacity(0.18), lineWidth: 1.5)
            )
            .overlay(
                // 2. Classy Inner Offset Border (Offset double-border vintage look)
                TicketStubShape(cutoutRatio: cutoutRatio, cutoutRadius: cutoutRadius, cornerRadius: cornerRadius)
                    .stroke(Color.carbonInk.opacity(0.08), lineWidth: 1.2)
                    .padding(3.5)
                    .clipShape(TicketStubShape(cutoutRatio: cutoutRatio, cutoutRadius: cutoutRadius, cornerRadius: cornerRadius))
            )
            .overlay(
                // 3. Perforation dashed line connecting side notches
                GeometryReader { geo in
                    Path { path in
                        let y = geo.size.height * cutoutRatio
                        path.move(to: CGPoint(x: cutoutRadius + 3, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width - cutoutRadius - 3, y: y))
                    }
                    .stroke(
                        Color.carbonInk.opacity(0.15),
                        style: StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [4, 5])
                    )
                }
            )
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func ticketStubStyle(cutoutRatio: CGFloat = 0.55, cutoutRadius: CGFloat = 12.0, cornerRadius: CGFloat = 14.0) -> some View {
        self.modifier(TicketStubModifier(cutoutRatio: cutoutRatio, cutoutRadius: cutoutRadius, cornerRadius: cornerRadius))
    }
}

// MARK: - Dedicated Empty Ticket Preview (Mockup Isolation View)
struct EmptyTicketPreview: View {
    var body: some View {
        ZStack {
            // Tabletop background
            Color(red: 0.12, green: 0.12, blue: 0.12)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Empty Ticket Stub Container
                VStack {
                    Spacer()
                    Text("TICKET COMPONENT")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.carbonInk.opacity(0.3))
                        .tracking(3)
                    Spacer()
                }
                .frame(width: 330, height: 560)
                .ticketStubStyle(cutoutRatio: 0.70, cutoutRadius: 10, cornerRadius: 12)
            }
        }
    }
}

#Preview {
    EmptyTicketPreview()
}
