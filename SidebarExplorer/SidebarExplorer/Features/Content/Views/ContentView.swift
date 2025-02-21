//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit
import WebKit

class ContentView: NSView {
    private let webView: WKWebView
    
    override init(frame frameRect: NSRect) {
        let config = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init(frame: frameRect)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func loadContent(for workspace: Workspace) {
        var selectedItemText = "Selected item from list: "
        var selectedItem = workspace.listItems.first(where: { $0.isSelected })
        if selectedItem == nil {
            selectedItemText = "Selected pinned item: "
            selectedItem = workspace.pinnedItems.first(where: { $0.isSelected })
        }
        let html = """
        <!DOCTYPE html>
        <html>
        <body bgcolor="#f0f2f5">
            <table width="80%" align="center" cellpadding="35" cellspacing="0" bgcolor="white" 
                   style="margin-top: 100px; border-radius: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                <tr>
                    <td align="left">
                        <font face="SF Pro Display, -apple-system, BlinkMacSystemFont" size="3" color="#1d1d1f">
                            <h1 style="margin: 0 0 9px 0;">Workspace: \(workspace.name)</h1>
                        </font>
                        <font face="SF Pro Text, -apple-system, BlinkMacSystemFont" size="2" color="#424245">
                            <p style="margin: 8px 0;">Workspace ID: \(workspace.id)</p>
                        </font>
                        <font face="SF Pro Text, -apple-system, BlinkMacSystemFont" size="3" color="#6e6e73">
                            <p style="margin: 8px 0;">\(selectedItemText)<b>\(selectedItem?.title ?? "None")</b></p>
                        </font>
                    </td>
                </tr>
            </table>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}
