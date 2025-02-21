//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import Foundation

class Workspace: NSObject {
    let id: UUID
    var name: String
    var icon: String
    var listItems: [WorkspaceItem]
    var pinnedItems: [WorkspaceItem]
    var selectedItemId: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        items: [WorkspaceItem] = [],
        pinnedItems: [WorkspaceItem] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.listItems = items
        self.pinnedItems = pinnedItems
    }

    static let defaultConfigs: [(name: String, icon: String)] = [
        ("Files", "folder"),
        ("Projects", "macwindow"),
        ("Notifications", "bell"),
        ("Downloads", "arrow.down.circle"),
        ("Documents", "doc")
    ]

    static func nextDefaultWorkspace(after count: Int) -> Workspace {
        let config = defaultConfigs[count % defaultConfigs.count]
        
        // Generate random number of items (5-10)
        let itemCount = Int.random(in: 5...10)
        let items = (0..<itemCount).map { index in
            let itemTypes = [
                ("Project \(index + 1)", "folder"),
                ("Document \(index + 1).pdf", "doc.text"),
                ("Notes \(index + 1).txt", "note.text"),
                ("Image \(index + 1).png", "photo"),
                ("Script \(index + 1).swift", "terminal")
            ]
            let randomType = itemTypes.randomElement()!
            return WorkspaceItem(
                title: randomType.0,
                description: "Created on \(Date())",
                icon: randomType.1
            )
        }
        
        // Generate random number of pinned items (0-6)
        let pinnedCount = Int.random(in: 0...6)
        let pinnedItems = (0..<pinnedCount).map { index in
            let pinnedTypes = [
                ("Quick Access \(index + 1)", "star.fill"),
                ("Favorites \(index + 1)", "heart.fill"),
                ("Shortcut \(index + 1)", "link"),
                ("Bookmark \(index + 1)", "bookmark.fill"),
                ("Recent \(index + 1)", "clock.fill"),
                ("Important \(index + 1)", "exclamationmark.circle.fill"),
                ("Shared \(index + 1)", "person.2.fill"),
                ("Archive \(index + 1)", "archivebox.fill"),
                ("Tagged \(index + 1)", "tag.fill"),
                ("Cloud \(index + 1)", "icloud.fill")
            ]
            let randomType = pinnedTypes.randomElement()!
            return WorkspaceItem(
                title: randomType.0,
                description: "Pinned item",
                icon: randomType.1
            )
        }
        
        return Workspace(
            name: config.name,
            icon: config.icon,
            items: items,
            pinnedItems: pinnedItems
        )
    }

    func selectItem(id: UUID) {
        // Deselect all items
        listItems = listItems.map { var item = $0; item.isSelected = false; return item }
        pinnedItems = pinnedItems.map { var item = $0; item.isSelected = false; return item }
        
        // Select the new item
        if let index = listItems.firstIndex(where: { $0.id == id }) {
            listItems[index].isSelected = true
            selectedItemId = id
        } else if let index = pinnedItems.firstIndex(where: { $0.id == id }) {
            pinnedItems[index].isSelected = true
            selectedItemId = id
        }
    }
    
    func togglePinned(item: WorkspaceItem) {
        if let index = listItems.firstIndex(where: { $0.id == item.id }) {
            // Move from items to pinnedItems
            let itemToPin = listItems.remove(at: index)
            pinnedItems = [itemToPin] + pinnedItems
        } else if let index = pinnedItems.firstIndex(where: { $0.id == item.id }) {
            // Move from pinnedItems to items
            let itemToUnpin = pinnedItems.remove(at: index)
            listItems = [itemToUnpin] + listItems
        }
    }

    func deleteItem(_ item: WorkspaceItem) {
        if let index = listItems.firstIndex(where: { $0.id == item.id }) {
            listItems.remove(at: index)
        } else if let index = pinnedItems.firstIndex(where: { $0.id == item.id }) {
            pinnedItems.remove(at: index)
        }
        
        // If we deleted the selected item, clear the selection
        if item.id == selectedItemId {
            selectedItemId = nil
        }
    }
}
