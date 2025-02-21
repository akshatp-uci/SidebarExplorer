//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

protocol SidebarTabButtonViewDelegate: AnyObject {
    func tabButtonViewDidClick(_ buttonView: SidebarTabButtonView)
    func tabButtonView(_ buttonView: SidebarTabButtonView, didRequestDelete workspace: Workspace)
}

class SidebarTabButtonView: NSView {
    private let button: NSButton
    private var trackingArea: NSTrackingArea?

    var workspace: Workspace
    var isSelected: Bool
    var canCollapse: Bool = false
    var isCollapsed: Bool = false
    
    var index: Int
    
    weak var stackView: NSStackView?
    weak var delegate: SidebarTabButtonViewDelegate?
    
    init(
        workspace: Workspace,
        isSelected: Bool,
        index: Int,
        stackView: NSStackView?
    ) {
        self.workspace = workspace
        self.isSelected = isSelected
        self.button = NSButton(frame: .zero)
        self.index = index
        self.stackView = stackView
        super.init(frame: .zero)
        setupButton()
        setupGestures()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isBordered = false
        button.image = NSImage(systemSymbolName: workspace.icon, accessibilityDescription: workspace.name)
        
        // Set accessibility properties
        button.setAccessibilityRole(.button)
        button.setAccessibilityIdentifier("Workspace_Button_\(workspace.name)")
        button.setAccessibilityLabel(workspace.name)
        
        button.wantsLayer = true
        button.layer?.cornerRadius = 4
        
        update()
        
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.widthAnchor.constraint(equalToConstant: 26),
            button.heightAnchor.constraint(equalToConstant: 26)
        ])
        
        setupTrackingArea()
    }
    
    private func setupTrackingArea() {
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        
        if let trackingArea = trackingArea {
            addTrackingArea(trackingArea)
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        setupTrackingArea()
    }
    
    override func mouseEntered(with event: NSEvent) {
        isCollapsed = false
        update()
    }
    
    override func mouseExited(with event: NSEvent) {
        isCollapsed = true
        update()
    }
        
    func update() {
        if isSelected {
            button.contentTintColor = NSColor.controlAccentColor
            button.layer?.backgroundColor = .clear
        } else {
            button.contentTintColor = nil
            button.layer?.backgroundColor = .clear
        }
        
        if canCollapse && isCollapsed && !isSelected {
            button.image = NSImage(systemSymbolName: "circlebadge.fill", accessibilityDescription: workspace.name)
            button.layer?.anchorPoint = CGPoint(x: -0.5, y: -0.5)
            button.layer?.setAffineTransform(CGAffineTransform(scaleX: 0.5, y: 0.5))
        } else {
            button.image = NSImage(systemSymbolName: workspace.icon, accessibilityDescription: workspace.name)
            button.layer?.anchorPoint = CGPoint(x: 0, y: 0)
            button.layer?.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
        }
    }
    
    private func setupGestures() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        addGestureRecognizer(clickGesture)
        
        let rightClickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleRightClick(_:)))
        rightClickGesture.buttonMask = 0x2
        addGestureRecognizer(rightClickGesture)
    }
    
    @objc private func handleClick(_ gesture: NSClickGestureRecognizer) {
        delegate?.tabButtonViewDidClick(self)
    }
    
    @objc private func handleRightClick(_ gesture: NSClickGestureRecognizer) {
        guard let event = NSApp.currentEvent else { return }
        
        let menu = NSMenu()
        let deleteItem = NSMenuItem(title: "Delete",
                                  action: #selector(deleteWorkspace),
                                  keyEquivalent: "")
        deleteItem.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "Delete Workspace")
        deleteItem.target = self
        deleteItem.setAccessibilityIdentifier("Delete Workspace")
        menu.addItem(deleteItem)
        
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    @objc private func deleteWorkspace() {
        delegate?.tabButtonView(self, didRequestDelete: workspace)
    }
}
