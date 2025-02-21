### Sidebar Explorer

This project is my submission for the Kagi macOS Demo. It is a macOS application that implements a sidebar that allows us to manage multiple workspaces of items.

#### Implementation Details

- The project has been implemented using AppKit in the classic MVC architecture.
- Different features have been separated in their own groups. The 3 main features are:
  
  - Content: This is the main view that displays a different HTML page for each selected workspace item.
  - Sidebar: This feature contains the implementation of the sidebar tab. It holds a certain amount of workspaces, and we are able to add, delete and switch them with a nice animation. It automatically collapses to smaller dots when there is not enough space.
  - Worskspace: This is the feature which shows us a list of items within a workspace. We are able to pin / unpin the items 
  
- In addition to the implementation, there are also two simple UI tests as a demonstration of how we would go ahead and test this application.
