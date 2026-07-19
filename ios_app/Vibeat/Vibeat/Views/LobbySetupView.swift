import SwiftUI
import MapKit

// MARK: - Simple Location Search Sheet (no map)
struct LocationPickerSheet: View {
    @ObservedObject var viewModel: LobbyViewModel
    @Environment(\.dismiss) var dismiss

    @StateObject private var searchService = LocationSearchService()
    @FocusState private var isSearchFocused: Bool

    // Confirmed selection
    @State private var selectedName: String = ""
    @State private var selectedSubtitle: String = ""
    @State private var selectedLat: Double? = nil
    @State private var selectedLng: Double? = nil

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ──────────────────────────────────────────────
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.carbonInk)
                        .frame(width: 40, height: 40)
                        .background(Color.carbonInk.opacity(0.06))
                        .clipShape(Circle())
                }

                Text("Choose Location")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.carbonInk)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // ── Search Bar ─────────────────────────────────────────
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.carbonInk.opacity(0.4))
                    .font(.system(size: 16, weight: .semibold))

                TextField("Search neighbourhood, city...", text: $searchService.searchQuery)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.carbonInk)
                    .tint(.terracottaOrange)
                    .focused($isSearchFocused)
                    .autocorrectionDisabled()
                    .submitLabel(.search)

                if !searchService.searchQuery.isEmpty {
                    Button(action: {
                        searchService.searchQuery = ""
                        selectedName = ""
                        selectedLat = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.carbonInk.opacity(0.3))
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .background(Color.carbonInk.opacity(0.05))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSearchFocused ? Color.terracottaOrange.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
            .padding(.horizontal, 20)
            .animation(.easeInOut(duration: 0.2), value: isSearchFocused)

            // ── Results List ───────────────────────────────────────
            if !searchService.completions.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(searchService.completions, id: \.self) { result in
                            Button(action: {
                                Task { await selectResult(result) }
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.terracottaOrange.opacity(0.10))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.terracottaOrange)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(result.title)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.carbonInk)
                                            .multilineTextAlignment(.leading)

                                        if !result.subtitle.isEmpty {
                                            Text(result.subtitle)
                                                .font(.system(size: 12, design: .rounded))
                                                .foregroundColor(.carbonInk.opacity(0.45))
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                    Spacer()

                                    Image(systemName: "arrow.up.left")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.carbonInk.opacity(0.25))
                                }
                                .padding(.vertical, 13)
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())

                            if result != searchService.completions.last {
                                Divider()
                                    .padding(.leading, 72)
                                    .opacity(0.5)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else if searchService.searchQuery.isEmpty {
                // Empty state hint
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "location.magnifyingglass")
                        .font(.system(size: 44))
                        .foregroundColor(.carbonInk.opacity(0.15))
                    Text("Type to search for a location")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.carbonInk.opacity(0.3))
                    Spacer()
                }
            } else {
                // Searching / no results
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView()
                        .tint(.terracottaOrange)
                    Text("Looking up \"\(searchService.searchQuery)\"…")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.carbonInk.opacity(0.35))
                    Spacer()
                }
            }

            // ── Confirm Button (shows after a selection) ──────────
            if selectedLat != nil {
                VStack(spacing: 8) {
                    Divider().opacity(0.4)

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.terracottaOrange.opacity(0.10))
                                .frame(width: 40, height: 40)
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.terracottaOrange)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedName)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.carbonInk)
                                .lineLimit(1)
                            if !selectedSubtitle.isEmpty {
                                Text(selectedSubtitle)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.carbonInk.opacity(0.45))
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Button(action: confirmSelection) {
                        Text("CONFIRM LOCATION")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.inkPaper)
                            .tracking(1.5)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.terracottaOrange)
                            )
                            .shadow(color: Color.terracottaOrange.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .background(Color.inkPaper)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color.inkPaper.ignoresSafeArea())
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedLat != nil)
        .onAppear {
            isSearchFocused = true
            // Pre-fill existing selection if any
            if let lat = viewModel.predefinedLat, let lng = viewModel.predefinedLng {
                selectedName = viewModel.predefinedName
                selectedLat = lat
                selectedLng = lng
            }
        }
    }

    // ── Helpers ────────────────────────────────────────────────────

    private func selectResult(_ completion: MKLocalSearchCompletion) async {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            if let item = response.mapItems.first {
                let coord = item.placemark.coordinate
                await MainActor.run {
                    selectedName = completion.title
                    selectedSubtitle = completion.subtitle
                    selectedLat = coord.latitude
                    selectedLng = coord.longitude
                    searchService.searchQuery = completion.title
                    isSearchFocused = false
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        } catch {
            print("Location search failed: \(error.localizedDescription)")
        }
    }

    private func confirmSelection() {
        guard let lat = selectedLat, let lng = selectedLng else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.predefinedName = selectedName
        viewModel.predefinedLat = lat
        viewModel.predefinedLng = lng
        dismiss()
    }
}

