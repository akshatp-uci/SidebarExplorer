//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

class PinnedItemCell: NSCollectionViewItem {
    private let iconSize: CGFloat = 26
    private let buttonSize: CGFloat = 50
    private let cornerRadius: CGFloat = 8
    
    private var item: WorkspaceItem?
    
    override var isSelected: Bool {
        didSet { updateSelectionColor() }
    }
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        
        let imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .scaleProportionallyDown
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: iconSize),
            imageView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        self.imageView = imageView
        updateSelectionColor()
    }
    
    func configure(with item: WorkspaceItem) {
        self.item = item
        isSelected = item.isSelected
        imageView?.image = NSImage(systemSymbolName: item.icon, accessibilityDescription: item.title)
        imageView?.symbolConfiguration = .init(pointSize: iconSize, weight: .regular)
        view.toolTip = item.title
        
        updateSelectionColor()
    }
    
    private func updateSelectionColor() {
        view.layer?.backgroundColor = isSelected
            ? NSColor.controlAccentColor.cgColor
            : NSColor.gray.withAlphaComponent(0.2).cgColor
        imageView?.contentTintColor = isSelected ? .white : nil
    }
}
