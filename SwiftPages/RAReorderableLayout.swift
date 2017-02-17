//
//  RAReorderableLayout.swift
//  RAReorderableLayout
//
//  Created by Ryo Aoyama on 10/12/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


@objc public protocol RAReorderableLayoutDelegate: UICollectionViewDelegateFlowLayout {
    @objc optional func collectionView(_ collectionView: UICollectionView, atIndexPath: IndexPath, willMoveToIndexPath toIndexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, atIndexPath: IndexPath, didMoveToIndexPath toIndexPath: IndexPath)
    
    @objc optional func collectionView(_ collectionView: UICollectionView, allowMoveAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: UICollectionView, atIndexPath: IndexPath, canMoveToIndexPath: IndexPath) -> Bool
    
    @objc optional func collectionView(_ collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, willBeginDraggingItemAtIndexPath indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, didBeginDraggingItemAtIndexPath indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, willEndDraggingItemToIndexPath indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, didEndDraggingItemToIndexPath indexPath: IndexPath)
}

@objc public protocol RAReorderableLayoutDataSource: UICollectionViewDataSource {
    
    @objc optional func collectionView(_ collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat
    @objc optional func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets
    @objc optional func scrollTrigerPaddingInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets
    @objc optional func scrollSpeedValueInCollectionView(_ collectionView: UICollectionView) -> CGFloat
}

open class RAReorderableLayout: UICollectionViewFlowLayout {
    
    fileprivate enum ScrollDirection {
        case upward
        case downward
        case anchor
        
        fileprivate func scrollValue(speedValue: CGFloat, percentage: CGFloat) -> CGFloat {
            var value: CGFloat = 0.0
            switch self {
            case .upward:
                value = -speedValue
            case .downward:
                value = speedValue
            case .anchor:
                return 0
            }
            
            let proofedPercentage: CGFloat = max(min(1.0, percentage), 0)
            return value * proofedPercentage
        }
    }
    
    open weak var delegate: RAReorderableLayoutDelegate? {
        set {
            collectionView?.delegate = delegate
        }
        get {
            return collectionView?.delegate as? RAReorderableLayoutDelegate
        }
    }
    
    open weak var datasource: RAReorderableLayoutDataSource? {
        set {
            collectionView?.delegate = delegate
        }
        get {
            return collectionView?.dataSource as? RAReorderableLayoutDataSource
        }
    }
    
    fileprivate var displayLink: CADisplayLink?
    
    fileprivate var longPress: UILongPressGestureRecognizer?
    
    fileprivate var panGesture: UIPanGestureRecognizer?
    
    fileprivate var continuousScrollDirection = ScrollDirection.anchor
    
    fileprivate var cellFakeView: RACellFakeView?
    
    fileprivate var panTranslation: CGPoint?
    
    fileprivate var fakeCellCenter: CGPoint?
    
    open var trigerInsets = UIEdgeInsets(top: 100.0, left: 100.0, bottom: 100.0, right: 100.0)
    
    open var trigerPadding = UIEdgeInsets.zero
    
    open var scrollSpeedValue = CGFloat(10.0)
    
    fileprivate var offsetFromTop: CGFloat {
        let contentOffset = collectionView!.contentOffset
        return scrollDirection == .vertical ? contentOffset.y : contentOffset.x
    }
    
    fileprivate var insetsTop: CGFloat {
        let contentInsets = collectionView!.contentInset
        return scrollDirection == .vertical ? contentInsets.top : contentInsets.left
    }
    
    fileprivate var insetsEnd: CGFloat {
        let contentInsets = collectionView!.contentInset
        return scrollDirection == .vertical ? contentInsets.bottom : contentInsets.right
    }
    
    fileprivate var contentLength: CGFloat {
        let contentSize = collectionView!.contentSize
        return scrollDirection == .vertical ? contentSize.height : contentSize.width
    }
    
