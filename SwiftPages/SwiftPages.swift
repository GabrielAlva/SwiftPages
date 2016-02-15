//
//  SwiftPages.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 6/27/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit


// MARK: - SwiftPages

public class SwiftPages: UIView {
    
    private var token: dispatch_once_t = 0
    
    // Items variables
    private var containerView: UIView!
    private var scrollView: UIScrollView!
    private var topBar: UIView!
    private var animatedBar: UIView!
    private var viewControllerIDs = [String]()
    private var buttonTitles = [String]()
    private var buttonImages = [UIImage]()
    private var pageViews = [UIViewController?]()
    private var currentPage: Int = 0
    
    // Container view position variables
    private var xOrigin: CGFloat = 0
    private var yOrigin: CGFloat = 64
    private var distanceToBottom: CGFloat = 0
    
    // Color variables
    private var animatedBarColor = UIColor(red: 28/255, green: 95/255, blue: 185/255, alpha: 1)
    private var topBarBackground = UIColor.whiteColor()
    private var buttonsTextColor = UIColor.grayColor()
    private var containerViewBackground = UIColor.whiteColor()
    
    // Item size variables
    private var topBarHeight: CGFloat = 52
    private var animatedBarHeight: CGFloat = 3
    
    // Bar item variables
    private var aeroEffectInTopBar = false //This gives the top bap a blurred effect, also overlayes the it over the VC's
    private var buttonsWithImages = false
    private var barShadow = true
    private var shadowView : UIView!
    private var shadowViewGradient = CAGradientLayer()
    private var buttonsTextFontAndSize = UIFont(name: "HelveticaNeue-Light", size: 20)!
    private var blurView : UIVisualEffectView!
    private var barButtons = [UIButton?]()
    
    // MARK: - Positions Of The Container View API -
    public func setOriginX (origin : CGFloat) { xOrigin = origin }
    public func setOriginY (origin : CGFloat) { yOrigin = origin }
    public func setDistanceToBottom (distance : CGFloat) { distanceToBottom = distance }
    
    // MARK: - API's -
    public func setAnimatedBarColor (color : UIColor) { animatedBarColor = color }
    public func setTopBarBackground (color : UIColor) { topBarBackground = color }
    public func setButtonsTextColor (color : UIColor) { buttonsTextColor = color }
    public func setContainerViewBackground (color : UIColor) { containerViewBackground = color }
    public func setTopBarHeight (pointSize : CGFloat) { topBarHeight = pointSize}
    public func setAnimatedBarHeight (pointSize : CGFloat) { animatedBarHeight = pointSize}
    public func setButtonsTextFontAndSize (fontAndSize : UIFont) { buttonsTextFontAndSize = fontAndSize}
    public func enableAeroEffectInTopBar (boolValue : Bool) { aeroEffectInTopBar = boolValue}
    public func enableButtonsWithImages (boolValue : Bool) { buttonsWithImages = boolValue}
    public func enableBarShadow (boolValue : Bool) { barShadow = boolValue}
    
