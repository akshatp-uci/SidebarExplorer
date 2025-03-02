//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

protocol WorkspaceViewDelegate: AnyObject {
    func workspaceView(_ workspaceView: WorkspaceView, didSelectItem item: WorkspaceItem)
    func workspaceView(_ workspaceView: WorkspaceView, didTogglePin item: WorkspaceItem)
    func workspaceView(_ workspaceView: WorkspaceView, didRequestDeleteItem item: WorkspaceItem)
}

protocol WorkspaceViewDataSource: AnyObject {
    var listItems: [WorkspaceItem] { get }
    var pinnedItems: [WorkspaceItem] { get }
}

class WorkspaceView: NSView {
    // MARK: - Properties
    
    weak var delegate: WorkspaceViewDelegate?
    weak var dataSource: WorkspaceViewDataSource?
    
    private let titleLabel = NSTextField(labelWithString: "")
    private let pinnedItemCollectionView = NSCollectionView()
    private let itemListTableView = NSTableView()
    private let itemListScrollView = ForwardingScrollView()
    
    private var pinnedItemsHeightConstraint: NSLayoutConstraint!
    
    private var contextMenuRow: Int = -1
    private var pinnedContextMenuRow: Int = -1
    
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
        wantsLayer = true
        setupTitleLabel()
        setupPinnedItemsArea()
        setupTableView()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabelColor
        titleLabel.alignment = .left
        addSubview(titleLabel)
    }
    
    private func setupPinnedItemsArea() {
        // Configure collection view
        pinnedItemCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a custom flow layout
        let flowLayout = FixedSpacingFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = NSSize(width: 56, height: 50)
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.minimumLineSpacing = 8
        flowLayout.sectionInset = NSEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        pinnedItemCollectionView.collectionViewLayout = flowLayout
        pinnedItemCollectionView.delegate = self
        pinnedItemCollectionView.dataSource = self
        pinnedItemCollectionView.isSelectable = true
        pinnedItemCollectionView.allowsMultipleSelection = false
        pinnedItemCollectionView.backgroundColors = [.clear]
        
        // Register the cell class
        pinnedItemCollectionView.register(PinnedItemCell.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("PinnedItemCell"))
        
        let contextMenu = createPinnedItemsContextMenu()
        contextMenu.delegate = self
        pinnedItemCollectionView.menu = contextMenu
        
        // Initialize height constraint
        pinnedItemsHeightConstraint = pinnedItemCollectionView.heightAnchor.constraint(equalToConstant: 0)
        
        addSubview(pinnedItemCollectionView)
    }
    
    private func createPinnedItemsContextMenu() -> NSMenu {
        let menu = NSMenu()
        
        let unpinItem = NSMenuItem(title: "Unpin", action: #selector(unpinSelectedItem(_:)), keyEquivalent: "")
        unpinItem.image = NSImage(systemSymbolName: "pin.slash", accessibilityDescription: "Unpin")
        unpinItem.setAccessibilityIdentifier("Unpin")
        menu.addItem(unpinItem)
        
        let deleteItem = NSMenuItem(title: "Delete", action: #selector(deletePinnedItem(_:)), keyEquivalent: "")
        deleteItem.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "Delete")
        deleteItem.setAccessibilityIdentifier("Delete")
        menu.addItem(deleteItem)
        
        return menu
    }
    
    private func setupTableView() {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ItemColumn"))
        itemListTableView.addTableColumn(column)
        itemListTableView.headerView = nil
        itemListTableView.delegate = self
        itemListTableView.dataSource = self
        itemListTableView.rowHeight = 36
        
        let contextMenu = createContextMenu()
        contextMenu.delegate = self
        itemListTableView.menu = contextMenu
        
        itemListScrollView.translatesAutoresizingMaskIntoConstraints = false
        itemListScrollView.documentView = itemListTableView
        itemListScrollView.hasVerticalScroller = true
        itemListScrollView.autohidesScrollers = true
        itemListScrollView.drawsBackground = false
        itemListScrollView.verticalScrollElasticity = .allowed
        
        addSubview(itemListScrollView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            pinnedItemCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            pinnedItemCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pinnedItemCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pinnedItemsHeightConstraint,
            
            itemListScrollView.topAnchor.constraint(equalTo: pinnedItemCollectionView.bottomAnchor, constant: 4),
            itemListScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemListScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            itemListScrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createContextMenu() -> NSMenu {
        let menu = NSMenu()
        
        let pinItem = NSMenuItem(title: "Pin", action: #selector(pinSelectedItem(_:)), keyEquivalent: "")
        pinItem.image = NSImage(systemSymbolName: "pin", accessibilityDescription: "Pin")
        pinItem.setAccessibilityIdentifier("Pin")
        menu.addItem(pinItem)
        
        let deleteItem = NSMenuItem(title: "Delete", action: #selector(deleteSelectedItem(_:)), keyEquivalent: "")
        deleteItem.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "Delete")
        deleteItem.setAccessibilityIdentifier("Delete")
        menu.addItem(deleteItem)
        
        return menu
    }
    
    // MARK: - Public Methods
    
    func updateTitle(_ title: String) {
        titleLabel.stringValue = title
    }
    
    func updatePinnedItemsArea(_ items: [WorkspaceItem], animated: Bool = true) {
        // Use the collection view width to determine the number of items per row
        let flowLayout = pinnedItemCollectionView.collectionViewLayout as? FixedSpacingFlowLayout
        flowLayout?.invalidateLayout()
        
        // Calculate the height needed based on the number of items and the current width
        let availableWidth = bounds.width
        let sectionInset = (flowLayout?.sectionInset ?? NSEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
        let itemWidth: CGFloat = 56
        let itemSpacing: CGFloat = 8
        let usableWidth = availableWidth - sectionInset.left - sectionInset.right
        let itemsPerRow = max(1, Int(floor((usableWidth + itemSpacing) / (itemWidth + itemSpacing))))
        let numberOfRows = items.isEmpty ? 0 : Int(ceil(Double(items.count) / Double(itemsPerRow)))
        
        // Calculate the total height needed (item height + spacing + insets)
        let itemHeight: CGFloat = 50
        let totalHeight = items.isEmpty ? 0 : CGFloat(numberOfRows) * (itemHeight + (numberOfRows > 1 ? flowLayout?.minimumLineSpacing ?? 8 : 0)) + sectionInset.top + sectionInset.bottom
        
        animateConstraints(
            constants: [(pinnedItemsHeightConstraint, totalHeight)],
            duration: animated ? 0.2 : 0.0
        )
    }
    
    func reloadItems() {
        itemListTableView.reloadData()
    }
    
    func updateListSelection(_ index: Int?) {
        itemListTableView.deselectAll(nil)
        if let index = index {
            itemListTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        }
    }
    
    func updatePinnedSelection(_ index: Int?) {
        pinnedItemCollectionView.deselectAll(nil)
        if let index = index {
            pinnedItemCollectionView.selectItems(at: [IndexPath(item: index, section: 0)], scrollPosition: .left)
        }
    }
}

// MARK: - Actions

extension WorkspaceView {
    @objc private func pinSelectedItem(_ sender: NSMenuItem) {
        guard contextMenuRow >= 0,
              contextMenuRow < items.count
        else { return }
        
        delegate?.workspaceView(self, didTogglePin: items[contextMenuRow])
        
        itemListTableView.removeRows(at: IndexSet(integer: contextMenuRow), withAnimation: .effectFade)
        let indexPath = IndexPath(item: 0, section: 0)
        pinnedItemCollectionView.animator().performBatchUpdates {
            pinnedItemCollectionView.insertItems(at: [indexPath])
        }
        pinnedItemCollectionView.scrollToItems(at: [indexPath], scrollPosition: .leadingEdge)
        
        let item = pinnedItems[indexPath.item]
        if item.isSelected {
            updatePinnedSelection(indexPath.item)
        }
        
        updatePinnedItemsArea(pinnedItems)
    }
    
    @objc private func unpinSelectedItem(_ sender: NSMenuItem) {
        guard pinnedContextMenuRow >= 0,
              pinnedContextMenuRow < pinnedItems.count
        else { return }
        
        delegate?.workspaceView(self, didTogglePin: pinnedItems[pinnedContextMenuRow])
        
        pinnedItemCollectionView.animator().performBatchUpdates {
            let indexPath = IndexPath(item: pinnedContextMenuRow, section: 0)
            pinnedItemCollectionView.deleteItems(at: [indexPath])
        }
        itemListTableView.insertRows(at: IndexSet(integer: 0), withAnimation: .effectFade)
        itemListTableView.scrollRowToVisible(0)
        
        if let item = items.first, item.isSelected {
            itemListTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
        updatePinnedItemsArea(pinnedItems)
    }
    
    @objc private func deleteSelectedItem(_ sender: NSMenuItem) {
        guard contextMenuRow >= 0,
              contextMenuRow < items.count
        else { return }
        
        delegate?.workspaceView(self, didRequestDeleteItem: items[contextMenuRow])
        itemListTableView.removeRows(at: IndexSet(integer: contextMenuRow), withAnimation: .effectFade)
    }
    
    @objc private func deletePinnedItem(_ sender: NSMenuItem) {
        guard pinnedContextMenuRow >= 0,
              pinnedContextMenuRow < pinnedItems.count
        else { return }
        
        delegate?.workspaceView(self, didRequestDeleteItem: pinnedItems[pinnedContextMenuRow])
        
        pinnedItemCollectionView.animator().performBatchUpdates {
            let indexPath = IndexPath(item: pinnedContextMenuRow, section: 0)
            pinnedItemCollectionView.deleteItems(at: [indexPath])
        }
        updatePinnedItemsArea(pinnedItems)
    }
}

// MARK: - NSTableViewDelegate & NSTableViewDataSource

extension WorkspaceView: NSTableViewDelegate, NSTableViewDataSource {
    var items: [WorkspaceItem] { dataSource?.listItems ?? [] }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < items.count else { return nil }
        
        let cellIdentifier = NSUserInterfaceItemIdentifier("WorkspaceItemCell")
        let item = items[row]
        
        let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? WorkspaceItemCell
            ?? WorkspaceItemCell(item: item)
        
        cell.identifier = cellIdentifier
        cell.configure(with: item)
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        
        guard tableView.selectedRow >= 0,
              tableView.selectedRow < items.count
        else { return }
        
        let selectedItem = items[tableView.selectedRow]
        if !selectedItem.isSelected {
            delegate?.workspaceView(self, didSelectItem: selectedItem)
        }
    }
}

// MARK: - NSCollectionViewDataSource and NSCollectionViewDelegateFlowLayout

extension WorkspaceView: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    var pinnedItems: [WorkspaceItem] { dataSource?.pinnedItems ?? [] }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return pinnedItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("PinnedItemCell"), for: indexPath)
        
        if let pinnedItem = item as? PinnedItemCell {
            pinnedItem.configure(with: pinnedItems[indexPath.item])
        }
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first,
              indexPath.item < pinnedItems.count
        else { return }
        
        let selectedItem = pinnedItems[indexPath.item]
        if !selectedItem.isSelected {
            delegate?.workspaceView(self, didSelectItem: selectedItem)
        }
    }
}

// MARK: - NSMenuDelegate

extension WorkspaceView: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        if menu == pinnedItemCollectionView.menu {
            let point = pinnedItemCollectionView.window?.convertPoint(fromScreen: NSEvent.mouseLocation) ?? .zero
            let localPoint = pinnedItemCollectionView.convert(point, from: nil)
            if let indexPath = pinnedItemCollectionView.indexPathForItem(at: localPoint) {
                pinnedContextMenuRow = indexPath.item
            }
        } else {
            let point = itemListTableView.window?.convertPoint(fromScreen: NSEvent.mouseLocation) ?? .zero
            let localPoint = itemListTableView.convert(point, from: nil)
            contextMenuRow = itemListTableView.row(at: localPoint)
        }
    }
}
