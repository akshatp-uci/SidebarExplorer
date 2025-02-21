//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

protocol WorkspaceViewControllerDelegate: AnyObject {
    func workspaceViewController(_ controller: WorkspaceViewController, didSelectWorkspace workspace: Workspace)
}

class WorkspaceViewController: NSViewController {
    // MARK: - Properties
    
    private let workspaceView: WorkspaceView
    private var workspace: Workspace
    weak var delegate: WorkspaceViewControllerDelegate?
    
    // MARK: - Initialization
    
    init(workspace: Workspace) {
        self.workspace = workspace
        self.workspaceView = WorkspaceView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
        
        workspaceView.dataSource = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = workspaceView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workspaceView.delegate = self
        updateView()
    }
    
    // MARK: - Public Methods
    
    func updateWorkspace(_ workspace: Workspace) {
        self.workspace = workspace
        updateView()
    }
    
    // MARK: - Private Methods
    
    private func updateView() {
        workspaceView.updateTitle(workspace.name)
        workspaceView.updatePinnedItemsArea(workspace.pinnedItems, animated: false)
        workspaceView.reloadItems()
        
        if let selectedId = workspace.selectedItemId {
            if let selectedListIndex = workspace.listItems.firstIndex(where: { $0.id == selectedId }) {
                workspaceView.updateListSelection(selectedListIndex)
            } else {
                workspaceView.updateListSelection(nil)
            }
            
            if let selectedPinnedIndex = workspace.pinnedItems.firstIndex(where: { $0.id == selectedId }) {
                workspaceView.updatePinnedSelection(selectedPinnedIndex)
            } else {
                workspaceView.updatePinnedSelection(nil)
            }
        }
    }
}

// MARK: - WorkspaceViewDataSource

extension WorkspaceViewController: WorkspaceViewDataSource {
    var listItems: [WorkspaceItem] {
        workspace.listItems
    }
    
    var pinnedItems: [WorkspaceItem] {
        workspace.pinnedItems
    }
}

// MARK: - WorkspaceViewDelegate

extension WorkspaceViewController: WorkspaceViewDelegate {
    func workspaceView(_ workspaceView: WorkspaceView, didSelectItem item: WorkspaceItem) {
        workspace.selectItem(id: item.id)
        delegate?.workspaceViewController(self, didSelectWorkspace: workspace)
        updateView()
    }
    
    func workspaceView(_ workspaceView: WorkspaceView, didTogglePin item: WorkspaceItem) {
        workspace.togglePinned(item: item)
    }
    
    func workspaceView(_ workspaceView: WorkspaceView, didRequestDeleteItem item: WorkspaceItem) {
        workspace.deleteItem(item)
    }
}
