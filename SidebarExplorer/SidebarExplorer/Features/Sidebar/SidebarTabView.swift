//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

protocol SidebarTabViewDelegate: AnyObject {
    func sidebarTabView(_ tabView: SidebarTabView, didSelectWorkspace index: Int)
    func sidebarTabViewDidRequestAddWorkspace(_ tabView: SidebarTabView)
    func sidebarTabView(_ tabView: SidebarTabView, didRequestDeleteWorkspaceAt index: Int)
    func sidebarTabView(_ tabView: SidebarTabView, didRequestShowWorkspaceList button: NSButton)
}

class SidebarTabView: NSView {
    // MARK: - Properties
    
    weak var delegate: SidebarTabViewDelegate?
    private let stackView = NSStackView()
    private let stackBackgroundView = NSView()
    private let addButton = NSButton()
    private let dropdownButton = NSButton()
    private let topDivider = NSBox()
    private let bottomDivider = NSBox()
    
    private var currentButtons: [SidebarTabButtonView] = []
    
    private var maxExpandedButtonCount: Int {
        return Int(floor(stackBackgroundView.bounds.width / 26))
    }
    
    private var maxCompressedButtonCount: Int {
        return Int(floor(stackBackgroundView.bounds.width / 24))
    }
            
    // MARK: - Initialization
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        // Setup dividers
        topDivider.translatesAutoresizingMaskIntoConstraints = false
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        topDivider.boxType = .separator
        bottomDivider.boxType = .separator
        
        // Setup stack view as the root view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .horizontal
        stackView.spacing = 6
        stackView.alignment = .centerY
        stackView.distribution = .equalCentering
        stackView.setClippingResistancePriority(.defaultLow, for: .horizontal)
        
        stackBackgroundView.wantsLayer = true
        stackBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup Add Button
        addButton.bezelStyle = .roundRect
        addButton.isBordered = false
        addButton.image = NSImage(systemSymbolName: "plus.circle.dashed", accessibilityDescription: "Add Workspace")
        addButton.target = self
        addButton.action = #selector(addWorkspaceButtonClicked(_:))
        addButton.setAccessibilityIdentifier("add")
        
        // Setup dropdown button
        dropdownButton.translatesAutoresizingMaskIntoConstraints = false
        dropdownButton.bezelStyle = .roundRect
        dropdownButton.isBordered = false
        dropdownButton.image = NSImage(systemSymbolName: "chevron.down", accessibilityDescription: "Show Workspaces")
        dropdownButton.target = self
        dropdownButton.action = #selector(dropdownButtonClicked(_:))
        
        // Add views to hierarchy
        addSubview(topDivider)
        addSubview(bottomDivider)
        addSubview(stackBackgroundView)
        stackBackgroundView.addSubview(stackView)
        addSubview(dropdownButton)
        
        // Add the add button to the stack view
        stackView.addArrangedSubview(addButton)
        
        NSLayoutConstraint.activate([
            // Divider constraints
            topDivider.leadingAnchor.constraint(equalTo: leadingAnchor),
            topDivider.trailingAnchor.constraint(equalTo: trailingAnchor),
            topDivider.topAnchor.constraint(equalTo: topAnchor),
            
            bottomDivider.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomDivider.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomDivider.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack background view contraints
            stackBackgroundView.topAnchor.constraint(equalTo: topDivider.bottomAnchor),
            stackBackgroundView.bottomAnchor.constraint(equalTo: bottomDivider.topAnchor),
            stackBackgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            stackBackgroundView.trailingAnchor.constraint(lessThanOrEqualTo: dropdownButton.leadingAnchor, constant: -8),
            
            // Stack view constraints
            stackView.centerXAnchor.constraint(equalTo: stackBackgroundView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: stackBackgroundView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: stackBackgroundView.bottomAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: stackBackgroundView.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: stackBackgroundView.trailingAnchor),
            
            dropdownButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dropdownButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateButtonStates()
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            stackView.layoutSubtreeIfNeeded()
        }
    }
    
