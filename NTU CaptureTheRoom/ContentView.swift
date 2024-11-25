//
//  ContentView.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 25/11/2024.
//
// KEY - AIzaSyAoV5ll67vmKdZOjFgQ-C7Lo2zszVyuO_k


//Twitter Client iD -RldfZU9FT1dBSy04NnpDOUlKdlE6MTpjaQ
//Twitter CLIENT SECRET - XrwGHiozQx3dJ_Macx1uMTxhvI11dCuuUYkoDZHmZ7i6D9uBQi


// tWITTER API KEY - HDsoSllsAHK6HjJaT442l7eNh
// TWITTER SECRET KEY -R bLpcP9hYZr6ApAGarMoGOXRFgwT7UYJVGzFlonBsv9jBwNdpW




import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
