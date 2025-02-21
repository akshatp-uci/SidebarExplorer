//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

class WorkspaceItemCell: NSTableCellView {
    private let iconImageView: NSImageView
    private let titleLabel: NSTextField
    private var item: WorkspaceItem
    
    init(item: WorkspaceItem) {
        self.item = item
        
        // Initialize views
        self.iconImageView = NSImageView()
        self.titleLabel = NSTextField(labelWithString: "")
        
        super.init(frame: .zero)
        
        setupViews()
        configure(with: item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Configure icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.imageScaling = .scaleNone
        iconImageView.symbolConfiguration = .init(pointSize: 16, weight: .regular)
        
        // Configure title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.lineBreakMode = .byTruncatingTail
        
        // Add subviews
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with item: WorkspaceItem) {
        self.item = item
        iconImageView.image = NSImage(systemSymbolName: item.icon, accessibilityDescription: item.title)
        titleLabel.stringValue = item.title
    }
} 
