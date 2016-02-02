//
//  RAReorderableLayout.swift
//  RAReorderableLayout
//
//  Created by Ryo Aoyama on 10/12/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

@objc public protocol RAReorderableLayoutDelegate: UICollectionViewDelegateFlowLayout {
    optional func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, willMoveToIndexPath toIndexPath: NSIndexPath)
    optional func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath)
    
    optional func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, canMoveToIndexPath: NSIndexPath) -> Bool
    
    optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, willBeginDraggingItemAtIndexPath indexPath: NSIndexPath)
    optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, didBeginDraggingItemAtIndexPath indexPath: NSIndexPath)
    optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, willEndDraggingItemToIndexPath indexPath: NSIndexPath)
    optional func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, didEndDraggingItemToIndexPath indexPath: NSIndexPath)
}

@objc public protocol RAReorderableLayoutDataSource: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    
    optional func collectionView(collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat
    optional func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets
    optional func scrollTrigerPaddingInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets
    optional func scrollSpeedValueInCollectionView(collectionView: UICollectionView) -> CGFloat
}

public class RAReorderableLayout: UICollectionViewFlowLayout {
    
    private enum ScrollDirection {
        case Upward
        case Downward
        case Anchor
        
        private func scrollValue(speedValue speedValue: CGFloat, percentage: CGFloat) -> CGFloat {
            var value: CGFloat = 0.0
            switch self {
            case .Upward:
                value = -speedValue
            case .Downward:
                value = speedValue
            case .Anchor:
                return 0
            }
            
            let proofedPercentage: CGFloat = max(min(1.0, percentage), 0)
            return value * proofedPercentage
        }
    }
    
    public weak var delegate: RAReorderableLayoutDelegate? {
        set {
            collectionView?.delegate = delegate
        }
        get {
            return collectionView?.delegate as? RAReorderableLayoutDelegate
        }
    }
    
    public weak var datasource: RAReorderableLayoutDataSource? {
        set {
            collectionView?.delegate = delegate
        }
        get {
            return collectionView?.dataSource as? RAReorderableLayoutDataSource
        }
    }
    
    private var displayLink: CADisplayLink?
    
    private var longPress: UILongPressGestureRecognizer?
    
    private var panGesture: UIPanGestureRecognizer?
    
    private var continuousScrollDirection = ScrollDirection.Anchor
    
    private var cellFakeView: RACellFakeView?
    
    private var panTranslation: CGPoint?
    
    private var fakeCellCenter: CGPoint?
    
    public var trigerInsets = UIEdgeInsets(top: 100.0, left: 100.0, bottom: 100.0, right: 100.0)
    
    public var trigerPadding = UIEdgeInsetsZero
    
    public var scrollSpeedValue = CGFloat(10.0)
    
    private var offsetFromTop: CGFloat {
        let contentOffset = collectionView!.contentOffset
        return scrollDirection == .Vertical ? contentOffset.y : contentOffset.x
    }
    
    private var insetsTop: CGFloat {
        let contentInsets = collectionView!.contentInset
        return scrollDirection == .Vertical ? contentInsets.top : contentInsets.left
    }
    
    private var insetsEnd: CGFloat {
        let contentInsets = collectionView!.contentInset
        return scrollDirection == .Vertical ? contentInsets.bottom : contentInsets.right
    }
    
    private var contentLength: CGFloat {
        let contentSize = collectionView!.contentSize
        return scrollDirection == .Vertical ? contentSize.height : contentSize.width
    }
    
    private var collectionViewLength: CGFloat {
        let collectionViewSize = collectionView!.bounds.size
        return scrollDirection == .Vertical ? collectionViewSize.height : collectionViewSize.width
    }
    
    private var fakeCellTopEdge: CGFloat? {
        if let fakeCell = cellFakeView {
            return scrollDirection == .Vertical ? CGRectGetMinY(fakeCell.frame) : CGRectGetMinX(fakeCell.frame)
        }
        return nil
    }
    
    private var fakeCellEndEdge: CGFloat? {
        if let fakeCell = cellFakeView {
            return scrollDirection == .Vertical ? CGRectGetMaxY(fakeCell.frame) : CGRectGetMaxX(fakeCell.frame)
        }
        return nil
    }
    
    private var trigerInsetTop: CGFloat {
        return scrollDirection == .Vertical ? trigerInsets.top : trigerInsets.left
    }
    
    private var trigerInsetEnd: CGFloat {
        return scrollDirection == .Vertical ? trigerInsets.top : trigerInsets.left
    }
    
    private var trigerPaddingTop: CGFloat {
        if scrollDirection == .Vertical {
            return trigerPadding.top
        } else {
            return trigerPadding.left
        }
    }
    
