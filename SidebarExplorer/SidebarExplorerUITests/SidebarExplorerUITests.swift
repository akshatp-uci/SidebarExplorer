//
//  SidebarExplorerUITests.swift
//  SidebarExplorerUITests
//
//  Created by Akshat Patel on 21/02/25.
//

import XCTest

final class SidebarExplorerUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    // MARK: - Helper Methods
    
    private func addWorkspace() {
        let addButton = app.buttons["add"]
        XCTAssertTrue(addButton.exists, "Add workspace button should exist")
        addButton.click()
    }
    
    private func deleteWorkspace(at index: Int) {
        let workspaceTitle = getWorkspaceTitle(for: index)
        let workspaceButton = app.buttons["Workspace_Button_\(workspaceTitle)"]
        XCTAssertTrue(workspaceButton.exists, "Workspace button '\(workspaceTitle)' should exist")
        
        // Perform right-click
        workspaceButton.rightClick()
        
        // Click delete menu item
        let deleteMenuItem = app.menuItems["Delete Workspace"]
        XCTAssertTrue(deleteMenuItem.exists, "Delete menu item should exist")
        deleteMenuItem.click()
    }
    
    private func verifyWorkspaceCount(_ expectedCount: Int) {
        // Find workspace buttons by their containing text
        let predicate = NSPredicate(format: "identifier BEGINSWITH 'Workspace_Button_'")
        let workspaceButtons = app.buttons.matching(predicate).count
        XCTAssertEqual(workspaceButtons, expectedCount, "Should have \(expectedCount) workspaces")
    }
    
    // Helper to get workspace title based on index
    private func getWorkspaceTitle(for index: Int) -> String {
        let defaultConfigs = [
            "Files",
            "Projects",
            "Notifications",
            "Downloads",
            "Documents"
        ]
        
        guard index < defaultConfigs.count else {
            return "Workspace \(index + 1)"
        }
        return defaultConfigs[index]
    }
    
    // MARK: - Test Cases
    
    func testAddingMultipleWorkspaces() throws {
        // Initial workspace count should be 1
        verifyWorkspaceCount(1)
        
        // Add 3 more workspaces
        for _ in 1...3 {
            addWorkspace()
        }
        
        // Verify we now have 4 workspaces
        verifyWorkspaceCount(4)
    }
    
    func testDeletingWorkspaces() throws {
        // Add two workspaces first
        addWorkspace()
        addWorkspace()
        verifyWorkspaceCount(3)
        
        // Delete the second workspace
        deleteWorkspace(at: 1)
        
        // Wait for UI to update using expectations
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true"),
            object: app.buttons["Workspace_Button_Files"]
        )
        wait(for: [expectation], timeout: 5.0)
        
        verifyWorkspaceCount(2)
    }
}