    fileprivate var collectionViewLength: CGFloat {
        let collectionViewSize = collectionView!.bounds.size
        return scrollDirection == .vertical ? collectionViewSize.height : collectionViewSize.width
    }
    
    fileprivate var fakeCellTopEdge: CGFloat? {
        if let fakeCell = cellFakeView {
            return scrollDirection == .vertical ? fakeCell.frame.minY : fakeCell.frame.minX
        }
        return nil
    }
    
    fileprivate var fakeCellEndEdge: CGFloat? {
        if let fakeCell = cellFakeView {
            return scrollDirection == .vertical ? fakeCell.frame.maxY : fakeCell.frame.maxX
        }
        return nil
    }
    
    fileprivate var trigerInsetTop: CGFloat {
        return scrollDirection == .vertical ? trigerInsets.top : trigerInsets.left
    }
    
    fileprivate var trigerInsetEnd: CGFloat {
        return scrollDirection == .vertical ? trigerInsets.top : trigerInsets.left
    }
    
    fileprivate var trigerPaddingTop: CGFloat {
        if scrollDirection == .vertical {
            return trigerPadding.top
        } else {
            return trigerPadding.left
        }
    }
    
    fileprivate var trigerPaddingEnd: CGFloat {
        if scrollDirection == .vertical {
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
    
    override open func prepare() {
        super.prepare()
        
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
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        for attribute in attributes where attribute.representedElementCategory == .cell && (attribute.indexPath == cellFakeView?.indexPath) {
            attribute.alpha = datasource?.collectionView?(collectionView!, reorderingItemAlphaInSection: attribute.indexPath.section) ?? 0
        }
        
        return attributes
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "collectionView" {
            setUpGestureRecognizers()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func configureObserver() {
        addObserver(self, forKeyPath: "collectionView", options: [], context: nil)
    }
    
    fileprivate func setUpDisplayLink() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(RAReorderableLayout.continuousScroll))
        displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    fileprivate func invalidateDisplayLink() {
        continuousScrollDirection = .anchor
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // begein scroll
    fileprivate func beginScrollIfNeeded() {
        guard nil != cellFakeView else { return }
        
        let offset = offsetFromTop
        
        let trigerInsetTop = self.trigerInsetTop
        let trigerInsetEnd = self.trigerInsetEnd
        let paddingTop = self.trigerPaddingTop
        let paddingEnd = self.trigerPaddingEnd
        let length = self.collectionViewLength
        let fakeCellTopEdge = self.fakeCellTopEdge
        let fakeCellEndEdge = self.fakeCellEndEdge
        
        if  fakeCellTopEdge <= offset + paddingTop + trigerInsetTop {
            self.continuousScrollDirection = .upward
            self.setUpDisplayLink()
        } else if fakeCellEndEdge >= offset + length - paddingEnd - trigerInsetEnd {
            self.continuousScrollDirection = .downward
            self.setUpDisplayLink()
        } else {
            self.invalidateDisplayLink()
        }
    }
    
    // move item
    fileprivate func moveItemIfNeeded() {
        var atIndexPath: IndexPath?
        var toIndexPath: IndexPath?
        if let fakeCell = cellFakeView {
            atIndexPath = fakeCell.indexPath
            toIndexPath = collectionView!.indexPathForItem(at: cellFakeView!.center)
        }
        
        if nil == atIndexPath || nil == toIndexPath || (atIndexPath! == toIndexPath) {
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
        
        let attribute = layoutAttributesForItem(at: toIndexPath!)!
        collectionView!.performBatchUpdates({ () -> Void in
            self.cellFakeView!.indexPath = toIndexPath
            self.cellFakeView!.cellFrame = attribute.frame
            self.cellFakeView!.changeBoundsIfNeeded(attribute.bounds)
            
            self.collectionView!.deleteItems(at: [atIndexPath!])
            self.collectionView!.insertItems(at: [toIndexPath!])
            
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
            case .vertical:
                self.fakeCellCenter?.y += scrollRate
                self.cellFakeView?.center.y = self.fakeCellCenter!.y + self.panTranslation!.y
                self.collectionView?.contentOffset.y += scrollRate
            case .horizontal:
                self.fakeCellCenter?.x += scrollRate
                self.cellFakeView?.center.x = self.fakeCellCenter!.x + self.panTranslation!.x
                self.collectionView?.contentOffset.x += scrollRate
            }
            }, completion: nil)
        
        moveItemIfNeeded()
    }
    
    fileprivate func calcTrigerPercentage() -> CGFloat {
        guard nil != cellFakeView else { return 0 }
        
        let offset = self.offsetFromTop
        let offsetEnd = self.offsetFromTop + self.collectionViewLength
        let insetTop = self.insetsTop
        
        let trigerInsetTop = self.trigerInsetTop
        let trigerInsetEnd = self.trigerInsetEnd
        
        let paddingEnd = self.trigerPaddingEnd
        
        var percentage: CGFloat = 0
        
        switch continuousScrollDirection {
        case .upward:
            if let fakeCellEdge = fakeCellTopEdge {
                percentage = 1.0 - ((fakeCellEdge - (offset + trigerPaddingTop)) / trigerInsetTop)
            }
        case .downward:
            if let fakeCellEdge = fakeCellEndEdge {
                percentage = 1.0 - (((insetTop + offsetEnd - paddingEnd) - (fakeCellEdge + insetTop)) / trigerInsetEnd)
            }
        case .anchor: ()
        }
        
        // 0 <= percentage <= 1.0
        percentage = max(0, min(1.0, percentage))
        
        return percentage
    }
    
    // gesture recognizers
    fileprivate func setUpGestureRecognizers() {
        guard nil != collectionView else { return }
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(RAReorderableLayout.handleLongPress(_:)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(RAReorderableLayout.handlePanGesture(_:)))
        longPress?.delegate = self
        panGesture?.delegate = self
        panGesture?.maximumNumberOfTouches = 1
        
        if let gestures = collectionView?.gestureRecognizers {
            for case let gesture as UILongPressGestureRecognizer in gestures {
                gesture.require(toFail: self.longPress!)
            }
        }
        
        collectionView?.addGestureRecognizer(longPress!)
        collectionView?.addGestureRecognizer(panGesture!)
    }
    
    open func cancelDrag() {
        cancelDrag(toIndexPath: nil)
    }
    
    fileprivate func cancelDrag(toIndexPath: IndexPath!) {
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
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // allow move item
        if let indexPath = collectionView?.indexPathForItem(at: gestureRecognizer.location(in: collectionView)) {
            if delegate?.collectionView?(collectionView!, allowMoveAtIndexPath: indexPath) == false {
                return false
            }
        }
        
        if gestureRecognizer.isEqual(longPress) {
            if collectionView!.panGestureRecognizer.state != .possible && collectionView!.panGestureRecognizer.state != .failed {
                return false
            }
        } else if gestureRecognizer.isEqual(panGesture) {
            if longPress!.state == .possible || longPress!.state == .failed {
                return false
            }
        }
        
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(longPress) {
            if otherGestureRecognizer.isEqual(panGesture) {
                return true
            }
        } else if gestureRecognizer.isEqual(panGesture) {
            return otherGestureRecognizer.isEqual(longPress)
        } else if gestureRecognizer.isEqual(collectionView?.panGestureRecognizer) {
            if longPress!.state != .possible || longPress!.state != .failed {
                return false
            }
        }
        
        return true
    }
}


// MARK: - RAReorderableLayout: Target-Action

internal extension RAReorderableLayout {
    
    // long press gesture
    internal func handleLongPress(_ longPress: UILongPressGestureRecognizer!) {
        var indexPathOptional = collectionView?.indexPathForItem(at: longPress.location(in: collectionView)) ?? nil
        if nil != cellFakeView {
            indexPathOptional = cellFakeView!.indexPath
        }
        
        guard let indexPath = indexPathOptional else { return }
        
        switch longPress.state {
        case .began:
            // will begin drag item
            delegate?.collectionView?(collectionView!, collectionViewLayout: self, willBeginDraggingItemAtIndexPath: indexPath)
            
            collectionView?.scrollsToTop = false
            
            let currentCell: UICollectionViewCell? = collectionView?.cellForItem(at: indexPath)
            
            cellFakeView = RACellFakeView(cell: currentCell!)
            cellFakeView!.indexPath = indexPath
            cellFakeView!.originalCenter = currentCell?.center
            cellFakeView!.cellFrame = layoutAttributesForItem(at: indexPath)!.frame
            collectionView?.addSubview(cellFakeView!)
            
            fakeCellCenter = cellFakeView!.center
            
            invalidateLayout()
            
            cellFakeView!.pushFowardView()
            
            // did begin drag item
            delegate?.collectionView?(collectionView!, collectionViewLayout: self, didBeginDraggingItemAtIndexPath: indexPath)
            
        case .ended, .cancelled:
            cancelDrag(toIndexPath: indexPath)
            
        default: ()
        }
    }
    
    // pan gesture
    internal func handlePanGesture(_ pan: UIPanGestureRecognizer!) {
        panTranslation = pan.translation(in: collectionView!)
        
        if nil != cellFakeView && nil != fakeCellCenter && nil != panTranslation {
            switch pan.state {
            case .changed:
                cellFakeView!.center.x = fakeCellCenter!.x + panTranslation!.x
                cellFakeView!.center.y = fakeCellCenter!.y + panTranslation!.y
                
                beginScrollIfNeeded()
                moveItemIfNeeded()
                
            case .ended, .cancelled:
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
    
    fileprivate var indexPath: IndexPath?
    
    fileprivate var originalCenter: CGPoint?
    
    fileprivate var cellFrame: CGRect?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(cell: UICollectionViewCell) {
        super.init(frame: cell.frame)
        
        self.cell = cell
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0
        layer.shadowRadius = 5.0
        layer.shouldRasterize = false
        
        cellFakeImageView = UIImageView(frame: self.bounds)
        cellFakeImageView?.contentMode = .scaleAspectFill
        cellFakeImageView?.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        
        cellFakeHightedView = UIImageView(frame: self.bounds)
        cellFakeHightedView?.contentMode = .scaleAspectFill
        cellFakeHightedView?.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        
        cell.isHighlighted = true
        cellFakeHightedView?.image = getCellImage()
        
        cell.isHighlighted = false
        cellFakeImageView?.image = getCellImage()
        
        addSubview(cellFakeImageView!)
        addSubview(cellFakeHightedView!)
    }
    
    func changeBoundsIfNeeded(_ bounds: CGRect) {
        if self.bounds.equalTo(bounds) {
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
            self.bounds = bounds
            }, completion: nil)
    }
    
    func pushFowardView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
            self.center = self.originalCenter!
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.cellFakeHightedView!.alpha = 0;
            let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowAnimation.fromValue = 0
            shadowAnimation.toValue = 0.7
            shadowAnimation.isRemovedOnCompletion = false
            shadowAnimation.fillMode = kCAFillModeForwards
            self.layer.add(shadowAnimation, forKey: "applyShadow")
            }, completion: { (finished) -> Void in
                self.cellFakeHightedView!.removeFromSuperview()
        })
    }
    
    func pushBackView(_ completion: (()->Void)?) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
            self.transform = CGAffineTransform.identity
            self.frame = self.cellFrame!
            let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowAnimation.fromValue = 0.7
            shadowAnimation.toValue = 0
            shadowAnimation.isRemovedOnCompletion = false
            shadowAnimation.fillMode = kCAFillModeForwards
            self.layer.add(shadowAnimation, forKey: "removeShadow")
            }, completion: { (finished) -> Void in
                completion?()
        })
    }
    
    fileprivate func getCellImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cell!.bounds.size, false, UIScreen.main.scale * 2)
        cell!.drawHierarchy(in: cell!.bounds, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
