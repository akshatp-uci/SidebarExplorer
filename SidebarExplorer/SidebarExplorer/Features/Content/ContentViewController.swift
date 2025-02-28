//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

class ContentViewController: NSViewController {
    
    // MARK: - Properties
    
    private(set) var splitViewController: NSSplitViewController?
    private var contentView: ContentView!
    
    // MARK: - Public Interface
    
    var sidebarViewController: NSViewController? {
        return splitViewController?.splitViewItems.first?.viewController
    }
    
    var contentViewController: NSViewController? {
        return splitViewController?.splitViewItems.last?.viewController
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplitViewController()
    }
    
    // MARK: - Private Setup
    
    private func setupSplitViewController() {
        let splitViewController = NSSplitViewController()
        let splitView = splitViewController.splitView
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        splitView.autosaveName = "MainSplitView"
        splitView.setAccessibilityIdentifier("SidebarView")
        splitView.autoresizingMask = [.width, .height]
        
        addChild(splitViewController)
        view.addSubview(splitViewController.view)
        
        splitViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splitViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            splitViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splitViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            splitViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let sidebarViewController = SidebarViewController(delegate: self)
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarViewController)
        
        // Configure sidebar behavior
        sidebarItem.canCollapse = true
        sidebarItem.holdingPriority = NSLayoutConstraint.Priority(rawValue: 260)
        sidebarItem.minimumThickness = 204
        sidebarItem.maximumThickness = 400
        
        let contentViewController = makeContentViewController()
        let contentItem = NSSplitViewItem(viewController: contentViewController)
        contentItem.holdingPriority = NSLayoutConstraint.Priority(rawValue: 50)
        
        splitViewController.addSplitViewItem(sidebarItem)
        splitViewController.addSplitViewItem(contentItem)
        
        self.splitViewController = splitViewController
    }
    
    private func makeContentViewController() -> NSViewController {
        let viewController = NSViewController()
        contentView = ContentView(frame: .zero)
        viewController.view = contentView
        return viewController
    }
    
    // MARK: - Sidebar Toggle
    
    @objc func toggleSidebar(_ sender: Any?) {
        splitViewController?.toggleSidebar(sender)
    }
}

// Add delegate implementation
extension ContentViewController: WorkspaceViewControllerDelegate {
    func workspaceViewController(_ controller: WorkspaceViewController, didSelectWorkspace workspace: Workspace) {
        contentView.loadContent(for: workspace)
    }
} 
