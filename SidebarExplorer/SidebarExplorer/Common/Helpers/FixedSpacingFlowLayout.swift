//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

class FixedSpacingFlowLayout: NSCollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        invalidateLayout()
    }
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        guard let collectionView = collectionView,
                collectionView.numberOfItems(inSection: 0) > 0 else {
            return super.layoutAttributesForElements(in: rect)
        }
        
        // Calculate how many items fit in a row with fixed spacing
        let sectionInset = self.sectionInset
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        let itemWidth = self.itemSize.width
        let interitemSpacing = self.minimumInteritemSpacing
        
        // Calculate max items per row with fixed spacing
        let itemsPerRow = max(1, Int(floor((availableWidth + interitemSpacing) / (itemWidth + interitemSpacing))))
        
        // Create a copy of attributes to modify
        let attributesCopy = super.layoutAttributesForElements(in: rect).map { $0.copy() as! NSCollectionViewLayoutAttributes }
        
        for (index, attribute) in attributesCopy.enumerated() {
            let row = index / itemsPerRow
            let column = index % itemsPerRow
            let x = sectionInset.left + CGFloat(column) * (itemWidth + interitemSpacing)
            let y = sectionInset.top + CGFloat(row) * (itemSize.height + minimumLineSpacing)
            attribute.frame.origin = NSPoint(x: x, y: y)
        }
        
        return attributesCopy
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return true
    }
}