    private var trigerPaddingEnd: CGFloat {
        if scrollDirection == .Vertical {
            return trigerPadding.bottom
        } else {
            return trigerPadding.right
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureObserver()
    }
    
    override init() {
        super.init()
        configureObserver()
    }
    
    deinit {
        removeObserver(self, forKeyPath: "collectionView")
    }
    
    override public func prepareLayout() {
        super.prepareLayout()
        
        // scroll triger insets
        if let insets = self.datasource?.scrollTrigerEdgeInsetsInCollectionView?(self.collectionView!) {
            trigerInsets = insets
        }
        
        // scroll trier padding
        if let padding = self.datasource?.scrollTrigerPaddingInCollectionView?(self.collectionView!) {
            trigerPadding = padding
        }
        
        // scroll speed value
        if let speed = self.datasource?.scrollSpeedValueInCollectionView?(self.collectionView!) {
            scrollSpeedValue = speed
        }
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElementsInRect(rect) else { return nil }
        
        for attribute in attributes where attribute.representedElementCategory == .Cell && attribute.indexPath.isEqual(cellFakeView?.indexPath) {
            attribute.alpha = datasource?.collectionView?(collectionView!, reorderingItemAlphaInSection: attribute.indexPath.section) ?? 0
        }
        
        return attributes
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "collectionView" {
            setUpGestureRecognizers()
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    private func configureObserver() {
        addObserver(self, forKeyPath: "collectionView", options: [], context: nil)
    }
    
    private func setUpDisplayLink() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: "continuousScroll")
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    private func invalidateDisplayLink() {
        continuousScrollDirection = .Anchor
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // begein scroll
    private func beginScrollIfNeeded() {
        guard nil != cellFakeView else { return }
        
        let offset = offsetFromTop
        _ = insetsTop
        _ = insetsEnd
        
        let trigerInsetTop = self.trigerInsetTop
        let trigerInsetEnd = self.trigerInsetEnd
        let paddingTop = self.trigerPaddingTop
        let paddingEnd = self.trigerPaddingEnd
        let length = self.collectionViewLength
        let fakeCellTopEdge = self.fakeCellTopEdge
        let fakeCellEndEdge = self.fakeCellEndEdge
        
        if  fakeCellTopEdge <= offset + paddingTop + trigerInsetTop {
            self.continuousScrollDirection = .Upward
            self.setUpDisplayLink()
        } else if fakeCellEndEdge >= offset + length - paddingEnd - trigerInsetEnd {
            self.continuousScrollDirection = .Downward
            self.setUpDisplayLink()
        } else {
            self.invalidateDisplayLink()
        }
    }
    
    // move item
    private func moveItemIfNeeded() {
        var atIndexPath: NSIndexPath?
        var toIndexPath: NSIndexPath?
        if let fakeCell = cellFakeView {
            atIndexPath = fakeCell.indexPath
            toIndexPath = collectionView!.indexPathForItemAtPoint(cellFakeView!.center)
        }
        
        if nil == atIndexPath || nil == toIndexPath || atIndexPath!.isEqual(toIndexPath) {
            return
        }
        
        // can move item
        if let canMove = delegate?.collectionView?(collectionView!, atIndexPath: atIndexPath!, canMoveToIndexPath: toIndexPath!) {
            if !canMove {
                return
            }
        }
        
        // will move item
        delegate?.collectionView?(collectionView!, atIndexPath: atIndexPath!, willMoveToIndexPath: toIndexPath!)
        
        let attribute = layoutAttributesForItemAtIndexPath(toIndexPath!)!
        collectionView!.performBatchUpdates({ () -> Void in
            self.cellFakeView!.indexPath = toIndexPath
            self.cellFakeView!.cellFrame = attribute.frame
            self.cellFakeView!.changeBoundsIfNeeded(attribute.bounds)
            
            self.collectionView!.deleteItemsAtIndexPaths([atIndexPath!])
            self.collectionView!.insertItemsAtIndexPaths([toIndexPath!])
            
            // did move item
            self.delegate?.collectionView?(self.collectionView!, atIndexPath: atIndexPath!, didMoveToIndexPath: toIndexPath!)
            }, completion:nil)
    }
    
    internal func continuousScroll() {
        guard nil != cellFakeView else { return }
        
        let percentage = calcTrigerPercentage()
        var scrollRate = continuousScrollDirection.scrollValue(speedValue: scrollSpeedValue, percentage: percentage)
        
        let offset = self.offsetFromTop
        let insetTop = self.insetsTop
        let insetEnd = self.insetsEnd
        let length = self.collectionViewLength
        let contentLength = self.contentLength
        
        if contentLength + insetTop + insetEnd <= length {
            return
        }
        
        if offset + scrollRate <= -insetTop {
            scrollRate = -insetTop - offset
        } else if offset + scrollRate >= contentLength + insetEnd - length {
            scrollRate = contentLength + insetEnd - length - offset
        }
        
        collectionView!.performBatchUpdates({ () -> Void in            
            switch self.scrollDirection {
            case .Vertical:
                self.fakeCellCenter?.y += scrollRate
                self.cellFakeView?.center.y = self.fakeCellCenter!.y + self.panTranslation!.y
                self.collectionView?.contentOffset.y += scrollRate
            case .Horizontal:
                self.fakeCellCenter?.x += scrollRate
                self.cellFakeView?.center.x = self.fakeCellCenter!.x + self.panTranslation!.x
                self.collectionView?.contentOffset.x += scrollRate
            }
            }, completion: nil)
        
        moveItemIfNeeded()
    }
    
    private func calcTrigerPercentage() -> CGFloat {
        guard nil != cellFakeView else { return 0 }
        
        let offset = self.offsetFromTop
        let offsetEnd = self.offsetFromTop + self.collectionViewLength
        let insetTop = self.insetsTop
        _ = self.insetsEnd
        let trigerInsetTop = self.trigerInsetTop
        let trigerInsetEnd = self.trigerInsetEnd
        _ = self.trigerPaddingTop
        let paddingEnd = self.trigerPaddingEnd
        
        var percentage: CGFloat = 0
        
        switch continuousScrollDirection {
        case .Upward:
            if let fakeCellEdge = fakeCellTopEdge {
                percentage = 1.0 - ((fakeCellEdge - (offset + trigerPaddingTop)) / trigerInsetTop)
            }
        case .Downward:
            if let fakeCellEdge = fakeCellEndEdge {
                percentage = 1.0 - (((insetTop + offsetEnd - paddingEnd) - (fakeCellEdge + insetTop)) / trigerInsetEnd)
            }
        case .Anchor: ()
        }
        
        // 0 <= percentage <= 1.0
        percentage = max(0, min(1.0, percentage))
        
        return percentage
    }
    
    // gesture recognizers
    private func setUpGestureRecognizers() {
        guard nil != collectionView else { return }
        
        longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        longPress?.delegate = self
        panGesture?.delegate = self
        panGesture?.maximumNumberOfTouches = 1
        
        if let gestures = collectionView?.gestureRecognizers {
            for case let gesture as UILongPressGestureRecognizer in gestures {
                gesture.requireGestureRecognizerToFail(self.longPress!)
            }
        }
        
        collectionView?.addGestureRecognizer(longPress!)
        collectionView?.addGestureRecognizer(panGesture!)
    }
    
    public func cancelDrag() {
        cancelDrag(toIndexPath: nil)
    }
    
    private func cancelDrag(toIndexPath toIndexPath: NSIndexPath!) {
        guard nil != cellFakeView else { return }
        
        // will end drag item
        delegate?.collectionView?(collectionView!, collectionViewLayout: self, willEndDraggingItemToIndexPath: toIndexPath)
        
        collectionView?.scrollsToTop = true
        
        fakeCellCenter = nil
        
        invalidateDisplayLink()
        
        cellFakeView!.pushBackView { () -> Void in
            self.cellFakeView!.removeFromSuperview()
            self.cellFakeView = nil
            self.invalidateLayout()
            
            // did end drag item
            self.delegate?.collectionView?(self.collectionView!, collectionViewLayout: self, didEndDraggingItemToIndexPath: toIndexPath)
        }
    }
}


// MARK: - RAReorderableLayout: UIGestureRecognizerDelegate

extension RAReorderableLayout: UIGestureRecognizerDelegate {
    
    // gesture recognize delegate
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        // allow move item
        if let indexPath = collectionView?.indexPathForItemAtPoint(gestureRecognizer.locationInView(collectionView)) {
            if delegate?.collectionView?(collectionView!, allowMoveAtIndexPath: indexPath) == false {
                return false
            }
        }
        
        if gestureRecognizer.isEqual(longPress) {
            if collectionView!.panGestureRecognizer.state != .Possible && collectionView!.panGestureRecognizer.state != .Failed {
                return false
            }
        } else if gestureRecognizer.isEqual(panGesture) {
            if longPress!.state == .Possible || longPress!.state == .Failed {
                return false
            }
        }
        
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(longPress) {
            if otherGestureRecognizer.isEqual(panGesture) {
                return true
            }
        } else if gestureRecognizer.isEqual(panGesture) {
            return otherGestureRecognizer.isEqual(longPress)
        } else if gestureRecognizer.isEqual(collectionView?.panGestureRecognizer) {
            if longPress!.state != .Possible || longPress!.state != .Failed {
                return false
            }
        }
        
        return true
    }
}


// MARK: - RAReorderableLayout: Target-Action

internal extension RAReorderableLayout {
    
    // long press gesture
    internal func handleLongPress(longPress: UILongPressGestureRecognizer!) {
        var indexPathOptional = collectionView?.indexPathForItemAtPoint(longPress.locationInView(collectionView)) ?? nil
        if nil != cellFakeView {
            indexPathOptional = cellFakeView!.indexPath
        }
        
        guard let indexPath = indexPathOptional else { return }
        
        switch longPress.state {
        case .Began:
            // will begin drag item
            delegate?.collectionView?(collectionView!, collectionViewLayout: self, willBeginDraggingItemAtIndexPath: indexPath)
            
            collectionView?.scrollsToTop = false
            
            let currentCell: UICollectionViewCell? = collectionView?.cellForItemAtIndexPath(indexPath)
            
            cellFakeView = RACellFakeView(cell: currentCell!)
            cellFakeView!.indexPath = indexPath
            cellFakeView!.originalCenter = currentCell?.center
            cellFakeView!.cellFrame = layoutAttributesForItemAtIndexPath(indexPath)!.frame
            collectionView?.addSubview(cellFakeView!)
            
            fakeCellCenter = cellFakeView!.center
            
            invalidateLayout()
            
            cellFakeView!.pushFowardView()
            
            // did begin drag item
            delegate?.collectionView?(collectionView!, collectionViewLayout: self, didBeginDraggingItemAtIndexPath: indexPath)
            
        case .Ended, .Cancelled:
            cancelDrag(toIndexPath: indexPath)
            
        default: ()
        }
    }
    
    // pan gesture
    internal func handlePanGesture(pan: UIPanGestureRecognizer!) {
        panTranslation = pan.translationInView(collectionView!)
        
        if nil != cellFakeView && nil != fakeCellCenter && nil != panTranslation {
            switch pan.state {
            case .Changed:
                cellFakeView!.center.x = fakeCellCenter!.x + panTranslation!.x
                cellFakeView!.center.y = fakeCellCenter!.y + panTranslation!.y
                
                beginScrollIfNeeded()
                moveItemIfNeeded()
                
            case .Ended, .Cancelled:
                invalidateDisplayLink()
                
            default: ()
            }
        }
    }
}


// MARK: - RACellFakeView

private class RACellFakeView: UIView {
    
    weak var cell: UICollectionViewCell?
    
    var cellFakeImageView: UIImageView?
    
    var cellFakeHightedView: UIImageView?
    
    private var indexPath: NSIndexPath?
    
    private var originalCenter: CGPoint?
    
    private var cellFrame: CGRect?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(cell: UICollectionViewCell) {
        super.init(frame: cell.frame)
        
        self.cell = cell
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0
        layer.shadowRadius = 5.0
        layer.shouldRasterize = false
        
        cellFakeImageView = UIImageView(frame: self.bounds)
        cellFakeImageView?.contentMode = .ScaleAspectFill
        cellFakeImageView?.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        
        cellFakeHightedView = UIImageView(frame: self.bounds)
        cellFakeHightedView?.contentMode = .ScaleAspectFill
        cellFakeHightedView?.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        
        cell.highlighted = true
        cellFakeHightedView?.image = getCellImage()
        
        cell.highlighted = false
        cellFakeImageView?.image = getCellImage()
        
        addSubview(cellFakeImageView!)
        addSubview(cellFakeHightedView!)
    }
    
    func changeBoundsIfNeeded(bounds: CGRect) {
        if CGRectEqualToRect(self.bounds, bounds) {
            return
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: { () -> Void in
            self.bounds = bounds
            }, completion: nil)
    }
    
    func pushFowardView() {
        UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: {
            self.center = self.originalCenter!
            self.transform = CGAffineTransformMakeScale(1.1, 1.1)
            self.cellFakeHightedView!.alpha = 0;
            let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowAnimation.fromValue = 0
            shadowAnimation.toValue = 0.7
            shadowAnimation.removedOnCompletion = false
            shadowAnimation.fillMode = kCAFillModeForwards
            self.layer.addAnimation(shadowAnimation, forKey: "applyShadow")
            }, completion: { (finished) -> Void in
                self.cellFakeHightedView!.removeFromSuperview()
        })
    }
    
    func pushBackView(completion: (()->Void)?) {
        UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: {
            self.transform = CGAffineTransformIdentity
            self.frame = self.cellFrame!
            let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowAnimation.fromValue = 0.7
            shadowAnimation.toValue = 0
            shadowAnimation.removedOnCompletion = false
            shadowAnimation.fillMode = kCAFillModeForwards
            self.layer.addAnimation(shadowAnimation, forKey: "removeShadow")
            }, completion: { (finished) -> Void in
                completion?()
        })
    }
    
    private func getCellImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cell!.bounds.size, false, UIScreen.mainScreen().scale * 2)
        cell!.drawViewHierarchyInRect(cell!.bounds, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