// MARK: - Main Lobby Setup View
struct LobbySetupView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var currentStep = 1
    @State private var locationChoice = "halfway"
    @State private var dinnerDate = Date()
    @State private var isSealStamped = false
    @State private var showingMapPicker = false
    
    // Robust local state to prevent SwiftUI cursor jump and deletion resets
    @State private var budgetInput = "500"
    
    // Occasions mapped to stamp assets
    let occasions = [
        ("Birthday", "stamp_birthday"),
        ("Celebration", "stamp_celebration"),
        ("Hangout", "stamp_hangout"),
        ("Meetup", "stamp_meetup"),
        ("Family", "stamp_family"),
        ("Date", "stamp_date")
    ]
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: dinnerDate)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: dinnerDate)
    }
    
    var body: some View {
        ZStack {
            // Solid dark slate background
            Color(red: 0.08, green: 0.10, blue: 0.13)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // DYNAMIC TICKET STUB CONTAINER
                VStack(spacing: 0) {
                    GeometryReader { cardGeo in
                        VStack(spacing: 0) {
                            
                            // ==========================================
                            // UPPER TICKET AREA (Exactly 70% of Card Height)
                            // ==========================================
                            VStack(alignment: .leading, spacing: 0) {
                                if currentStep < 4 {
                                    // ACTIVE FORM STAGES (Steps 1–3)
                                    VStack(alignment: .leading, spacing: 0) {
                                        Spacer() // Push mascot block down from upper edge
                                        
                                        // Mascot Dialogue Block
                                        HStack(alignment: .center, spacing: 14) {
                                            Image(getMascotForStep())
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 80, height: 80)
                                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                            
                                            Text(getSpeechForStep())
                                                .font(.editorialSubheader(size: 13))
                                                .foregroundColor(.carbonInk)
                                                .lineSpacing(3)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.carbonInk.opacity(0.15), lineWidth: 1)
                                                        .background(Color.inkPaper.opacity(0.95))
                                                )
                                                .overlay(
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
                                        
                                        Spacer() // Spacing between Mascot and Form Panel
                                        
                                        // Dynamic input selectors
                                        VStack(spacing: 0) {
                                            if currentStep == 1 {
                                                // STEP 1: Integrated Input Panel
                                                VStack(alignment: .leading, spacing: 18) {
                                                    // Field 1: Title
                                                    VStack(alignment: .leading, spacing: 6) {
                                                        Text("GATHERING TITLE")
                                                            .font(.uiLabel(size: 10, weight: .bold))
                                                            .foregroundColor(.carbonInk.opacity(0.4))
                                                            .tracking(1.5)
                                                        
                                                        ZStack(alignment: .leading) {
                                                            if viewModel.lobbyTitle.isEmpty {
                                                                Text("e.g. Aryan's Birthday...")
                                                                    .font(.custom("Georgia-Bold", size: 18))
                                                                    .foregroundColor(.carbonInk.opacity(0.45)) // Darker placeholder
                                                            }
                                                            TextField("", text: $viewModel.lobbyTitle)
                                                                .font(.custom("Georgia-Bold", size: 18))
                                                                .foregroundColor(.carbonInk)
                                                                .tint(.terracottaOrange)
                                                                .autocorrectionDisabled()
                                                        }
                                                    }
                                                    
                                                    Divider().background(Color.carbonInk.opacity(0.08))
                                                    
                                                    // Field 2: Date & Time Selector (Side-by-side native pills)
                                                    VStack(alignment: .leading, spacing: 8) {
                                                        Text("DATE & TIME OF GATHERING")
                                                            .font(.uiLabel(size: 10, weight: .bold))
                                                            .foregroundColor(.carbonInk.opacity(0.4))
                                                            .tracking(1.5)
                                                        
                                                        HStack(spacing: 8) {
                                                            DatePicker("", selection: $dinnerDate, displayedComponents: .date)
                                                                .datePickerStyle(.compact)
                                                                .tint(.terracottaOrange)
                                                                .accentColor(.terracottaOrange)
                                                                .colorScheme(.light) // Force light style for dark text
                                                                .labelsHidden()
                                                            
                                                            Text("at")
                                                                .font(.uiLabel(size: 13, weight: .bold))
                                                                .foregroundColor(.carbonInk.opacity(0.4))
                                                            
                                                            DatePicker("", selection: $dinnerDate, displayedComponents: .hourAndMinute)
                                                                .datePickerStyle(.compact)
                                                                .tint(.terracottaOrange)
                                                                .accentColor(.terracottaOrange)
                                                                .colorScheme(.light) // Force light style for dark text
                                                                .labelsHidden()
                                                            
                                                            Spacer()
                                                        }
                                                    }
                                                    
                                                    Divider().background(Color.carbonInk.opacity(0.08))
                                                    
                                                    // Field 3: Budget Floor
                                                    VStack(alignment: .leading, spacing: 6) {
                                                        Text("INDIVIDUAL BUDGET FLOOR (₹)")
                                                            .font(.uiLabel(size: 10, weight: .bold))
                                                            .foregroundColor(.carbonInk.opacity(0.4))
                                                            .tracking(1.5)
                                                        
                                                        TextField("e.g. 500", text: $budgetInput)
                                                            .font(.uiNumber(size: 16, weight: .semibold))
                                                            .foregroundColor(.carbonInk)
                                                            .tint(.terracottaOrange)
                                                            .keyboardType(.numberPad)
                                                            .onChange(of: budgetInput) { _, newValue in
                                                                let filtered = newValue.filter { $0.isNumber }
                                                                budgetInput = filtered
                                                                if let parsed = Double(filtered) {
                                                                    viewModel.minimumBudget = parsed
                                                                }
                                                            }
                                                    }
                                                }
                                                .padding(18)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.carbonInk.opacity(0.08), lineWidth: 1)
                                                        .background(Color.inkPaper.opacity(0.6))
                                                )
                                            } else if currentStep == 2 {
                                                // STEP 2: Custom Stamp Selection with selection rings
                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text("SELECT GATHERING VIBE")
                                                        .font(.uiLabel(size: 13, weight: .black))
                                                        .foregroundColor(.carbonInk.opacity(0.6))
                                                        .tracking(1.8)
                                                    
                                                    HStack {
                                                        OccasionStampButton(name: "Birthday", assetName: "stamp_birthday", isSelected: viewModel.occasionType == "Birthday") {
                                                            viewModel.occasionType = "Birthday"
                                                        }
                                                        Spacer()
                                                        OccasionStampButton(name: "Celebration", assetName: "stamp_celebration", isSelected: viewModel.occasionType == "Celebration") {
                                                            viewModel.occasionType = "Celebration"
                                                        }
                                                        Spacer()
                                                        OccasionStampButton(name: "Hangout", assetName: "stamp_hangout", isSelected: viewModel.occasionType == "Hangout") {
                                                            viewModel.occasionType = "Hangout"
                                                        }
                                                    }
                                                    
                                                    HStack {
                                                        OccasionStampButton(name: "Meetup", assetName: "stamp_meetup", isSelected: viewModel.occasionType == "Meetup") {
                                                            viewModel.occasionType = "Meetup"
                                                        }
                                                        Spacer()
                                                        OccasionStampButton(name: "Family", assetName: "stamp_family", isSelected: viewModel.occasionType == "Family") {
                                                            viewModel.occasionType = "Family"
                                                        }
                                                        Spacer()
                                                        OccasionStampButton(name: "Date", assetName: "stamp_date", isSelected: viewModel.occasionType == "Date") {
                                                            viewModel.occasionType = "Date"
                                                        }
                                                    }
                                                }
                                                .padding(.vertical, 12)
                                            } else if currentStep == 3 {
                                                // STEP 3: Location target selection
                                                VStack(spacing: 16) {
                                                    HStack(spacing: 12) {
                                                        LocationTypeButton(
                                                            title: "Meet Halfway",
                                                            subtitle: "We'll find the middle",
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
                                                        
                                                        Button(action: {
                                                            showingMapPicker = true
                                                        }) {
                                                            HStack(spacing: 10) {
                                                                Image(systemName: viewModel.predefinedName.isEmpty ? "magnifyingglass" : "checkmark.circle.fill")
                                                                    .font(.system(size: 15, weight: .semibold))
                                                                    .foregroundColor(viewModel.predefinedName.isEmpty ? .carbonInk.opacity(0.4) : .terracottaOrange)
                                                                
                                                                Text(viewModel.predefinedName.isEmpty ? "Search location..." : viewModel.predefinedName)
                                                                    .font(.system(size: 15, weight: viewModel.predefinedName.isEmpty ? .regular : .semibold, design: .rounded))
                                                                    .foregroundColor(viewModel.predefinedName.isEmpty ? .carbonInk.opacity(0.4) : .carbonInk)
                                                                    .lineLimit(1)
                                                                
                                                                Spacer()
                                                                
                                                                if !viewModel.predefinedName.isEmpty {
                                                                    Button(action: {
                                                                        viewModel.predefinedName = ""
                                                                        viewModel.predefinedLat = nil
                                                                        viewModel.predefinedLng = nil
                                                                    }) {
                                                                        Image(systemName: "xmark.circle.fill")
                                                                            .font(.system(size: 16))
                                                                            .foregroundColor(.carbonInk.opacity(0.25))
                                                                    }
                                                                }
                                                            }
                                                            .padding(.vertical, 12)
                                                            .padding(.horizontal, 14)
                                                            .background(.ultraThinMaterial)
                                                            .cornerRadius(12)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .stroke(
                                                                        viewModel.predefinedName.isEmpty
                                                                            ? Color.carbonInk.opacity(0.10)
                                                                            : Color.terracottaOrange.opacity(0.4),
                                                                        lineWidth: 1.2
                                                                    )
                                                            )
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                        .sheet(isPresented: $showingMapPicker) {
                                                            LocationPickerSheet(viewModel: viewModel)
                                                        }
                                                    }
                                                }
                                                .padding(.vertical, 8)
                                            }
                                        }
                                        
                                        Spacer() // Push panel away from perforation line
                                    }
                                    .padding(.horizontal, 20)
                                } else {
                                    editorialTicket(geo: cardGeo)
                                }
                            }
                            .frame(height: cardGeo.size.height * 0.70, alignment: .top)
                            
                            // ==========================================
                            // LOWER TICKET AREA (Exactly 30% of Card Height)
                            // ==========================================
                            VStack {
                                Spacer()
                                
                                if currentStep < 4 {
                                    // Setup Action Button (Styled as "NEXT" / "CREATE TABLE")
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                            currentStep += 1
                                        }
                                    }) {
                                        Text(currentStep == 3 ? "CREATE TABLE" : "NEXT")
                                            .font(.uiLabel(size: 14, weight: .black))
                                            .foregroundColor(.inkPaper)
                                            .tracking(1.5)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 15)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(isStepValid() ? Color.terracottaOrange : Color.carbonInk.opacity(0.25))
                                            )
                                            .shadow(color: .black.opacity(isStepValid() ? 0.2 : 0), radius: 4, x: 0, y: 3)
                                    }
                                    .disabled(!isStepValid())
                                    .padding(.horizontal, 24)
                                } else {
                                    // Step 4: CREATE LOBBY button
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        Task {
                                            
                                            let hostPlayer = Player(
                                                name: "Host (You)",
                                                lat: 28.6139,
                                                lng: 77.2090,
                                                budget: viewModel.minimumBudget,
                                                cuisines: ["Italian"],
                                                cards: ["HDFC"],
                                                wantsAlcohol: true,
                                                atmosphere: "lively",
                                                specificDish: nil,
                                                isReady: true
                                            )
                                            viewModel.activePlayers.append(hostPlayer)
                                            viewModel.isTicketSubmitted = false
                                            withAnimation(.spring()) {
                                                viewModel.path.append(.lobby)
                                            }
                                        }
                                    }) {
                                        Text("CREATE LOBBY")
                                            .font(.uiLabel(size: 14, weight: .black))
                                            .foregroundColor(.inkPaper)
                                            .tracking(1.5)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 15)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.terracottaOrange)
                                            )
                                            .shadow(color: Color.terracottaOrange.opacity(0.4), radius: 6, x: 0, y: 4)
                                    }
                                    .padding(.horizontal, 24)
                                }
                                
                                Spacer()
                            }
                            .frame(height: cardGeo.size.height * 0.30)
                            
                        }
                    }
                }
                .ticketStubStyle(cutoutRatio: 0.70, cutoutRadius: 10)
                .frame(height: UIScreen.main.bounds.height * 0.74) // Tall ticket aspect ratio
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                
                Spacer()
            }
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    if currentStep > 1 {
                        withAnimation(.spring()) {
                            currentStep -= 1
                        }
                    } else {
                        // Pop from NavigationStack path
                        withAnimation {
                            _ = viewModel.path.popLast()
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundColor(.terracottaOrange)
                }
            }
        }
    }
    
    private func isStepValid() -> Bool {
        switch currentStep {
        case 1:
            return !viewModel.lobbyTitle.isEmpty && !budgetInput.isEmpty
        case 2:
            return !viewModel.occasionType.isEmpty
        case 3:
            return locationChoice == "halfway" || !viewModel.predefinedName.isEmpty
        default:
            return false
        }
    }
    
    private func getSpeechForStep() -> String {
        switch currentStep {
        case 1:
            return "Greetings! Let's get your table set up. What is the name of this gathering?"
        case 2:
            return "Perfect! And what is the occasion for this dining table?"
        case 3:
            return "Lastly, where should we meet? Let us find the middle, or lock in a specific spot?"
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

    // ── Fully printed editorial ticket (Step 4 upper area) ──────────
    @ViewBuilder
    private func editorialTicket(geo: GeometryProxy) -> some View {
        let cardW = geo.size.width
        let cardH = geo.size.height

        VStack(alignment: .leading, spacing: 0) {

            // Header row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("VIBEAT")
                        .font(.system(size: cardW * 0.055, weight: .black, design: .rounded))
                        .foregroundColor(.terracottaOrange)
                        .tracking(4)
                    Text("DINING PASS")
                        .font(.system(size: cardW * 0.030, weight: .semibold, design: .monospaced))
                        .foregroundColor(.carbonInk.opacity(0.35))
                        .tracking(3)
                }
                Spacer()
                Image("clochey_host")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: cardW * 0.22)
            }
            .padding(.horizontal, cardW * 0.07)
            .padding(.top, cardH * 0.04)

            // Thin separator
            Rectangle()
                .fill(Color.carbonInk.opacity(0.12))
                .frame(height: 1)
                .padding(.horizontal, cardW * 0.07)
                .padding(.vertical, cardH * 0.025)

            // Large serif headline
            Text(viewModel.lobbyTitle.uppercased())
                .font(.custom("Georgia-Bold", size: cardW * 0.115))
                .foregroundColor(.carbonInk)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, cardW * 0.07)

            // Orange + grey accent rule
            HStack(spacing: 4) {
                Rectangle().fill(Color.terracottaOrange).frame(width: cardW * 0.10, height: 3)
                Rectangle().fill(Color.carbonInk.opacity(0.10)).frame(height: 1)
            }
            .padding(.horizontal, cardW * 0.07)
            .padding(.vertical, cardH * 0.022)

            // Detail rows (spaced out more to fill empty space nicely)
            VStack(alignment: .leading, spacing: cardH * 0.035) {
                ticketRow(label: "OCCASION", value: viewModel.occasionType, cardW: cardW, accent: false)
                ticketRow(label: "DATE", value: formattedDate, cardW: cardW, accent: false)
                ticketRow(label: "TIME", value: formattedTime, cardW: cardW, accent: false)
                ticketRow(label: "BUDGET", value: "INR \(Int(viewModel.minimumBudget))+ per head", cardW: cardW, accent: false)
                ticketRow(label: "DESTINATION",
                          value: viewModel.predefinedName.isEmpty ? "Meet Halfway" : viewModel.predefinedName,
                          cardW: cardW, accent: true)
            }
            .padding(.horizontal, cardW * 0.07)

            Spacer()
        }
    }

    // ── Ticket detail row: label + value ────────────────────────────
    @ViewBuilder
    private func ticketRow(label: String, value: String, cardW: CGFloat, accent: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: cardW * 0.030, weight: .bold, design: .monospaced))
                .foregroundColor(.carbonInk.opacity(0.4))
                .tracking(2.5)
            Text(value.uppercased())
                .font(.system(size: cardW * 0.046, weight: accent ? .black : .bold, design: .monospaced))
                .foregroundColor(accent ? .terracottaOrange : .carbonInk)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }
}

