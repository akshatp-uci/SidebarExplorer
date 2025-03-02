//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

class SidebarViewController: NSViewController {
    // MARK: - Properties
    
    private let workspacePageController: WorkspacePageController
    private let tabView: SidebarTabView
        
    // MARK: - Initialization
    
    init(delegate: WorkspaceViewControllerDelegate?) {
        // Initialize with a default workspace
        let defaultWorkspace = Workspace.nextDefaultWorkspace(after: 0)
        self.workspacePageController = WorkspacePageController(
            workspaces: [defaultWorkspace],
            workspaceViewControllerDelegate: delegate
        )
        self.tabView = SidebarTabView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle & Setup
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.clipsToBounds = true
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabView.setupInitialWorkspaces(with: workspacePageController.arrangedObjects as! [Workspace], currentIndex: workspacePageController.selectedIndex)
        workspacePageController.workspacePageControllerDelegate = self
        self.view.layoutSubtreeIfNeeded()
    }
    
    // MARK: - Private Setup
    
    private func setupViews() {
        tabView.translatesAutoresizingMaskIntoConstraints = false
        workspacePageController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(workspacePageController)
        view.addSubview(tabView)
        view.addSubview(workspacePageController.view)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: 32),
            
            workspacePageController.view.topAnchor.constraint(equalTo: tabView.bottomAnchor),
            workspacePageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            workspacePageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            workspacePageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tabView.delegate = self
    }
}

extension SidebarViewController: WorkspacePageControllerDelegate {
    func workspacePageController(_ controller: WorkspacePageController, didSwitchToWorkspace workspace: Workspace) {
        tabView.configure(for: controller.selectedIndex)
    }
}

extension SidebarViewController: SidebarTabViewDelegate {
    func sidebarTabView(_ tabView: SidebarTabView, didRequestShowWorkspaceList button: NSButton) {
        let menu = NSMenu()
        
        let workspaces = workspacePageController.arrangedObjects as! [Workspace]
        for (index, workspace) in workspaces.enumerated() {
            let item = NSMenuItem(
                title: workspace.name,
                action: #selector(workspaceMenuItemSelected(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = index
            item.state = index == workspacePageController.selectedIndex ? .on : .off
            item.image = NSImage(systemSymbolName: workspace.icon, accessibilityDescription: workspace.name)
            menu.addItem(item)
        }
        
        menu.addItem(.separator())
        
        let addItem = NSMenuItem(
            title: "Add Workspace",
            action: #selector(addWorkspaceFromMenu(_:)),
            keyEquivalent: ""
        )
        addItem.target = self
        addItem.image = NSImage(systemSymbolName: "plus", accessibilityDescription: "Add")
        menu.addItem(addItem)
        
        // Show the menu
        let point = NSPoint(x: 0, y: button.bounds.height)
        menu.popUp(positioning: nil, at: point, in: button)
    }
    
    @objc private func workspaceMenuItemSelected(_ sender: NSMenuItem) {
        sidebarTabView(tabView, didSelectWorkspace: sender.tag)
    }
    
    @objc private func addWorkspaceFromMenu(_ sender: NSMenuItem) {
        sidebarTabViewDidRequestAddWorkspace(tabView)
    }

    func sidebarTabViewDidRequestAddWorkspace(_ tabView: SidebarTabView) {
        let workspaces = workspacePageController.arrangedObjects as! [Workspace]
        let newWorkspace = Workspace.nextDefaultWorkspace(after: workspaces.count)
        workspacePageController.addWorkspace(newWorkspace)
        tabView.addWorkspaceButton(for: newWorkspace)
        tabView.configure(for: workspacePageController.selectedIndex)
    }
    
    func sidebarTabView(_ tabView: SidebarTabView, didRequestDeleteWorkspaceAt index: Int) {
        workspacePageController.removeWorkspace(at: index)
        tabView.removeWorkspaceButton(at: index)
        tabView.configure(for: workspacePageController.selectedIndex)
    }
    
    func sidebarTabView(_ tabView: SidebarTabView, didSelectWorkspace index: Int) {
        workspacePageController.switchToWorkspace(at: index)
        tabView.configure(for: workspacePageController.selectedIndex)
    }
}
