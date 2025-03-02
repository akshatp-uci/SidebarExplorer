//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

extension NSView {
    func addWithZoomAnimation(to stackView: NSStackView,
                              at index: Int,
                              duration: TimeInterval = 0.2,
                              shouldHideLeftMostView: Bool)
    {
        stackView.insertArrangedSubview(self, at: index)
        if shouldHideLeftMostView {
            var visibleSubviews = stackView.views
            for view in stackView.detachedViews {
                visibleSubviews.removeAll(where: { $0 == view })
            }
            if let firstVisibleView = visibleSubviews.first {
                stackView.setVisibilityPriority(.notVisible, for: firstVisibleView)
            }
        }
        alphaValue = 0
        wantsLayer = true
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            stackView.window?.layoutIfNeeded()
            layer?.anchorPoint = CGPoint(x: -0.25, y: -0.25)
            layer?.setAffineTransform(CGAffineTransform(scaleX: 0.5, y: 0.5))
        } completionHandler: { [self] in
            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                context.allowsImplicitAnimation = true
                self.alphaValue = 1
                layer?.anchorPoint = CGPoint(x: 0, y: 0)
                layer?.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
            } completionHandler: {}
        }
    }
    
    func replaceFirstButtonWithZoomAnimation(in stackView: NSStackView,
                                             duration: TimeInterval = 0.4)
    {
        var visibleSubviews = stackView.views
        for view in stackView.detachedViews {
            visibleSubviews.removeAll(where: { $0 == view })
        }
        if let firstVisibleView = visibleSubviews.first {
            stackView.setVisibilityPriority(.notVisible, for: firstVisibleView)
        }
        
        stackView.setVisibilityPriority(.mustHold, for: self)

        alphaValue = 0
        wantsLayer = true
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration / 2
            context.allowsImplicitAnimation = true
            stackView.window?.layoutIfNeeded()
        } completionHandler: { [self] in
            layer?.anchorPoint = CGPoint(x: 0, y: 0)
            layer?.setAffineTransform(CGAffineTransform(scaleX: 0, y: 0))
            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration / 2
                context.allowsImplicitAnimation = true
                self.alphaValue = 1
                layer?.setAffineTransform(.identity)
            } completionHandler: {}
        }
    }
    
    func removeWithZoomAnimation(duration: TimeInterval = 0.4) {
        guard let stackView = superview as? NSStackView else { return }
        
        if let lastDetachedView = stackView.detachedViews.last {
            stackView.setVisibilityPriority(.mustHold, for: lastDetachedView)
        }
        
        stackView.removeArrangedSubview(self)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.allowsImplicitAnimation = true
            stackView.window?.layoutIfNeeded()
            animator().alphaValue = 0
            layer?.anchorPoint = CGPoint(x: 0.5, y: -0.5)
            layer?.setAffineTransform(CGAffineTransform(scaleX: 0.5, y: 0.5))
        } completionHandler: {
            self.removeFromSuperview()
        }
    }
    
    func pressWithZoomAnimation(duration: TimeInterval = 0.2) {
        self.wantsLayer = true
        self.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
        if let layer = self.layer {
            let position = layer.position
            if position.x == 0 {
                layer.position = CGPoint(x: position.x + layer.bounds.width * 0.5,
                                         y: position.y + layer.bounds.height * 0.5)
            }
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.1
                context.allowsImplicitAnimation = true
                self.layer?.setAffineTransform(CGAffineTransform(scaleX: 0.8, y: 0.8))
            } completionHandler: { [self] in
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.1
                    context.allowsImplicitAnimation = true
                    self.layer?.setAffineTransform(CGAffineTransform.identity)
                } completionHandler: {}
            }
        }
    }
    
    func animateConstraints(constants: [(NSLayoutConstraint, CGFloat)] = [],
                            duration: TimeInterval = 0.2)
    {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Animate constraint constants
            for (constraint, constant) in constants {
                constraint.animator().constant = constant
            }
        } completionHandler: {
            self.window?.layoutIfNeeded()
        }
    }
    
    func slideTransition(type: CATransitionType = .push,
                         direction: CATransitionSubtype,
                         duration: TimeInterval = 0.3)
    {
        wantsLayer = true
        let transition = CATransition()
        transition.type = type
        transition.subtype = direction
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer?.add(transition, forKey: "slideTransition")
    }
}
