//
//  SidebarExplorer
//
//  Created by Akshat Patel on 20/02/25.
//

import AppKit

extension NSView {
    func slideReplace(with newView: NSView, direction: NSRectEdge, duration: TimeInterval = 0.2) {
        guard let superview = self.superview else { return }
        
        self.wantsLayer = true
        newView.wantsLayer = true
        let currentFrame = self.frame
        
        superview.addSubview(newView)
        newView.frame = currentFrame
        let offset = direction == .maxX ? currentFrame.width : -currentFrame.width
        newView.layer?.position.x -= offset
        
        let currentViewAnimation = CABasicAnimation(keyPath: "position.x")
        currentViewAnimation.fromValue = self.layer?.position.x
        currentViewAnimation.toValue = (self.layer?.position.x ?? 0) + offset
        
        let newViewAnimation = CABasicAnimation(keyPath: "position.x")
        newViewAnimation.fromValue = newView.layer?.position.x
        newViewAnimation.toValue = (newView.layer?.position.x ?? 0) + offset

        let animations = [currentViewAnimation, newViewAnimation]
        for animation in animations {
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
        }
        
        self.layer?.add(currentViewAnimation, forKey: "slideOut")
        newView.layer?.add(newViewAnimation, forKey: "slideIn")
        
        self.layer?.position.x += offset
        newView.layer?.position.x += offset
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.removeFromSuperview()
        }
    }
    
    enum SlideType {
        case `in`
        case out
    }
    
    func addWithZoomAnimation(
        to stackView: NSStackView,
        at index: Int,
        duration: TimeInterval = 0.4,
        shouldHideLeftMostView: Bool
    ) {
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
    
    func replaceFirstButtonWithZoomAnimation(
        in stackView: NSStackView,
        duration: TimeInterval = 0.4
    ) {
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
    
    func animateConstraint(_ constraint: NSLayoutConstraint,
                           to constant: CGFloat,
                           duration: TimeInterval = 0.2)
    {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            constraint.animator().constant = constant
        }
    }
    
    func animateConstraints(
        constants: [(NSLayoutConstraint, CGFloat)] = [],
        duration: TimeInterval = 0.2
    ) {
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
}