    override public func drawRect(rect: CGRect) {
        
        dispatch_once(&token) {
            let pagesContainerHeight = self.frame.height - self.yOrigin - self.distanceToBottom
            let pagesContainerWidth = self.frame.width
            
            // Set the notifications for an orientation change & BG mode
            let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
            defaultNotificationCenter.addObserver(self, selector: Selector("applicationWillEnterBackground"), name: UIApplicationWillResignActiveNotification, object: nil)
            defaultNotificationCenter.addObserver(self, selector: Selector("orientationWillChange"), name: UIApplicationWillChangeStatusBarOrientationNotification, object: nil)
            defaultNotificationCenter.addObserver(self, selector: Selector("orientationDidChange"), name: UIDeviceOrientationDidChangeNotification, object: nil)
            
            // Set the containerView, every item is constructed relative to this view
            self.containerView = UIView(frame: CGRect(x: self.xOrigin, y: self.yOrigin, width: pagesContainerWidth, height: pagesContainerHeight))
            self.containerView.backgroundColor = self.containerViewBackground
            self.containerView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.containerView)
            
            //Add the constraints to the containerView.
            if #available(iOS 9.0, *) {
                let horizontalConstraint = self.containerView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor)
                let verticalConstraint = self.containerView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor)
                let widthConstraint = self.containerView.widthAnchor.constraintEqualToAnchor(self.widthAnchor)
                let heightConstraint = self.containerView.heightAnchor.constraintEqualToAnchor(self.heightAnchor)
                NSLayoutConstraint.activateConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            }
            
            
            // Set the scrollview
            if self.aeroEffectInTopBar {
                self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height))
            } else {
                self.scrollView = UIScrollView(frame: CGRect(x: 0, y: self.topBarHeight, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height - self.topBarHeight))
            }
            self.scrollView.pagingEnabled = true
            self.scrollView.showsHorizontalScrollIndicator = false
            self.scrollView.showsVerticalScrollIndicator = false
            self.scrollView.delegate = self
            self.scrollView.backgroundColor = UIColor.clearColor()
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            self.scrollView.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(self.scrollView)
            
            // Add the constraints to the scrollview.
            if #available(iOS 9.0, *) {
                let leadingConstraint = self.scrollView.leadingAnchor.constraintEqualToAnchor(self.containerView.leadingAnchor)
                let trailingConstraint = self.scrollView.trailingAnchor.constraintEqualToAnchor(self.containerView.trailingAnchor)
                let topConstraint = self.scrollView.topAnchor.constraintEqualToAnchor(self.containerView.topAnchor)
                let bottomConstraint = self.scrollView.bottomAnchor.constraintEqualToAnchor(self.containerView.bottomAnchor)
                NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
            }
            
            // Set the top bar
            self.topBar = UIView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.topBarHeight))
            self.topBar.backgroundColor = self.topBarBackground
            
            if self.aeroEffectInTopBar {
                // Create the blurred visual effect
                // You can choose between ExtraLight, Light and Dark
                self.topBar.backgroundColor = UIColor.clearColor()
                
                let blurEffect: UIBlurEffect = UIBlurEffect(style: .Light)
                self.blurView = UIVisualEffectView(effect: blurEffect)
                
                self.blurView.frame = self.topBar.bounds
                self.blurView.translatesAutoresizingMaskIntoConstraints = false
                self.topBar.addSubview(self.blurView)
            }
            self.topBar.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(self.topBar)
            
            // Set the top bar buttons
            // Check to see if the top bar will be created with images ot text
            if self.buttonsWithImages {
                var buttonsXPosition: CGFloat = 0
                
                for (index, image) in self.buttonImages.enumerate() {
                    let frame = CGRect(x: buttonsXPosition, y: 0, width: self.containerView.frame.size.width / CGFloat(self.viewControllerIDs.count), height: self.topBarHeight)
                    
                    let barButton = UIButton(frame: frame)
                    barButton.backgroundColor = UIColor.clearColor()
                    barButton.imageView?.contentMode = .ScaleAspectFit
                    barButton.setImage(image, forState: .Normal)
                    barButton.tag = index
                    barButton.addTarget(self, action: "barButtonAction:", forControlEvents: .TouchUpInside)
                    self.topBar.addSubview(barButton)
                    self.barButtons.append(barButton)
                    
                    buttonsXPosition += self.containerView.frame.size.width / CGFloat(self.viewControllerIDs.count)
                }
            } else {
                var buttonsXPosition: CGFloat = 0
                
                for (index, title) in self.buttonTitles.enumerate() {
                    let frame = CGRect(x: buttonsXPosition, y: 0, width: self.containerView.frame.size.width / CGFloat(self.viewControllerIDs.count), height: self.topBarHeight)
                    
                    let barButton = UIButton(frame: frame)
                    barButton.backgroundColor = UIColor.clearColor()
                    barButton.titleLabel!.font = self.buttonsTextFontAndSize
                    barButton.setTitle(title, forState: .Normal)
                    barButton.setTitleColor(self.buttonsTextColor, forState: .Normal)
                    barButton.tag = index
                    barButton.addTarget(self, action: "barButtonAction:", forControlEvents: .TouchUpInside)
                    self.topBar.addSubview(barButton)
                    self.barButtons.append(barButton)
                    
                    buttonsXPosition += self.containerView.frame.size.width / CGFloat(self.viewControllerIDs.count)
                }
            }
            
            // Set up the animated UIView
            self.animatedBar = UIView(frame: CGRect(x: 0, y: self.topBarHeight - self.animatedBarHeight + 1, width: (self.containerView.frame.size.width / CGFloat(self.viewControllerIDs.count)) * 0.8, height: self.animatedBarHeight))
            self.animatedBar.center.x = self.containerView.frame.size.width / CGFloat(self.viewControllerIDs.count << 1)
            self.animatedBar.backgroundColor = self.animatedBarColor
            self.containerView.addSubview(self.animatedBar)
            
            // Add the bar shadow (set to true or false with the barShadow var)
            if self.barShadow {
                self.shadowView = UIView(frame: CGRect(x: 0, y: self.topBarHeight, width: self.containerView.frame.size.width, height: 4))
                self.shadowViewGradient.frame = self.shadowView.bounds
                self.shadowViewGradient.colors = [UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.28).CGColor, UIColor.clearColor().CGColor]
                self.shadowView.layer.insertSublayer(self.shadowViewGradient, atIndex: 0)
                self.containerView.addSubview(self.shadowView)
            }
            
            let pageCount = self.viewControllerIDs.count
            
            // Fill the array containing the VC instances with nil objects as placeholders
            for _ in 0..<pageCount {
                self.pageViews.append(nil)
            }
            
            // Defining the content size of the scrollview
            let pagesScrollViewSize = self.scrollView.frame.size
            self.scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageCount), height: pagesScrollViewSize.height)
            
            // Load the pages to show initially
            self.loadVisiblePages()
            
            // Do the initial alignment of the subViews
            self.alignSubviews()
        }
    }
    
    // MARK: - Initialization Functions -
    public func initializeWithVCIDsArrayAndButtonTitlesArray (VCIDsArray: [String], buttonTitlesArray: [String]) {
        // Important - Titles Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCIDsArray.count == buttonTitlesArray.count {
            viewControllerIDs = VCIDsArray
            buttonTitles = buttonTitlesArray
            buttonsWithImages = false
        } else {
            print("Initilization failed, the VC ID array count does not match the button titles array count.")
        }
    }
    
    public func initializeWithVCIDsArrayAndButtonImagesArray (VCIDsArray: [String], buttonImagesArray: [UIImage]) {
        // Important - Images Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCIDsArray.count == buttonImagesArray.count {
            viewControllerIDs = VCIDsArray
            buttonImages = buttonImagesArray
            buttonsWithImages = true
        } else {
            print("Initilization failed, the VC ID array count does not match the button images array count.")
        }
    }
    
    public func loadPage(page: Int) {
        // If it's outside the range of what you have to display, then do nothing
        guard page >= 0 && page < viewControllerIDs.count else { return }
        
        // Do nothing if the view is already loaded.
        guard pageViews[page] == nil else { return }
        
        print("Loading Page \(page)")
        
        // The pageView instance is nil, create the page
        var frame = scrollView.bounds
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0.0
        
        // Look for the VC by its identifier in the storyboard and add it to the scrollview
        let newPageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(viewControllerIDs[page])
        newPageView.view.frame = frame
        scrollView.addSubview(newPageView.view)
        
        // Replace the nil in the pageViews array with the VC just created
        pageViews[page] = newPageView
    }
    
    public func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
    }
    
    public func barButtonAction(sender: UIButton?) {
        let index = sender!.tag
        let pagesScrollViewSize = scrollView.frame.size
        
        scrollView.setContentOffset(CGPoint(x: pagesScrollViewSize.width * CGFloat(index), y: 0), animated: true)
        
        currentPage = index
    }
    
    // MARK: - Orientation Handling Functions -
    
    public func alignSubviews() {
        let pageCount = viewControllerIDs.count
        
        // Setup the new frames
        scrollView.contentSize = CGSize(width: CGFloat(pageCount) * scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        topBar.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: topBarHeight)
        blurView?.frame = topBar.bounds
        animatedBar.frame.size = CGSize(width: (containerView.frame.size.width / (CGFloat)(viewControllerIDs.count)) * 0.8, height: animatedBarHeight)
        if barShadow {
            shadowView.frame.size = CGSize(width: containerView.frame.size.width, height: 4)
            shadowViewGradient.frame = shadowView.bounds
        }
        
        // Set the new frame of the scrollview contents
        for (index, controller) in pageViews.enumerate() {
            controller?.view.frame = CGRect(x: CGFloat(index) * scrollView.bounds.size.width, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        }
        
        // Set the new frame for the top bar buttons
        var buttonsXPosition: CGFloat = 0
        for button in barButtons {
            button?.frame = CGRect(x: buttonsXPosition, y: 0, width: containerView.frame.size.width / CGFloat(viewControllerIDs.count), height: topBarHeight)
            buttonsXPosition += containerView.frame.size.width / CGFloat(viewControllerIDs.count)
        }
    }
    
    func applicationWillEnterBackground() {
        //Save the current page
        currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
    }
    
    func orientationWillChange() {
        //Save the current page
        currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
    }
    
    func orientationDidChange() {
        //Update the view
        alignSubviews()
        scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * scrollView.frame.size.width, y: 0)
    }
    
    // MARK: - ScrollView delegate -
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let previousPage : NSInteger = currentPage
        let pageWidth : CGFloat = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page : NSInteger = Int(round(fractionalPage))
        if (previousPage != page) {
            currentPage = page;
        }
    }
    
    // MARK: - deinit -
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


// MARK: - SwiftPages: UIScrollViewDelegate

extension SwiftPages: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
        
        // The calculations for the animated bar's movements
        // The offset addition is based on the width of the animated bar (button width times 0.8)
        let offsetAddition = (containerView.frame.size.width / CGFloat(viewControllerIDs.count)) * 0.1
        animatedBar.frame = CGRect(x: (offsetAddition + (scrollView.contentOffset.x / CGFloat(viewControllerIDs.count))), y: animatedBar.frame.origin.y, width: animatedBar.frame.size.width, height: animatedBar.frame.size.height)
    }
}
