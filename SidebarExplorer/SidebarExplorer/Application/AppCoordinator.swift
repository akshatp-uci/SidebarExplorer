//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

final class AppCoordinator: NSObject {
    // MARK: - Properties
    
    private let window: NSWindow
    private var childCoordinators: [Any] = []
    
    private var contentViewController: ContentViewController? {
        return window.contentViewController as? ContentViewController
    }
    
    // MARK: - Initialization
    
    init(window: NSWindow) {
        self.window = window
    }
    
    // MARK: - Setup Methods
    
    func setup() {
        let toolbar = NSToolbar(identifier: "Toolbar")
        toolbar.delegate = self
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = true
        toolbar.displayMode = .iconOnly
        
        window.toolbar = toolbar
    }
}

// MARK: - Toolbar Configuration

extension AppCoordinator: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, NSToolbarItem.Identifier("Title"), .flexibleSpace]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, NSToolbarItem.Identifier("Title"), .flexibleSpace]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .toggleSidebar:
            let item = NSToolbarItem(itemIdentifier: .toggleSidebar)
            item.image = NSImage(systemSymbolName: "sidebar.left", accessibilityDescription: "Toggle Sidebar")
            item.label = "Toggle Sidebar"
            item.target = self
            item.action = #selector(toggleSidebar(_:))
            item.isBordered = true
            return item
            
        case NSToolbarItem.Identifier("Title"):
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            let label = NSTextField(labelWithString: "Sidebar Explorer")
            label.font = NSFont.systemFont(ofSize: 15, weight: .bold)
            label.textColor = .labelColor
            item.view = label
            return item
            
        default:
            return nil
        }
    }
    
    @objc private func toggleSidebar(_ sender: Any?) {
        contentViewController?.splitViewController?.toggleSidebar(sender)
    }
}
