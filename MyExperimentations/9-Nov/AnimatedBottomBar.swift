//
//  checking.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/9/25.
//

import SwiftUI

extension FileManager {
    static func documentsPath(key: String) -> URL {
        FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: key)
    }
}

@propertyWrapper
struct FileManagerProperty: DynamicProperty {
    @State private var title: String
        let key: String
        
        var wrappedValue: String {
            get { title }
            nonmutating set {
                save(newValue: newValue)
            }
        }
        
        var projectedValue: Binding<String> {
            Binding(get: {
                wrappedValue
            }, set: { newValue in
                wrappedValue = newValue
            })
        }
        
        init(wrappedValue: String, _ key: String) {
            self.key = key
            
            do {
                title = try String(contentsOf: FileManager.documentsPath(key: key), encoding: .utf8)
                print("SUCCESS READ")
            } catch {
                title = wrappedValue
                print("ERROR READ: \(error)")
            }
        }
        
        func save(newValue: String) {
            do {
                // When atomically is set to true, it means that the data will be written to a temporary file first.
                // When atomically is set to false, the data is written directly to the specified file path.
                try newValue.write(to: FileManager.documentsPath(key: key), atomically: false, encoding: .utf8)
                title = newValue
    //            print(NSHomeDirectory())
                print("SUCCESS SAVED")
            } catch {
                print("EEROR SAVING: \(error)")
            }
        }
    
}

// Enum for identifying screens
enum Tab: Int, CaseIterable {
    case home
    case search
    case add
    case profile
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .add: return "plus.circle.fill"
        case .profile: return "person.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .add: return "Add"
        case .profile: return "Profile"
        }
    }
}

// Each screen struct (use generics for content)
struct ScreenView<Content: View>: View {
    let content: Content
    
    var body: some View {
        content
    }
}

// Main tab bar view with generics & selection
struct BottomBar<Content: View>: View {
    @Binding var selectedTab: Tab
    
    @ViewBuilder
    let content: (Tab) -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenView(content: content(selectedTab))
            Spacer()
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedTab = tab
                        }
                    }) {
                        VStack {
                            Image(systemName: tab.icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == tab ? .blue : .gray)
                                .scaleEffect(selectedTab == tab ? 1.2 : 1.0)
                            if selectedTab == tab {
                                Capsule()
                                    .frame(width: 18, height: 3)
                                    .foregroundColor(.blue)
                                    .transition(.scale)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 10)
            .background(Color(.systemBackground).shadow(radius: 8))
            .cornerRadius(24)
            .padding(.horizontal, 20)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// Usage example
struct UsageView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        BottomBar(selectedTab: $selectedTab) { tab in
            switch tab {
            case .home:
                homeContent()
            case .search:
                Text("Search Screen")
            case .add:
                Text("Add Screen")
            case .profile:
                Text("Profile Screen")
            }
        }
    }
}

@ViewBuilder
private func homeContent() -> some View {
    @FileManagerProperty("numberOne.txt") var fileText = ""
    
    NavigationStack{
        VStack {
            List {
                ForEach(namedFonts, id: \.id) { names in
                    Text(names.name)
                }
            }
            Circle()
                .strokeBorder()
                .overlay(
                    Text(fileText.isEmpty ? "No content from file" : fileText)
                        .onTapGesture {
                            print(NSHomeDirectory())
                            fileText = "This one stored from property wrapper)"
                        }
                )
            .navigationTitle("Home Content")
        }
    }
}
 
struct NamedFont: Identifiable {
    let name: String
    let font: Font
    var id = UUID().uuidString
}


private let namedFonts: [NamedFont] = [
    NamedFont(name: "Large Title", font: .largeTitle),
    NamedFont(name: "Title", font: .title),
    NamedFont(name: "Headline", font: .headline),
    NamedFont(name: "Body", font: .body),
    NamedFont(name: "Caption", font: .caption)
]

#Preview {
    UsageView()
}
