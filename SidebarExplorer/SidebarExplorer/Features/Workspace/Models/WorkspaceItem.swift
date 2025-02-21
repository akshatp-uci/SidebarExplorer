//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import Foundation

struct WorkspaceItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var icon: String
    var isSelected: Bool

    init(
        id: UUID = UUID(), 
        title: String, 
        description: String, 
        icon: String, 
        isSelected: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isSelected = isSelected
    }
}
