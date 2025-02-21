//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

class SidebarViewController: NSViewController {
    // MARK: - Properties
    
    private(set) var workspaceViewController: WorkspaceViewController!
    
    private let tabView: SidebarTabView
    private var workspaces: [Workspace]
    private var currentWorkspaceIndex: Int
    private var previousWorkspaceIndex: Int = 0
    
    private var currentWorkspace: Workspace {
        workspaces[currentWorkspaceIndex]
    }
    
    private var lastScrollTime: TimeInterval = 0
    private let scrollTimeThreshold: TimeInterval = 0.5  // Half second threshold
    
    // MARK: - Initialization
    
    init() {
        // Initialize with a default workspace
        self.workspaces = [Workspace.nextDefaultWorkspace(after: 0)]
        self.currentWorkspaceIndex = 0
        self.tabView = SidebarTabView(frame: .zero)
        self.workspaceViewController = WorkspaceViewController(workspace: self.workspaces[0])
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
        tabView.setupInitialWorkspaces(with: workspaces, currentIndex: currentWorkspaceIndex)
    }
    
    // MARK: - Workspace Management
    
    private func addWorkspace(_ workspace: Workspace) {
        workspaces.append(workspace)
        previousWorkspaceIndex = currentWorkspaceIndex
        currentWorkspaceIndex = workspaces.count - 1
    }
    
    private func removeWorkspace(at index: Int) {
        guard index < workspaces.count else { return }
        
        previousWorkspaceIndex = currentWorkspaceIndex
        
        if index == currentWorkspaceIndex {
            if index > 0 {
                currentWorkspaceIndex = index - 1
            } else if workspaces.count > 1 {
                currentWorkspaceIndex = 0
            }
        } else if index < currentWorkspaceIndex {
            currentWorkspaceIndex -= 1
        }
        
        workspaces.remove(at: index)
        
        if currentWorkspaceIndex >= workspaces.count {
            currentWorkspaceIndex = max(workspaces.count - 1, 0)
        }
    }
    
    private func switchToWorkspace(at index: Int) {
        previousWorkspaceIndex = currentWorkspaceIndex
        currentWorkspaceIndex = index
    }
    
    // MARK: - Private Setup
    
    private func setupViews() {
        tabView.translatesAutoresizingMaskIntoConstraints = false
        workspaceViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(workspaceViewController)
        view.addSubview(tabView)
        view.addSubview(workspaceViewController.view)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: 36),
            
            workspaceViewController.view.topAnchor.constraint(equalTo: tabView.bottomAnchor),
            workspaceViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            workspaceViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            workspaceViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tabView.delegate = self
    }
    
    private func updateUI() {
        tabView.configure(for: currentWorkspaceIndex)
        updateWorkspaceViewController()
    }
    
    private func updateWorkspaceViewController() {
        let newWorkspaceViewController = WorkspaceViewController(workspace: currentWorkspace)
        newWorkspaceViewController.delegate = workspaceViewController.delegate
        
        addChild(newWorkspaceViewController)
        newWorkspaceViewController.view.translatesAutoresizingMaskIntoConstraints = false
        workspaceViewController.view.slideReplace(
            with: newWorkspaceViewController.view,
            direction: currentWorkspaceIndex > previousWorkspaceIndex ? .minX : .maxX
        )
        
        workspaceViewController.removeFromParent()
        workspaceViewController = newWorkspaceViewController

        NSLayoutConstraint.activate([
            workspaceViewController.view.topAnchor.constraint(equalTo: tabView.bottomAnchor),
            workspaceViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            workspaceViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            workspaceViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func scrollWheel(with event: NSEvent) {
        let currentTime = ProcessInfo.processInfo.systemUptime
        
        // Check if this is a new scroll gesture based on time threshold
        let isNewScrollGesture = (currentTime - lastScrollTime) > scrollTimeThreshold
        
        if abs(event.scrollingDeltaX) > 20 && isNewScrollGesture {
            if event.scrollingDeltaX > 0 && currentWorkspaceIndex > 0 {
                switchToWorkspace(at: currentWorkspaceIndex - 1)
                updateUI()
            } else if event.scrollingDeltaX < 0 && currentWorkspaceIndex < workspaces.count - 1 {
                switchToWorkspace(at: currentWorkspaceIndex + 1)
                updateUI()
            }
            lastScrollTime = currentTime
            return
        }
        super.scrollWheel(with: event)
    }
}

extension SidebarViewController: SidebarTabViewDelegate {
    func sidebarTabView(_ tabView: SidebarTabView, didRequestShowWorkspaceList button: NSButton) {
        let menu = NSMenu()
        
        for (index, workspace) in workspaces.enumerated() {
            let item = NSMenuItem(
                title: workspace.name,
                action: #selector(workspaceMenuItemSelected(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = index
            item.state = index == currentWorkspaceIndex ? .on : .off
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
        let newWorkspace = Workspace.nextDefaultWorkspace(after: workspaces.count)
        addWorkspace(newWorkspace)
        tabView.addWorkspaceButton(for: newWorkspace)
        tabView.configure(for: currentWorkspaceIndex)
        updateWorkspaceViewController()
    }
    
    func sidebarTabView(_ tabView: SidebarTabView, didRequestDeleteWorkspaceAt index: Int) {
        let isDeletingSelected = index == currentWorkspaceIndex
        tabView.removeWorkspaceButton(at: index)
        removeWorkspace(at: index)
        tabView.configure(for: currentWorkspaceIndex)
        if isDeletingSelected {
            updateWorkspaceViewController()
        }
    }
    
    func sidebarTabView(_ tabView: SidebarTabView, didSelectWorkspace index: Int) {
        if index != currentWorkspaceIndex {
            switchToWorkspace(at: index)
            updateUI()
        }
    }
}
