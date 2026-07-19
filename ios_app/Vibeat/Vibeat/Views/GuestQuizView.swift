import SwiftUI
import Combine
import MapKit
import CoreLocation

struct GuestQuizView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @Binding var playerName: String
    @State private var budget: Double = 1200
    @State private var selectedCuisines: [String] = []
    @State private var selectedAtmosphere: String = ""
    @State private var wantsAlcohol = false
    @State private var quizStep = 1
    @State private var dietPreference = "Veg"
    @State private var particularDish = ""
    
    // Travel location inputs
    @State private var useCurrentLocation = true
    @State private var selectedTravelLocationName = "Current Location"
    @State private var travelLat: Double = 28.6139
    @State private var travelLng: Double = 77.2090
    @State private var isSearchingLocation = false
    @StateObject private var localSearchService = LocationSearchService()
    @StateObject private var locationManager = LocationManager()
    @FocusState private var isLocationSearchFocused: Bool
    
    // Wallet / Credit Card deck state
    @State private var selectedCards: [String] = []
    
    let cuisinesList = [
        "North Indian", "South Indian",
        "Chinese", "Italian",
        "Korean", "Mexican",
        "Japanese", "American",
        "Continental", "Mediterranean"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress Bar / Step Indicator
            HStack(spacing: 6) {
                ForEach(1...6, id: \.self) { step in
                    Capsule()
                        .fill(step <= quizStep ? Color.terracottaOrange : Color.carbonInk.opacity(0.1))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
            Spacer()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    if quizStep == 1 {
                        // STEP 1: Name & Diet Preference (Menu Card style)
                        VStack(spacing: 24) {
                            Text("La Carte de Vibeat")
                                .font(.custom("Georgia-Italic", size: 14))
                                .foregroundColor(.terracottaOrange)
                                .padding(.top, 10)
                            
                            Image("clochey_welcome")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 120)
                            
                            VStack(spacing: 6) {
                                Text("CLOCHEY")
                                    .font(.uiLabel(size: 10, weight: .black))
                                    .foregroundColor(.terracottaOrange)
                                    .tracking(1.5)
                                
                                Text("What shall I call you, and what is your dietary preference?")
                                    .font(.editorialSubheader(size: 15))
                                    .foregroundColor(.carbonInk)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 18)
                            .background(Color.inkPaper.opacity(0.4))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.terracottaOrange.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                            
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Image(systemName: "fork.knife")
                                    .font(.caption2)
                                    .foregroundColor(.terracottaOrange.opacity(0.6))
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("YOUR NAME")
                                    .font(.uiLabel(size: 11, weight: .black))
                                    .foregroundColor(.carbonInk.opacity(0.6))
                                    .tracking(1)
                                
                                TextField("", text: $playerName, prompt: Text("Enter your name...").foregroundColor(Color.carbonInk.opacity(0.45)))
                                    .font(.uiLabel(size: 15, weight: .bold))
                                    .foregroundColor(.carbonInk)
                                    .padding()
                                    .background(Color.inkPaper.opacity(0.5))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.carbonInk.opacity(0.1), lineWidth: 1)
                                    )
                                    .autocorrectionDisabled()
                            }
                            .padding(.horizontal, 10)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("DIETARY REQUIREMENT")
                                    .font(.uiLabel(size: 11, weight: .black))
                                    .foregroundColor(.carbonInk.opacity(0.6))
                                    .tracking(1)
                                
                                HStack(spacing: 12) {
                                    ForEach(["Veg", "Non-Veg", "Vegan"], id: \.self) { diet in
                                        let isSelected = dietPreference == diet
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            dietPreference = diet
                                        }) {
                                            VStack(spacing: 6) {
                                                Circle()
                                                    .fill(getDietColor(for: diet))
                                                    .frame(width: 8, height: 8)
                                                
                                                Text(diet)
                                                    .font(.uiLabel(size: 13, weight: .bold))
                                                    .foregroundColor(isSelected ? .white : .carbonInk)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(isSelected ? getDietColor(for: diet) : Color.inkPaper.opacity(0.5))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(isSelected ? Color.clear : Color.carbonInk.opacity(0.1), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.bottom, 12)
                        }
                        .padding(20)
                        .menuBoardStyle()
                    } else if quizStep == 2 {
                        // STEP 2: Cuisine Ranking Grid (Menu Card style)
                        VStack(spacing: 20) {
                            Text("Les Entrées")
                                .font(.custom("Georgia-Italic", size: 14))
                                .foregroundColor(.terracottaOrange)
                                .padding(.top, 10)
                            
                            Image("clochey_waiting")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                            
                            VStack(spacing: 6) {
                                Text("CLOCHEY")
                                    .font(.uiLabel(size: 10, weight: .black))
                                    .foregroundColor(.terracottaOrange)
                                    .tracking(1.5)
                                
                                Text("Select and rank your top 3 cuisines for today:")
                                    .font(.editorialSubheader(size: 15))
                                    .foregroundColor(.carbonInk)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.inkPaper.opacity(0.4))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.terracottaOrange.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                            
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                ForEach(cuisinesList, id: \.self) { cuisine in
                                    let isSelected = selectedCuisines.contains(cuisine)
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        if let index = selectedCuisines.firstIndex(of: cuisine) {
                                            selectedCuisines.remove(at: index)
                                        } else {
                                            if selectedCuisines.count < 3 {
                                                selectedCuisines.append(cuisine)
                                            }
                                        }
                                    }) {
                                        VStack(spacing: 6) {
                                            ZStack(alignment: .topTrailing) {
                                                Image(getCuisineImageName(for: cuisine))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 70)
                                                    .cornerRadius(6)
                                                
                                                if isSelected, let rankIndex = selectedCuisines.firstIndex(of: cuisine) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.terracottaOrange)
                                                            .frame(width: 22, height: 22)
                                                        Text("\(rankIndex + 1)")
                                                            .font(.system(size: 11, weight: .bold))
                                                            .foregroundColor(.white)
                                                    }
                                                    .padding(4)
                                                }
                                            }
                                            
                                            Text(cuisine)
                                                .font(.uiLabel(size: 13, weight: .bold))
                                                .foregroundColor(.carbonInk)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? Color.terracottaOrange : Color.carbonInk.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                                        )
                                        .shadow(color: isSelected ? Color.terracottaOrange.opacity(0.1) : Color.black.opacity(0.02), radius: 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.bottom, 12)
                        }
                        .padding(20)
                        .menuBoardStyle()
                    } else if quizStep == 3 {
                        // STEP 3: Vibe & Atmosphere Custom Input (Menu Card style)
                        VStack(spacing: 20) {
                            Text("L'Ambiance")
                                .font(.custom("Georgia-Italic", size: 14))
                                .foregroundColor(.terracottaOrange)
                                .padding(.top, 10)
                            
                            Image("clochey_thinking")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                            
                            VStack(spacing: 6) {
                                Text("CLOCHEY")
                                    .font(.uiLabel(size: 10, weight: .black))
                                    .foregroundColor(.terracottaOrange)
                                    .tracking(1.5)
                                
                                Text("What kind of vibe or atmosphere are you looking for today?")
                                    .font(.editorialSubheader(size: 15))
                                    .foregroundColor(.carbonInk)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.inkPaper.opacity(0.4))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.terracottaOrange.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                            
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PREFERRED VIBE")
                                    .font(.uiLabel(size: 11, weight: .black))
                                    .foregroundColor(.carbonInk.opacity(0.6))
                                    .tracking(1)
                                
                                TextField("", text: $selectedAtmosphere, prompt: Text("e.g. rooftop, calm music, cozy...").foregroundColor(Color.carbonInk.opacity(0.45)))
                                    .font(.uiLabel(size: 15, weight: .bold))
                                    .foregroundColor(.carbonInk)
                                    .padding()
                                    .background(Color.inkPaper.opacity(0.5))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.carbonInk.opacity(0.1), lineWidth: 1)
                                    )
                                    .autocorrectionDisabled()
                            }
                            .padding(.horizontal, 10)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SUGGESTIONS")
                                    .font(.uiLabel(size: 10, weight: .black))
                                    .foregroundColor(.carbonInk.opacity(0.4))
                                    .tracking(1)
                                    .padding(.horizontal, 10)
                                
                                FlowLayout(items: [
                                    "Rooftop 🌇", "Cozy ☕", "Ambient Lights ✨",
                                    "Calm Music 🎵", "Lively 🥳", "Romantic 🕯️"
                                ], spacing: 8) { tag in
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        selectedAtmosphere = tag.components(separatedBy: " ").first ?? tag
                                    }) {
                                        Text(tag)
                                            .font(.uiLabel(size: 12, weight: .bold))
                                            .foregroundColor(selectedAtmosphere.lowercased() == tag.lowercased().components(separatedBy: " ").first ? .white : .carbonInk)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedAtmosphere.lowercased() == tag.lowercased().components(separatedBy: " ").first ? Color.terracottaOrange : Color.inkPaper.opacity(0.5))
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(selectedAtmosphere.lowercased() == tag.lowercased().components(separatedBy: " ").first ? Color.clear : Color.carbonInk.opacity(0.1), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.bottom, 12)
                        }
                        .padding(20)
                        .menuBoardStyle()
                    } else if quizStep == 4 {
                        // STEP 4: Credit Cards Selection & Personal Budget (Menu Card style)
                        VStack(spacing: 20) {
                            Text("Les Cartes")
                                .font(.custom("Georgia-Italic", size: 14))
                                .foregroundColor(.terracottaOrange)
                                .padding(.top, 10)
                            
                            Image("clochey_waiting")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                            
                            VStack(spacing: 6) {
                                Text("CLOCHEY")
                                    .font(.uiLabel(size: 10, weight: .black))
                                    .foregroundColor(.terracottaOrange)
                                    .tracking(1.5)
                                
                                Text("Which of these dining cards do you have, and what is your personal budget?")
                                    .font(.editorialSubheader(size: 15))
                                    .foregroundColor(.carbonInk)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.inkPaper.opacity(0.4))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.terracottaOrange.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                            
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Image(systemName: "fork.knife")
                                    .font(.caption2)
                                    .foregroundColor(.terracottaOrange.opacity(0.6))
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                                ForEach(["SBI", "HDFC", "ICICI", "AXIS"], id: \.self) { card in
                                    let isSelected = selectedCards.contains(card)
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        if isSelected {
                                            selectedCards.removeAll(where: { $0 == card })
                                        } else {
                                            selectedCards.append(card)
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            ZStack(alignment: .topTrailing) {
                                                Image(getCardImageName(for: card))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 80)
                                                    .cornerRadius(8)
                                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                                
                                                if isSelected {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.title3)
                                                        .foregroundColor(.terracottaOrange)
                                                        .background(Color.white.clipShape(Circle()))
                                                        .padding(4)
                                                }
                                            }
                                            
                                            Text(getBankDisplayName(for: card))
                                                .font(.uiLabel(size: 13, weight: .bold))
                                                .foregroundColor(.carbonInk)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? Color.terracottaOrange : Color.carbonInk.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                                        )
                                        .shadow(color: isSelected ? Color.terracottaOrange.opacity(0.1) : Color.black.opacity(0.02), radius: 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                            
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.15))
                                    .frame(width: 40, height: 1)
                                Image(systemName: "banknote")
                                    .font(.caption2)
                                    .foregroundColor(.terracottaOrange.opacity(0.5))
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.15))
                                    .frame(width: 40, height: 1)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("YOUR PERSONAL BUDGET")
                                        .font(.uiLabel(size: 11, weight: .black))
                                        .foregroundColor(.carbonInk.opacity(0.6))
                                        .tracking(1)
                                    Spacer()
                                    Text("₹\(Int(budget))")
                                        .font(.uiLabel(size: 14, weight: .black))
                                        .foregroundColor(.terracottaOrange)
                                }
                                
                                Slider(value: $budget, in: viewModel.minimumBudget...5000, step: 100)
                                    .tint(.terracottaOrange)
                                
                                HStack {
                                    Text("Min: ₹\(Int(viewModel.minimumBudget))")
                                        .font(.caption2)
                                        .foregroundColor(.carbonInk.opacity(0.5))
                                    Spacer()
                                    Text("Max: ₹5000")
                                        .font(.caption2)
                                        .foregroundColor(.carbonInk.opacity(0.5))
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.bottom, 12)
                        }
                        .padding(20)
                        .menuBoardStyle()
                        .onAppear {
                            budget = max(budget, viewModel.minimumBudget)
                        }
                    } else if quizStep == 5 {
                        // STEP 5: Alcohol Preference & Particular Dish (Menu Card style)
                        VStack(spacing: 20) {
                            Text("Le Digestif & Les Plats")
                                .font(.custom("Georgia-Italic", size: 14))
                                .foregroundColor(.terracottaOrange)
                                .padding(.top, 10)
                            
                            Image("clochey_reveal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                            
                            VStack(spacing: 6) {
                                Text("CLOCHEY")
                                    .font(.uiLabel(size: 10, weight: .black))
                                    .foregroundColor(.terracottaOrange)
                                    .tracking(1.5)
                                
                                Text("Would you like alcohol to be available, and do you have a specific dish in mind?")
                                    .font(.editorialSubheader(size: 15))
                                    .foregroundColor(.carbonInk)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.inkPaper.opacity(0.4))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.terracottaOrange.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                            
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Image(systemName: "fork.knife")
                                    .font(.caption2)
                                    .foregroundColor(.terracottaOrange.opacity(0.6))
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("ALCOHOL AVAILABILITY")
                                    .font(.uiLabel(size: 11, weight: .black))
                                    .foregroundColor(.carbonInk.opacity(0.6))
                                    .tracking(1)
                                    .padding(.horizontal, 10)
                                
                                HStack(spacing: 16) {
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        wantsAlcohol = true
                                    }) {
                                        HStack {
                                            Image(systemName: wantsAlcohol ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(wantsAlcohol ? .white : .carbonInk.opacity(0.3))
                                            Text("Alcohol Okay 🥂")
                                                .font(.uiLabel(size: 13, weight: .bold))
                                                .foregroundColor(wantsAlcohol ? .white : .carbonInk)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(wantsAlcohol ? Color.terracottaOrange : Color.inkPaper.opacity(0.5))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(wantsAlcohol ? Color.clear : Color.carbonInk.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                    
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        wantsAlcohol = false
                                    }) {
                                        HStack {
                                            Image(systemName: !wantsAlcohol ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(!wantsAlcohol ? .white : .carbonInk.opacity(0.3))
                                            Text("No Alcohol 🚫")
                                                .font(.uiLabel(size: 13, weight: .bold))
                                                .foregroundColor(!wantsAlcohol ? .white : .carbonInk)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(!wantsAlcohol ? Color.terracottaOrange : Color.inkPaper.opacity(0.5))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(!wantsAlcohol ? Color.clear : Color.carbonInk.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                            
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.15))
                                    .frame(width: 40, height: 1)
                                Image(systemName: "sparkles")
                                    .font(.caption2)
                                    .foregroundColor(.terracottaOrange.opacity(0.5))
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.15))
                                    .frame(width: 40, height: 1)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PARTICULAR DISH (OPTIONAL)")
                                    .font(.uiLabel(size: 11, weight: .black))
                                    .foregroundColor(.carbonInk.opacity(0.6))
                                    .tracking(1)
                                
                                TextField("", text: $particularDish, prompt: Text("e.g. Biryani, Pasta, Ramen...").foregroundColor(Color.carbonInk.opacity(0.45)))
                                    .font(.uiLabel(size: 15, weight: .bold))
                                    .foregroundColor(.carbonInk)
                                    .padding()
                                    .background(Color.inkPaper.opacity(0.5))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.carbonInk.opacity(0.1), lineWidth: 1)
                                    )
                                    .autocorrectionDisabled()
                            }
                            .padding(.horizontal, 10)
                            .padding(.bottom, 12)
                        }
                        .padding(20)
                        .menuBoardStyle()
                    } else if quizStep == 6 {
                        // STEP 6: Travel Location (Menu Card style)
                        VStack(spacing: 20) {
                            Text("Le Voyage")
                                .font(.custom("Georgia-Italic", size: 14))
                                .foregroundColor(.terracottaOrange)
                                .padding(.top, 10)
                            
                            Image("clochey_reveal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                            
                            VStack(spacing: 6) {
                                Text("CLOCHEY")
                                    .font(.uiLabel(size: 10, weight: .black))
                                    .foregroundColor(.terracottaOrange)
                                    .tracking(1.5)
                                
                                Text("Where will you be travelling to the gathering venue from?")
                                    .font(.editorialSubheader(size: 15))
                                    .foregroundColor(.carbonInk)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.inkPaper.opacity(0.4))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.terracottaOrange.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                            
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.caption2)
                                    .foregroundColor(.terracottaOrange.opacity(0.6))
                                Rectangle()
                                    .fill(Color.terracottaOrange.opacity(0.2))
                                    .frame(width: 60, height: 1)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("DEPARTING FROM")
                                    .font(.uiLabel(size: 10, weight: .black))
                                    .foregroundColor(.carbonInk.opacity(0.5))
                                    .tracking(1)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.terracottaOrange)
                                    Text(selectedTravelLocationName == "Current Location" ? locationManager.addressString : selectedTravelLocationName)
                                        .font(.uiLabel(size: 14, weight: .bold))
                                        .foregroundColor(.carbonInk)
                                        .lineLimit(1)
                                    if selectedTravelLocationName == "Current Location" {
                                        Text("(Current)")
                                            .font(.custom("Georgia-Italic", size: 12))
                                            .foregroundColor(.carbonInk.opacity(0.5))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.terracottaOrange.opacity(0.3), lineWidth: 1.5)
                            )
                            .padding(.horizontal, 10)
                            
                            if !isSearchingLocation {
                                HStack(spacing: 12) {
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        withAnimation(.easeInOut) {
                                            isSearchingLocation = true
                                        }
                                        isLocationSearchFocused = true
                                    }) {
                                        HStack {
                                            Image(systemName: "pencil")
                                            Text("Change Location")
                                        }
                                        .font(.uiLabel(size: 12, weight: .bold))
                                        .foregroundColor(.terracottaOrange)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color.terracottaOrange.opacity(0.08))
                                        .cornerRadius(8)
                                    }
                                    
                                    if selectedTravelLocationName != "Current Location" {
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            withAnimation(.easeInOut) {
                                                selectedTravelLocationName = "Current Location"
                                                useCurrentLocation = true
                                                travelLat = locationManager.location?.coordinate.latitude ?? 28.6139
                                                travelLng = locationManager.location?.coordinate.longitude ?? 77.2090
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "arrow.counterclockwise")
                                                Text("Reset to Current")
                                            }
                                            .font(.uiLabel(size: 12, weight: .bold))
                                            .foregroundColor(.carbonInk.opacity(0.6))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(Color.carbonInk.opacity(0.05))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 12)
                            } else {
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Search departure location")
                                            .font(.uiLabel(size: 11, weight: .black))
                                            .foregroundColor(.carbonInk.opacity(0.6))
                                            .tracking(1)
                                        Spacer()
                                        Button(action: {
                                            withAnimation(.easeInOut) {
                                                isSearchingLocation = false
                                            }
                                        }) {
                                            Text("Cancel")
                                                .font(.uiLabel(size: 11, weight: .bold))
                                                .foregroundColor(.carbonInk.opacity(0.5))
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    
                                    TextField("", text: $localSearchService.searchQuery, prompt: Text("Search place or address...").foregroundColor(Color.carbonInk.opacity(0.45)))
                                        .font(.uiLabel(size: 15, weight: .bold))
                                        .foregroundColor(.carbonInk)
                                        .padding()
                                        .background(Color.inkPaper.opacity(0.5))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.carbonInk.opacity(0.1), lineWidth: 1)
                                        )
                                        .focused($isLocationSearchFocused)
                                        .autocorrectionDisabled()
                                        .padding(.horizontal, 10)
                                    
                                    if !localSearchService.completions.isEmpty {
                                        VStack(alignment: .leading, spacing: 0) {
                                            ForEach(localSearchService.completions.prefix(4), id: \.self) { completion in
                                                Button(action: {
                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    selectManualLocation(completion)
                                                    localSearchService.searchQuery = ""
                                                    localSearchService.completions = []
                                                    withAnimation(.easeInOut) {
                                                        isSearchingLocation = false
                                                    }
                                                    isLocationSearchFocused = false
                                                }) {
                                                    VStack(alignment: .leading, spacing: 3) {
                                                        Text(completion.title)
                                                            .font(.uiLabel(size: 13, weight: .bold))
                                                            .foregroundColor(.carbonInk)
                                                            .multilineTextAlignment(.leading)
                                                        if !completion.subtitle.isEmpty {
                                                            Text(completion.subtitle)
                                                                .font(.caption2)
                                                                .foregroundColor(.carbonInk.opacity(0.5))
                                                                .multilineTextAlignment(.leading)
                                                        }
                                                        Divider()
                                                            .padding(.top, 4)
                                                    }
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 10)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                            }
                                        }
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.carbonInk.opacity(0.1), lineWidth: 1)
                                        )
                                        .padding(.horizontal, 10)
                                    }
                                }
                                .padding(.bottom, 12)
                            }
                        }
                        .padding(20)
                        .menuBoardStyle()
                        .onAppear {
                            locationManager.requestPermission()
                        }
                        .onChange(of: locationManager.location) { _, newLocation in
                            if let loc = newLocation, useCurrentLocation {
                                travelLat = loc.coordinate.latitude
                                travelLng = loc.coordinate.longitude
                            }
                        }
                        .onChange(of: locationManager.addressString) { _, newAddress in
                            if useCurrentLocation {
                                selectedTravelLocationName = "Current Location"
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            
            Spacer()
            
            // Bottom Navigation Buttons
            HStack(spacing: 12) {
                if quizStep > 1 {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring()) {
                            quizStep -= 1
                        }
                    }) {
                        Text("BACK")
                            .font(.uiLabel(size: 14, weight: .black))
                            .foregroundColor(.carbonInk)
                            .tracking(1.5)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.carbonInk.opacity(0.15), lineWidth: 1)
                            )
                    }
                }
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if quizStep < 6 {
                        withAnimation(.spring()) {
                            quizStep += 1
                        }
                    } else {
                        // Final submission (Toss Ticket)
                        let player = Player(
                            name: playerName,
                            lat: travelLat,
                            lng: travelLng,
                            budget: budget,
                            cuisines: selectedCuisines,
                            cards: selectedCards,
                            wantsAlcohol: wantsAlcohol,
                            atmosphere: selectedAtmosphere,
                            specificDish: particularDish.isEmpty ? nil : particularDish,
                            dietPreference: dietPreference,
                            isReady: false
                        )
                        viewModel.activePlayers.append(player)
                        viewModel.isTicketSubmitted = true
                        Task {
                            await viewModel.calculateRecommendations()
                        }
                    }
                }) {
                    Text(quizStep == 6 ? "TOSS TICKET 🍽️" : "CONTINUE")
                        .font(.uiLabel(size: 14, weight: .black))
                        .foregroundColor(isStepValid() ? .white : .white.opacity(0.5))
                        .tracking(1.5)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isStepValid() ? Color.terracottaOrange : Color.terracottaOrange.opacity(0.5))
                        )
                        .shadow(color: Color.terracottaOrange.opacity(isStepValid() ? 0.3 : 0), radius: 6, x: 0, y: 4)
                }
                .disabled(!isStepValid())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
    
    private func isStepValid() -> Bool {
        switch quizStep {
        case 1:
            return !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 2:
            return selectedCuisines.count == 3
        case 3:
            return !selectedAtmosphere.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 6:
            return useCurrentLocation || (!selectedTravelLocationName.isEmpty && selectedTravelLocationName != "Current Location")
        default:
            return true
        }
    }
    
    private func getDietColor(for diet: String) -> Color {
        switch diet {
        case "Veg":
            return .green
        case "Vegan":
            return .teal
        default:
            return .red
        }
    }
    
    private func getCuisineImageName(for cuisine: String) -> String {
        switch cuisine {
        case "North Indian": return "cuisine_north_indian"
        case "South Indian": return "cuisine_south_indian"
        case "Chinese": return "cuisine_chinese"
        case "Italian": return "cuisine_italian"
        case "Korean": return "cuisine_korean"
        case "Mexican": return "cuisine_mexican"
        case "Japanese": return "cuisine_japanese"
        case "American": return "cuisine_american"
        case "Continental": return "cuisine_continental"
        case "Mediterranean": return "cuisine_mediterranean"
        default: return ""
        }
    }
    
    private func getCardImageName(for card: String) -> String {
        switch card {
        case "HDFC": return "card_hdfc"
        case "SBI": return "card_sbi"
        case "ICICI": return "card_icici"
        case "AXIS": return "card_axis"
        default: return ""
        }
    }
    
    private func getBankDisplayName(for card: String) -> String {
        switch card {
        case "HDFC": return "HDFC Bank"
        case "SBI": return "SBI Card"
        case "ICICI": return "ICICI Bank"
        case "AXIS": return "Axis Bank"
        default: return card
        }
    }
    
    private func selectManualLocation(_ completion: MKLocalSearchCompletion) {
        selectedTravelLocationName = completion.title
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let coord = response?.mapItems.first?.placemark.coordinate {
                travelLat = coord.latitude
                travelLng = coord.longitude
            }
        }
    }
}

// MARK: - LocationManager
@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var addressString: String = "Connaught Place, New Delhi"
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.location = location
            self.manager.stopUpdatingLocation()
            
            // Reverse geocode
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                if let placemark = placemarks?.first {
                    let name = placemark.name ?? placemark.locality ?? "Current Location"
                    Task { @MainActor [weak self] in
                        self?.addressString = name
                    }
                }
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}
