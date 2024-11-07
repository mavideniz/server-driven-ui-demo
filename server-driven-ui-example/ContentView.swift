//
//  ContentView.swift
//  server-driven-ui-example
//
//  Created by Doğancan Mavideniz on 7.11.2024.
//
// Code source: https://medium.rip/@kalidoss.shanmugam/server-driven-ui-design-with-swiftui-53097ffa765c
import SwiftUI

struct ContentView: View {
    @State private var components: [UIComponent] = []
    
    var body: some View {
        ZStack {
            ScrollView {
                ForEach(components, id: \.type) { component in
                    UIBuilder.buildComponent(from: component)
                }
            }
        }
        
        .refreshable {
            fetchData()
        }
        .onAppear {
            fetchData()
        }
    }
    
    func fetchData() {
        let url = URL(string: "https://dogancan.dev/api/ui")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decodedComponent = try JSONDecoder().decode(UIComponent.self, from: data)
                DispatchQueue.main.async {
                    self.components = [decodedComponent]
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}
struct TextComponent: View {
    let text: String
    
    var body: some View {
        Text(text)
    }
}
struct ButtonComponent: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
        }
    }
}
struct UIBuilder {
    static func buildComponent(from uiComponent: UIComponent) -> some View {
        switch uiComponent.type {
        case "text":
            return AnyView(TextComponent(text: uiComponent.text ?? ""))
        case "button":
            return AnyView(ButtonComponent(title: uiComponent.title ?? "", action: {
                if uiComponent.action == "showAlert" {
                    // Show an alert
                }
            }))
        case "vstack":
            let childrenViews = (uiComponent.children ?? []).map { buildComponent(from: $0) }
            return AnyView(VStack(alignment: .leading, spacing: CGFloat(uiComponent.spacing ?? 0)) {
                ForEach(0..<childrenViews.count) { index in
                    childrenViews[index]
                }
            })
        default:
            return AnyView(EmptyView())
        }
    }
}

struct UIComponent: Codable {
    let type: String
    let alignment: String?
    let spacing: Int?
    let text: String?
    let title: String?
    let action: String?
    let children: [UIComponent]?
    
    enum CodingKeys: String, CodingKey {
        case type, alignment, spacing, text, title, action, children
    }
}
