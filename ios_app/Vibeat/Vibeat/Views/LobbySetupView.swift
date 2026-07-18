import SwiftUI

struct LobbySetupView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var currentStep = 1
    @State private var locationChoice = "halfway" // "halfway" or "neighborhood"
    
    let occasions = [
        ("Birthday", "🎂"),
        ("Casual", "🍕"),
        ("Meeting", "💼"),
        ("Date", "🌹"),
        ("Party", "🎉")
    ]
    
    var body: some View {
        ZStack {
            // 1. Tabletop Backdrop (Locked, ignores keyboard safe area)
            Image("texture_linen_table")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.keyboard)
            
            // 2. Faint Floating Decorative Music Notes (Mockup parity)
            Group {
                Text("♪")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(.inkPaper.opacity(0.12))
                    .position(x: 60, y: 120)
                Text("♫")
                    .font(.system(size: 22, design: .serif))
                    .foregroundColor(.inkPaper.opacity(0.08))
                    .position(x: 320, y: 150)
                Text("♩")
                    .font(.system(size: 24, design: .serif))
                    .foregroundColor(.inkPaper.opacity(0.1))
                    .position(x: 80, y: 700)
                Text("♬")
                    .font(.system(size: 26, design: .serif))
                    .foregroundColor(.inkPaper.opacity(0.08))
                    .position(x: 290, y: 680)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Editorial Custom Header
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            if currentStep > 1 {
                                currentStep -= 1
                            } else {
                                viewModel.appState = .welcome
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text(currentStep > 1 ? "PREV STEP" : "LEAVE")
                                .font(.uiLabel(size: 11, weight: .bold))
                        }
                        .foregroundColor(.inkPaper.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Simple Progress Indicator
                    Text("TICKET \(currentStep) OF 3")
                        .font(.uiNumber(size: 11, weight: .bold))
                        .foregroundColor(.terracottaOrange)
                        .tracking(2)
                    
                    Spacer()
                    
                    // Invisible spacer for alignment
                    Color.clear.frame(width: 80, height: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Screen Content
                VStack {
                    Spacer()
                    
                    // THE COMPREHENSIVE TICKET HERO (Fills the screen space beautifully)
                    VStack(spacing: 0) {
                        
                        // UPPER TICKET: MASCOT & DIALOGUE (Above perforation line)
                        ZStack(alignment: .topLeading) {
                            // Faded circular postmark stamp in top-left
                            Image("stamp_airmail_invite")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .opacity(0.12)
                                .rotationEffect(.degrees(-12))
                                .offset(x: 10, y: 10)
                            
                            HStack(alignment: .center, spacing: 16) {
                                // Clochey (Stands on light paper, outlines and legs 100% visible!)
                                Image(getMascotForStep())
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 90, height: 90)
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                
                                // Speech bubble pointing to Clochey
                                Text(getSpeechForStep())
                                    .font(.editorialSubheader(size: 13.5))
                                    .foregroundColor(.carbonInk)
                                    .lineSpacing(3)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.carbonInk.opacity(0.15), lineWidth: 1)
                                            .background(Color.inkPaper.opacity(0.95))
                                    )
                                    .overlay(
                                        // Dialogue arrow pointing left to Clochey
                                        Image(systemName: "triangle.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.inkPaper)
                                            .overlay(
                                                Image(systemName: "triangle")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.carbonInk.opacity(0.15))
                                            )
                                            .rotationEffect(.degrees(-90))
                                            .offset(x: -14)
                                        , alignment: .leading
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 20)
                        }
                        
                        // MIDDLE PERFORATION CUTOUTS (Double border ticket stub shape handles this)
                        // It cuts in at 55% height
                        
                        // LOWER TICKET: INPUTS & ACTIONS (Below perforation line)
                        VStack(spacing: 20) {
                            if currentStep == 1 {
                                // STEP 1 CONTENT
                                VStack(spacing: 18) {
                                    CustomUnderlineTextField(
                                        label: "LOBBY TITLE",
                                        placeholder: "Enter lobby title...",
                                        text: $viewModel.lobbyTitle
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("CHOOSE OCCASION")
                                            .font(.uiLabel(size: 10, weight: .bold))
                                            .foregroundColor(.carbonInk.opacity(0.4))
                                            .tracking(1.5)
                                        
                                        // Flow Wrapping Pills (Mockup parity - wraps, no clipping!)
                                        FlowLayout(items: occasions.map { $0.0 }) { name in
                                            let isSelected = viewModel.occasionType == name
                                            let emoji = occasions.first(where: { $0.0 == name })?.1 ?? ""
                                            
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                withAnimation(.spring()) {
                                                    viewModel.occasionType = name
                                                }
                                            }) {
                                                HStack(spacing: 4) {
                                                    Text(emoji)
                                                    Text(name)
                                                        .font(.uiLabel(size: 12, weight: .bold))
                                                        .foregroundColor(isSelected ? .inkPaper : .carbonInk)
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(isSelected ? Color.terracottaOrange : Color.clear)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(isSelected ? Color.terracottaOrange : Color.carbonInk.opacity(0.2), lineWidth: 1)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            } else if currentStep == 2 {
                                // STEP 2 CONTENT
                                VStack(spacing: 18) {
                                    DatePicker("Dinner Timing", selection: Binding(
                                        get: { Date() },
                                        set: { _ in }
                                    ), displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .tint(.terracottaOrange)
                                    .font(.uiLabel(size: 14))
                                    .padding(.horizontal, 4)
                                    
                                    Divider().background(Color.subtleDottedLine)
                                    
                                    CustomUnderlineDecimalField(
                                        label: "INDIVIDUAL BUDGET FLOOR (₹)",
                                        placeholder: "e.g. 500",
                                        value: Binding(
                                            get: { viewModel.minimumBudget },
                                            set: { viewModel.minimumBudget = $0 ?? 500 }
                                        )
                                    )
                                }
                            } else {
                                // STEP 3 CONTENT (Location suggestions)
                                VStack(spacing: 16) {
                                    HStack(spacing: 12) {
                                        LocationTypeButton(
                                            title: "Meet Halfway",
                                            subtitle: "Centroid midpoint",
                                            icon: "person.3.fill",
                                            isSelected: locationChoice == "halfway",
                                            action: {
                                                withAnimation(.spring()) {
                                                    locationChoice = "halfway"
                                                    viewModel.predefinedName = ""
                                                    viewModel.predefinedLat = nil
                                                    viewModel.predefinedLng = nil
                                                }
                                            }
                                        )
                                        
                                        LocationTypeButton(
                                            title: "Lock Area",
                                            subtitle: "Select custom spot",
                                            icon: "mappin.and.ellipse",
                                            isSelected: locationChoice == "neighborhood",
                                            action: {
                                                withAnimation(.spring()) {
                                                    locationChoice = "neighborhood"
                                                }
                                            }
                                        )
                                    }
                                    
                                    if locationChoice == "neighborhood" {
                                        Divider().background(Color.subtleDottedLine)
                                        
                                        if !viewModel.predefinedName.isEmpty {
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.budgetStamp)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("LOCKED LOCATION")
                                                        .font(.uiLabel(size: 9, weight: .bold))
                                                        .foregroundColor(.budgetStamp)
                                                    Text(viewModel.predefinedName)
                                                        .font(.uiLabel(size: 13, weight: .bold))
                                                        .foregroundColor(.carbonInk)
                                                        .lineLimit(1)
                                                }
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    withAnimation(.spring()) {
                                                        viewModel.predefinedName = ""
                                                        viewModel.predefinedLat = nil
                                                        viewModel.predefinedLng = nil
                                                    }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.carbonInk.opacity(0.3))
                                                }
                                            }
                                            .padding(10)
                                            .background(Color.budgetStamp.opacity(0.08))
                                            .cornerRadius(8)
                                        } else {
                                            LocationSearchView(viewModel: viewModel)
                                        }
                                    }
                                }
                            }
                            
                            Spacer(minLength: 10)
                            
                            // BOTTOM FLOW ACTION BUTTON (Contained inside ticket card body)
                            Button(action: {
                                Task {
                                    if currentStep < 3 {
                                        withAnimation(.spring()) {
                                            currentStep += 1
                                        }
                                    } else {
                                        await viewModel.updateSettings()
                                        withAnimation(.spring()) {
                                            viewModel.appState = .lobby
                                        }
                                    }
                                }
                            }) {
                                HStack {
                                    Text(currentStep < 3 ? "CONTINUE ORDER" : "LOCK & OPEN LOBBY")
                                        .font(.uiLabel(size: 13.5, weight: .black))
                                        .foregroundColor(.inkPaper)
                                        .tracking(1.5)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.footnote)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isStepValid() ? Color.terracottaOrange : Color.carbonInk.opacity(0.25))
                                )
                                .shadow(color: .black.opacity(isStepValid() ? 0.2 : 0), radius: 4, x: 0, y: 3)
                            }
                            .disabled(!isStepValid())
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                    }
                    .frame(height: 580) // Set vertical height to fill the screen proportion
                    .ticketStubStyle(cutoutRatio: 0.36, cutoutRadius: 10)
                    .frame(maxWidth: 350)
                    
                    Spacer()
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func isStepValid() -> Bool {
        switch currentStep {
        case 1:
            return !viewModel.lobbyTitle.isEmpty
        case 2:
            return viewModel.minimumBudget >= 300
        case 3:
            return locationChoice == "halfway" || !viewModel.predefinedName.isEmpty
        default:
            return false
        }
    }
    
    private func getSpeechForStep() -> String {
        switch currentStep {
        case 1:
            return "Greetings! Let's get your table set up. First, what should we call this gathering?"
        case 2:
            return "Perfect! And what is the minimum budget floor we should target for everyone's starting value?"
        case 3:
            return "Lastly, where should we meet? Halfway centroid, or should we lock in a specific neighborhood?"
        default:
            return "Preparing details..."
        }
    }
    
    private func getMascotForStep() -> String {
        switch currentStep {
        case 1:
            return "clochey_welcome"
        case 2:
            return "clochey_waiting"
        case 3:
            return "clochey_host"
        default:
            return "clochey_welcome"
        }
    }
}

#Preview {
    LobbySetupView(viewModel: LobbyViewModel())
}