    private func updateButtonStates() {
        if currentButtons.count < maxExpandedButtonCount {
            stackView.spacing = 6
            for button in currentButtons {
                button.canCollapse = false
                button.isCollapsed = false
                if stackView.views.contains(button) {
                    stackView.setVisibilityPriority(.mustHold, for: button)
                }
                button.update()
            }
        } else if currentButtons.count >= maxExpandedButtonCount && currentButtons.count <= maxCompressedButtonCount {
            stackView.spacing = 0
            for button in currentButtons {
                button.canCollapse = true
                button.isCollapsed = true
                if stackView.views.contains(button) {
                    stackView.setVisibilityPriority(.mustHold, for: button)
                }
                button.update()
            }
        } else if currentButtons.count > maxCompressedButtonCount {
            stackView.spacing = 0
            for button in currentButtons {
                button.canCollapse = true
                button.isCollapsed = true
                if stackView.views.contains(button) {
                    stackView.setVisibilityPriority(button.isSelected ? .mustHold : .notVisible, for: button)
                }
                button.update()
            }
            
            var remainingButtonCount = maxCompressedButtonCount - 1
            for button in currentButtons.reversed() {
                if !button.isSelected && stackView.views.contains(button) {
                    if remainingButtonCount > 0 {
                        stackView.setVisibilityPriority(.mustHold, for: button)
                        remainingButtonCount -= 1
                    }
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    func setupInitialWorkspaces(with workspaces: [Workspace], currentIndex: Int) {
        // Clear any existing buttons
        currentButtons.forEach { $0.removeFromSuperview() }
        currentButtons.removeAll()
        
        // Create buttons for all workspaces
        for (index, workspace) in workspaces.enumerated() {
            let buttonView = createButtonView(workspace: workspace, isSelected: index == currentIndex)
            stackView.insertArrangedSubview(buttonView, at: stackView.arrangedSubviews.count - 1)
            currentButtons.append(buttonView)
        }
    }
    
    func removeWorkspaceButton(at index: Int) {
        guard index < currentButtons.count else { return }
        let buttonView = currentButtons.remove(at: index)
        for (newIndex, button) in currentButtons.enumerated() {
            button.index = newIndex
        }
        updateButtonStates()
        buttonView.removeWithZoomAnimation()
    }
    
    func addWorkspaceButton(for workspace: Workspace) {
        let buttonView = createButtonView(workspace: workspace, isSelected: false)
        currentButtons.append(buttonView)
        updateButtonStates()
        buttonView.addWithZoomAnimation(
            to: stackView,
            at: stackView.arrangedSubviews.count - 1,
            shouldHideLeftMostView: (stackView.views.count - stackView.detachedViews.count) > maxCompressedButtonCount
        )
    }
    
    func configure(for currentIndex: Int) {
        var selectedButton: SidebarTabButtonView? = nil
        for (index, button) in currentButtons.enumerated() {
            button.isSelected = index == currentIndex
            if button.isSelected {
                selectedButton = button
            }
            button.update(withZoomAnimation: button.isSelected && button.canCollapse)
        }
        
        if let selectedButton = selectedButton,
           stackView.detachedViews.contains(selectedButton) {
            selectedButton.replaceFirstButtonWithZoomAnimation(in: stackView)
        }
    }
    
    private func createButtonView(workspace: Workspace, isSelected: Bool) -> SidebarTabButtonView {
        let buttonView = SidebarTabButtonView(workspace: workspace, isSelected: isSelected, index: currentButtons.count , stackView: stackView)
        buttonView.delegate = self
        return buttonView
    }
    
    // MARK: - Actions
    
    @objc private func addWorkspaceButtonClicked(_ sender: NSButton) {
        delegate?.sidebarTabViewDidRequestAddWorkspace(self)
    }
    
    @objc private func dropdownButtonClicked(_ sender: NSButton) {
        delegate?.sidebarTabView(self, didRequestShowWorkspaceList: sender)
    }
}

// MARK: - SidebarTabButtonViewDelegate

extension SidebarTabView: SidebarTabButtonViewDelegate {
    func tabButtonViewDidClick(_ buttonView: SidebarTabButtonView) {
        delegate?.sidebarTabView(self, didSelectWorkspace: buttonView.index)
    }
    
    func tabButtonView(_ buttonView: SidebarTabButtonView, didRequestDelete workspace: Workspace) {
        guard stackView.arrangedSubviews.count > 2 else { return }
        delegate?.sidebarTabView(self, didRequestDeleteWorkspaceAt: buttonView.index)
    }
}
