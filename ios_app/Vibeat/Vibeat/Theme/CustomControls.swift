import SwiftUI

// MARK: - Dotted Line Path Shape
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

// MARK: - Custom UI: Underlined Typewriter Text Field
struct CustomUnderlineTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.uiLabel(size: 10, weight: .bold))
                .foregroundColor(.carbonInk.opacity(0.4))
                .tracking(1)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.editorialSubheader(size: 15))
                        .foregroundColor(.carbonInk.opacity(0.25))
                }
                
                TextField("", text: $text)
                    .font(.editorialSubheader(size: 15))
                    .foregroundColor(.carbonInk)
                    .tint(.terracottaOrange)
                    .autocorrectionDisabled()
            }
            
            // Dotted Underline
            Line()
                .stroke(Color.carbonInk.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                .frame(height: 1)
        }
    }
}

// MARK: - Custom UI: Underlined Decimal Field
struct CustomUnderlineDecimalField: View {
    let label: String
    let placeholder: String
    @Binding var value: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.uiLabel(size: 10, weight: .bold))
                .foregroundColor(.carbonInk.opacity(0.4))
                .tracking(1)
            
            ZStack(alignment: .leading) {
                if value == nil {
                    Text(placeholder)
                        .font(.uiNumber(size: 14, weight: .medium))
                        .foregroundColor(.carbonInk.opacity(0.25))
                }
                
                TextField("", value: $value, format: .number)
                    .font(.uiNumber(size: 14, weight: .medium))
                    .foregroundColor(.carbonInk)
                    .tint(.terracottaOrange)
                    .keyboardType(.decimalPad)
            }
            
            // Dotted Underline
            Line()
                .stroke(Color.carbonInk.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                .frame(height: 1)
        }
    }
}

// MARK: - Custom UI: Occasion Button Selector
struct OccasionButton: View {
    let label: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.title3)
                Text(label.uppercased())
                    .font(.uiLabel(size: 11, weight: .black))
                    .foregroundColor(.carbonInk)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        // Oval red pencil marking outline
                        Image(systemName: "circle")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.terracottaOrange)
                            .scaleEffect(x: 2.8, y: 1.1)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom UI: Location Choice Selector Card
struct LocationTypeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .terracottaOrange : .carbonInk.opacity(0.4))
                
                Text(title.uppercased())
                    .font(.uiLabel(size: 12, weight: .bold))
                    .foregroundColor(.carbonInk)
                
                Text(subtitle)
                    .font(.uiLabel(size: 9))
                    .foregroundColor(.carbonInk.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.terracottaOrange : Color.carbonInk.opacity(0.12), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.terracottaOrange.opacity(0.04) : Color.clear)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
