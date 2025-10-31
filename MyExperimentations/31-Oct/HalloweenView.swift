//
//  HalloweenView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/31/25.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

// MARK: - Model

struct MoonItem: Identifiable, Codable, Equatable, Transferable {
    let id: UUID
    var emoji: String
    var name: String
    
    init(emoji: String, name: String) {
        self.id = UUID()
        self.emoji = emoji
        self.name = name
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

// MARK: - ViewModel

@MainActor
final class MoonViewModel: ObservableObject {
    @Published var stars: [MoonItem]
    @Published var moonItems: [MoonItem]
    
    init() {
        self.stars = [
            MoonItem(emoji: "🎃", name: "Pumpkin"),
            MoonItem(emoji: "👻", name: "Ghost"),
            MoonItem(emoji: "🕸", name: "Web"),
            MoonItem(emoji: "🕯", name: "Candle"),
            MoonItem(emoji: "🦇", name: "Bat")
        ]
        self.moonItems = []
    }
    
    func moveItem(_ item: MoonItem, from source: [MoonItem], to destination: inout [MoonItem]) {
        if stars.contains(where: { $0.id == item.id }) {
            stars.removeAll { $0.id == item.id }
        } else {
            moonItems.removeAll { $0.id == item.id }
        }
        destination.append(item)
    }
}

// MARK: - View

struct HalloweenMoonView: View {
    @StateObject private var viewModel = MoonViewModel()
    @State private var moonGlow = false
    @State private var isTargeted = false
    
    var body: some View {
        ZStack {
            // Background Night Sky
            background
            
            VStack(spacing: 40) {
                // Draggable stars
                draggableStars
                
                Spacer()
                
                // Drop destination (Moon)
                dropDestination
                
                // Items on moon
                if !viewModel.moonItems.isEmpty {
                    VStack(spacing: 8) {
                        Text("✨ Landed on the Moon:")
                            .font(.headline)
                            .foregroundColor(.cyan)
                        
                        ForEach(viewModel.moonItems) { item in
                            Text("\(item.emoji) \(item.name)")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .padding()
        }
        .navigationTitle("Moonlight Tasks")
    }
    
    private var background: some View {
        LinearGradient(colors: [.black, .indigo.opacity(0.8)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
        .ignoresSafeArea()
        .overlay(
            // Faint stars
            RadialGradient(gradient: Gradient(colors: [.white.opacity(0.15), .clear]),
                           center: .topLeading, startRadius: 50, endRadius: 400)
            .blur(radius: 100)
        )
    }
    
    private var draggableStars: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(viewModel.stars) { item in
                    GlassyCard(item: item)
                        .draggable(item)
                        .transition(.scale)
                }
            }
            .padding()
        }
        
    }
    
    private var dropDestination: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [.white, .gray.opacity(0.3)],
                                   center: .center, startRadius: 20, endRadius: 200)
                )
                .frame(width: 200, height: 200)
                .shadow(color: .white.opacity(0.6), radius: moonGlow ? 30 : 10)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 3)
                )
                .blur(radius: isTargeted ? 1 : 0)
                .scaleEffect(isTargeted ? 1.05 : 1)
                .animation(.easeInOut(duration: 0.5), value: isTargeted)
                .onAppear { moonGlow.toggle() }
                .dropDestination(for: MoonItem.self) { dropped, _ in
                    handleDrop(dropped)
                } isTargeted: { targeted in
                    isTargeted = targeted
                }
            
            Text("Drop Here 🌙")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .offset(y: 70)
        }
    }
    
    private func handleDrop(_ dropped: [MoonItem]) -> Bool {
        guard let item = dropped.first else { return false }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            viewModel.moveItem(item, from: viewModel.stars, to: &viewModel.moonItems)
        }
        return true
    }
}

// MARK: - Glassy Card View

struct GlassyCard: View {
    let item: MoonItem
    
    var body: some View {
        VStack {
            Text(item.emoji)
                .font(.system(size: 50))
            Text(item.name)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial) // glass effect
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .purple.opacity(0.4), radius: 6)
    }
}

// MARK: - Preview

#Preview {
    HalloweenMoonView()
}