// MARK: - Custom UI: Occasion Stamp Option Button
struct OccasionStampButton: View {
    let name: String
    let assetName: String
    let isSelected: Bool
    let action: () -> Void
    
    // Dynamic size scaling based on asset shape
    private var imageSize: CGFloat {
        if assetName == "stamp_celebration" {
            return 82 // Zoomed champagne toast
        } else if assetName == "stamp_hangout" {
            return 82 // Zoomed pizza
        } else {
            return 74 // Default balanced size
        }
    }
    
    // Custom offset to visually align/center assets that have shadows or off-center perspective
    private var imageOffset: CGFloat {
        if assetName == "stamp_hangout" {
            return -4 // Shift pizza up slightly to counter perspective shadow imbalance
        } else {
            return 0
        }
    }
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Tactile Grey Outer Stroke (always visible to indicate tappability)
                    Circle()
                        .stroke(Color.carbonInk.opacity(0.08), lineWidth: 1.5)
                        .frame(width: 86, height: 86)
                        .scaleEffect(isSelected ? 0.92 : 1.0)
                        .opacity(isSelected ? 0.0 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    
                    // Selected Orange Ring
                    Circle()
                        .stroke(Color.terracottaOrange, lineWidth: 2)
                        .frame(width: 86, height: 86)
                        .scaleEffect(isSelected ? 1.0 : 0.92)
                        .opacity(isSelected ? 1.0 : 0.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    
                    // Stamp Image
                    Image(assetName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageSize, height: imageSize)
                        .offset(y: imageOffset)
                        .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: isSelected ? 3 : 1, x: 0, y: isSelected ? 1.5 : 0)
                }
                .frame(width: 90, height: 90)
                
                Text(name.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? .terracottaOrange : .carbonInk.opacity(0.55))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LobbySetupView(viewModel: LobbyViewModel())
}
