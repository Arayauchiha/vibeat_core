import SwiftUI
import MapKit

struct LocationSearchView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Typewriter Search Header
            Text("NEIGHBORHOOD SEARCH")
                .font(.uiLabel(size: 11, weight: .bold))
                .foregroundColor(.carbonInk.opacity(0.4))
                .tracking(1.5)
            
            // Search Input Row
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.carbonInk.opacity(0.4))
                    .font(.footnote)
                
                ZStack(alignment: .leading) {
                    if viewModel.searchCompleter.searchQuery.isEmpty {
                        Text("Search neighborhood or area...")
                            .font(.editorialSubheader(size: 15))
                            .foregroundColor(.carbonInk.opacity(0.25))
                    }
                    
                    TextField("", text: $viewModel.searchCompleter.searchQuery)
                        .font(.editorialSubheader(size: 15))
                        .foregroundColor(.carbonInk)
                        .tint(.terracottaOrange)
                        .focused($isSearchFocused)
                        .autocorrectionDisabled()
                }
            }
            
            // Dotted Underline
            Line()
                .stroke(Color.carbonInk.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                .frame(height: 1)
            
            // Suggestion list (Typewriter Styled)
            if !viewModel.searchCompleter.results.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.searchCompleter.results.prefix(4), id: \.self) { result in
                        Button(action: {
                            Task {
                                isSearchFocused = false
                                await viewModel.selectLocation(result)
                                viewModel.searchCompleter.searchQuery = "" // Clear after selection
                            }
                        }) {
                            HStack(alignment: .top, spacing: 8) {
                                Text("→")
                                    .font(.uiNumber(size: 14))
                                    .foregroundColor(.terracottaOrange)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.title)
                                        .font(.uiLabel(size: 14, weight: .bold))
                                        .foregroundColor(.carbonInk)
                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(.uiLabel(size: 11))
                                            .foregroundColor(.carbonInk.opacity(0.5))
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().background(Color.subtleDottedLine)
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.top, 8)
    }
}
