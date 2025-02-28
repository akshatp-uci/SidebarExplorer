//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

protocol WorkspacePageControllerDelegate: AnyObject {
    func workspacePageController(_ controller: WorkspacePageController, didSwitchToWorkspace workspace: Workspace)
}

class WorkspacePageController: NSPageController {
    
    // MARK: - Properties
    
    private var workspaces: [Workspace]
    private var currentWorkspaceIndex: Int
    private var previousWorkspaceIndex: Int = 0
    
    var currentWorkspace: Workspace {
        workspaces[currentWorkspaceIndex]
    }
    
    weak var workspacePageControllerDelegate: WorkspacePageControllerDelegate?
    private weak var workspaceViewControllerDelegate: WorkspaceViewControllerDelegate?
    
    // MARK: - Initialization
    
    init(
        workspaces: [Workspace] = [Workspace.nextDefaultWorkspace(after: 0)],
        currentIndex: Int = 0,
        workspaceViewControllerDelegate: WorkspaceViewControllerDelegate?
    ) {
        self.workspaces = workspaces
        self.currentWorkspaceIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
        
        self.workspaceViewControllerDelegate = workspaceViewControllerDelegate
        self.delegate = self
        self.transitionStyle = .horizontalStrip
        self.arrangedObjects = workspaces
        self.selectedIndex = currentWorkspaceIndex
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Workspace Management
    
    func addWorkspace(_ workspace: Workspace) {
        workspaces.append(workspace)
        previousWorkspaceIndex = currentWorkspaceIndex
        currentWorkspaceIndex = workspaces.count - 1
        
        // Update the page controller with animation
        arrangedObjects = workspaces
        
        // Animate from right since we're adding a new workspace
        view.slideTransition(direction: .fromRight)
        
        // Navigate to the new page
        selectedIndex = currentWorkspaceIndex
        completeTransition()
    }
    
    func removeWorkspace(at index: Int) {
        guard index < workspaces.count, workspaces.count > 1 else { return }
        
        previousWorkspaceIndex = currentWorkspaceIndex
        let isRemovingCurrentWorkspace = index == currentWorkspaceIndex
        
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
        
        arrangedObjects = workspaces
        
        if isRemovingCurrentWorkspace {
            let direction: CATransitionSubtype = index == 0 ? .fromRight : .fromLeft
            view.slideTransition(direction: direction)
        }
        
        selectedIndex = currentWorkspaceIndex
        completeTransition()
    }
    
    func switchToWorkspace(at index: Int) {
        guard index != currentWorkspaceIndex && index >= 0 && index < workspaces.count else { return }
        
        previousWorkspaceIndex = currentWorkspaceIndex
        currentWorkspaceIndex = index
        
        // Determine the slide direction based on the index change
        let direction: CATransitionSubtype = index > previousWorkspaceIndex ? .fromRight : .fromLeft
        
        // Apply the slide transition
        view.slideTransition(direction: direction)
        
        // Navigate to the selected page
        selectedIndex = index
        completeTransition()
    }
    
    // MARK: - Navigation
    
    private func navigateToPage(at index: Int) {
        if index != selectedIndex {
            selectedIndex = index
            navigateToPage(at: index)
        }
    }
}

// MARK: - NSPageControllerDelegate

extension WorkspacePageController: NSPageControllerDelegate {
    func pageController(_ pageController: NSPageController, identifierFor object: Any) -> NSPageController.ObjectIdentifier {
        guard let workspace = object as? Workspace else {
            return "unknown"
        }
        return workspace.id.uuidString
    }
    
    func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: NSPageController.ObjectIdentifier) -> NSViewController {
        let workspace = workspaces.first { $0.id.uuidString == identifier } ?? currentWorkspace
        return WorkspaceViewController(workspace: workspace, delegate: workspaceViewControllerDelegate)
    }

    func pageControllerDidEndLiveTransition(_ pageController: NSPageController) {
        // Update the current index based on the selected index
        previousWorkspaceIndex = currentWorkspaceIndex
        currentWorkspaceIndex = selectedIndex
        
        // Notify delegate about the workspace change
        workspacePageControllerDelegate?.workspacePageController(self, didSwitchToWorkspace: currentWorkspace)
    }
}
