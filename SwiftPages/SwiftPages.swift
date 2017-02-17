//
//  self.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 6/27/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit

// protocol delegate
protocol SwiftPagesDelegate {
    func SwiftPagesCurrentPageNumber(_ currentIndex: Int)
}


// MARK: - SwiftPages

open class SwiftPages: UIView {
    private lazy var __once: () = {
        let pagesContainerHeight = self.frame.height - self.yOrigin - self.distanceToBottom
        let pagesContainerWidth = self.frame.width
        
        let pageCount = self.pageCount
        
        // Set the notifications for an orientation change & BG mode
        let defaultNotificationCenter = NotificationCenter.default
        defaultNotificationCenter.addObserver(self, selector: #selector(self.applicationWillEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        defaultNotificationCenter.addObserver(self, selector: #selector(self.orientationWillChange), name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
        defaultNotificationCenter.addObserver(self, selector: #selector(self.orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Set the containerView, every item is constructed relative to this view
        self.containerView = UIView(frame: CGRect(x: self.xOrigin, y: self.yOrigin, width: pagesContainerWidth, height: pagesContainerHeight))
        self.containerView.backgroundColor = self.containerViewBackground
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.containerView)
        
        //Add the constraints to the containerView.
        if #available(iOS 9.0, *) {
            let horizontalConstraint = self.containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            let verticalConstraint = self.containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            let widthConstraint = self.containerView.widthAnchor.constraint(equalTo: self.widthAnchor)
            let heightConstraint = self.containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
            NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        }
        
        
        // Set the scrollview
        if self.aeroEffectInTopBar {
            self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height))
        } else {
            self.scrollView = UIScrollView(frame: CGRect(x: 0, y: self.topBarHeight, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height - self.topBarHeight))
        }
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.scrollView)
        
        // Add the constraints to the scrollview.
        if #available(iOS 9.0, *) {
            let leadingConstraint = self.scrollView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor)
            let trailingConstraint = self.scrollView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
            let topConstraint = self.scrollView.topAnchor.constraint(equalTo: self.containerView.topAnchor)
            let bottomConstraint = self.scrollView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
            NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        }
        
        // Set the top bar
        self.topBar = UIView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.topBarHeight))
        self.topBar.backgroundColor = self.topBarBackground
        
        if self.aeroEffectInTopBar {
            // Create the blurred visual effect
            // You can choose between ExtraLight, Light and Dark
            self.topBar.backgroundColor = UIColor.clear
            
            let blurEffect: UIBlurEffect = UIBlurEffect(style: .light)
            self.blurView = UIVisualEffectView(effect: blurEffect)
            
            self.blurView.frame = self.topBar.bounds
            self.blurView.translatesAutoresizingMaskIntoConstraints = false
            self.topBar.addSubview(self.blurView)
        }
        self.topBar.translatesAutoresizingMaskIntoConstraints = false
        if self.topbarIsEnabled {
            self.containerView.addSubview(self.topBar)
        }
        
        // Set the top bar buttons
        // Check to see if the top bar will be created with images ot text
        if self.buttonsWithImages {
            var buttonsXPosition: CGFloat = 0
            
            for (index, image) in self.buttonImages.enumerated() {
                let frame = CGRect(x: buttonsXPosition, y: 0, width: self.containerView.frame.size.width / CGFloat(pageCount), height: self.topBarHeight)
                
                let barButton = UIButton(frame: frame)
                barButton.backgroundColor = UIColor.clear
                barButton.imageView?.contentMode = .scaleAspectFit
                barButton.setImage(image, for: UIControlState())
                barButton.tag = index
                barButton.addTarget(self, action: #selector(self.barButtonAction(_:)), for: .touchUpInside)
                self.topBar.addSubview(barButton)
                self.barButtons.append(barButton)
                
                buttonsXPosition += self.containerView.frame.size.width / CGFloat(pageCount)
            }
        } else {
            var buttonsXPosition: CGFloat = 0
            
            for (index, title) in self.buttonTitles.enumerated() {
                let frame = CGRect(x: buttonsXPosition, y: 0, width: self.containerView.frame.size.width / CGFloat(pageCount), height: self.topBarHeight)
                
                let barButton = UIButton(frame: frame)
                barButton.backgroundColor = UIColor.clear
                barButton.titleLabel!.font = self.buttonsTextFontAndSize
                barButton.setTitle(title, for: UIControlState())
                barButton.setTitleColor(self.buttonsTextColor, for: UIControlState())
                barButton.tag = index
                barButton.addTarget(self, action: #selector(self.barButtonAction(_:)), for: .touchUpInside)
                self.topBar.addSubview(barButton)
                self.barButtons.append(barButton)
                
                buttonsXPosition += self.containerView.frame.size.width / CGFloat(pageCount)
            }
        }
        
        // Set up the animated UIView
        self.animatedBar = UIView(frame: CGRect(x: 0, y: self.topBarHeight - self.animatedBarHeight + 1, width: (self.containerView.frame.size.width / CGFloat(pageCount)) * 0.8, height: self.animatedBarHeight))
        self.animatedBar.center.x = self.containerView.frame.size.width / CGFloat(pageCount << 1)
        self.animatedBar.backgroundColor = self.animatedBarColor
        if self.topbarIsEnabled {
            self.containerView.addSubview(self.animatedBar)
        }
        
        // Add the bar shadow (set to true or false with the barShadow var)
        if self.barShadow {
            self.shadowView = UIView(frame: CGRect(x: 0, y: self.topBarHeight, width: self.containerView.frame.size.width, height: 4))
            self.shadowViewGradient.frame = self.shadowView.bounds
            self.shadowViewGradient.colors = [UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.28).cgColor, UIColor.clear.cgColor]
            self.shadowView.layer.insertSublayer(self.shadowViewGradient, at: 0)
            if self.topbarIsEnabled {
                self.containerView.addSubview(self.shadowView)
            }
        }
        
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
    }()
    // current page index and delegate
    var currentIndex: Int = 0
    var delegate : SwiftPagesDelegate?
    
    fileprivate var token: Int = 0
    
    // Items variables
    fileprivate var containerView: UIView!
    fileprivate var scrollView: UIScrollView!
    fileprivate var topBar: UIView!
    fileprivate var animatedBar: UIView!
    fileprivate var viewControllerIDs = [String]()
    fileprivate var viewControllersArray = [UIViewController]()
    fileprivate var buttonTitles = [String]()
    fileprivate var buttonImages = [UIImage]()
    fileprivate var pageViews = [UIViewController?]()
    fileprivate var currentPage: Int = 0
    fileprivate var storyBoardName: String!
    fileprivate var storyBoard: UIStoryboard?
    fileprivate var pageCount: Int {
        return viewControllerIDs.count != 0 ? viewControllerIDs.count : viewControllersArray.count
    }
    
    // Container view position variables
    fileprivate var xOrigin: CGFloat = 0
    fileprivate var yOrigin: CGFloat = 64
    fileprivate var distanceToBottom: CGFloat = 0
    
    // Color variables
    fileprivate var animatedBarColor = UIColor(red: 28/255, green: 95/255, blue: 185/255, alpha: 1)
    fileprivate var topBarBackground = UIColor.white
    fileprivate var buttonsTextColor = UIColor.gray
    fileprivate var containerViewBackground = UIColor.white
    
    // Item size variables
    fileprivate var topBarHeight: CGFloat = 52
    fileprivate var animatedBarHeight: CGFloat = 3
    
    // Bar item variables
    fileprivate var topbarIsEnabled = true
    fileprivate var aeroEffectInTopBar = false //This gives the top bap a blurred effect, also overlayes the it over the VC's
    fileprivate var buttonsWithImages = false
    fileprivate var barShadow = true
    fileprivate var shadowView : UIView!
    fileprivate var shadowViewGradient = CAGradientLayer()
    fileprivate var buttonsTextFontAndSize = UIFont(name: "HelveticaNeue-Light", size: 20)!
    fileprivate var blurView : UIVisualEffectView!
    fileprivate var barButtons = [UIButton?]()
    
    // MARK: - Positions Of The Container View API -
    open func setOriginX (_ origin : CGFloat) { xOrigin = origin }
    open func setOriginY (_ origin : CGFloat) { yOrigin = origin }
    open func setDistanceToBottom (_ distance : CGFloat) { distanceToBottom = distance }
    
    // MARK: - API's -
    open func setAnimatedBarColor (_ color : UIColor) { animatedBarColor = color }
    open func setTopBarBackground (_ color : UIColor) { topBarBackground = color }
    open func setButtonsTextColor (_ color : UIColor) { buttonsTextColor = color }
    open func setContainerViewBackground (_ color : UIColor) { containerViewBackground = color }
    open func setTopBarHeight (_ pointSize : CGFloat) { topBarHeight = pointSize}
    open func setAnimatedBarHeight (_ pointSize : CGFloat) { animatedBarHeight = pointSize}
    open func setButtonsTextFontAndSize (_ fontAndSize : UIFont) { buttonsTextFontAndSize = fontAndSize}
    open func enableAeroEffectInTopBar (_ boolValue : Bool) { aeroEffectInTopBar = boolValue}
    open func enableButtonsWithImages (_ boolValue : Bool) { buttonsWithImages = boolValue}
    open func enableBarShadow (_ boolValue : Bool) { barShadow = boolValue}
    
    open func disableTopBar () { topbarIsEnabled = false }
    
    override open func draw(_ rect: CGRect) {
        
        _ = self.__once
    }
    
    // MARK: - Initialization Functions -
    
    open func initializeWithVCIDsArrayAndButtonTitlesArray (_ VCIDsArray: [String], buttonTitlesArray: [String], storyBoard: UIStoryboard) {
        self.storyBoard = storyBoard;
        initializeWithVCIDsArrayAndButtonTitlesArray (VCIDsArray, buttonTitlesArray: buttonTitlesArray)
    }
    
    open func initializeWithVCIDsArrayAndButtonImagesArray (_ VCIDsArray: [String], buttonImagesArray: [UIImage], storyBoard: UIStoryboard) {
        self.storyBoard = storyBoard
        initializeWithVCIDsArrayAndButtonImagesArray(VCIDsArray, buttonImagesArray: buttonImagesArray)
    }
    
    open func initializeWithVCsInstanciatedArrayAndButtonTitlesArray(_ VCsArray: [UIViewController], buttonTitlesArray: [String]) {
        // Important - Titles Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCsArray.count == buttonTitlesArray.count {
            viewControllersArray = VCsArray
            buttonTitles = buttonTitlesArray
            buttonsWithImages = false
        } else {
            print("Initilization failed, the VC array count does not match the button titles array count.")
        }
    }
    
    open func initializeWithVCsInstanciatedArrayAndButtonImagesArray(_ VCsArray: [UIViewController], buttonImagesArray: [UIImage]) {
        // Important - Titles Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCsArray.count == buttonImagesArray.count {
            viewControllersArray = VCsArray
            buttonImages = buttonImagesArray
            buttonsWithImages = true
        } else {
            print("Initilization failed, the VC array count does not match the button titles array count.")
        }
    }
    
    open func initializeWithVCIDsArrayAndButtonTitlesArray (_ VCIDsArray: [String], buttonTitlesArray: [String], storyBoardName: String = "Main") {
        // Important - Titles Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCIDsArray.count == buttonTitlesArray.count {
            viewControllerIDs = VCIDsArray
            buttonTitles = buttonTitlesArray
            buttonsWithImages = false
            self.storyBoardName = storyBoardName
        } else {
            print("Initilization failed, the VC ID array count does not match the button titles array count.")
        }
    }
    
    open func initializeWithVCIDsArrayAndButtonImagesArray (_ VCIDsArray: [String], buttonImagesArray: [UIImage], storyBoardName: String = "Main") {
        // Important - Images Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCIDsArray.count == buttonImagesArray.count {
            viewControllerIDs = VCIDsArray
            buttonImages = buttonImagesArray
            buttonsWithImages = true
            self.storyBoardName = storyBoardName
        } else {
            print("Initilization failed, the VC ID array count does not match the button images array count.")
        }
    }
    
    open func loadPage(_ page: Int) {
        // If it's outside the range of what you have to display, then do nothing
        guard page >= 0 && page < pageCount else { return }
        
        // Do nothing if the view is already loaded.
        guard pageViews[page] == nil else { return }
        
        print("Loading Page \(page)")
        
        // The pageView instance is nil, create the page
        var frame = scrollView.bounds
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0.0
        
        let newPageView = viewControllerForPage(page)
        newPageView.view.frame = frame
        scrollView.addSubview(newPageView.view)
        
        // Replace the nil in the pageViews array with the VC just created
        pageViews[page] = newPageView
    }
    
    open func viewControllerForPage(_ page: Int) -> UIViewController {
        //Look for the VC in the VC id list or in the VC object list
        if viewControllerIDs.count != 0 {
            return instanciateViewControllerWithIdentifier(viewControllerIDs[page])
        }
        return viewControllersArray[page]
    }
    
    open func instanciateViewControllerWithIdentifier(_ identifier: String) -> UIViewController {
        //If we have a storyboard created
        if let storyBoard = storyBoard {
            return storyBoard.instantiateViewController(withIdentifier: identifier)
        }
        return UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    open func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // make sure the delegate method called once
        if currentIndex != page {
            currentIndex = page;
            self.delegate?.SwiftPagesCurrentPageNumber(currentIndex)
        }
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
    }
    
    open func barButtonAction(_ sender: UIButton?) {
        let index = sender!.tag
        let pagesScrollViewSize = scrollView.frame.size
        
        scrollView.setContentOffset(CGPoint(x: pagesScrollViewSize.width * CGFloat(index), y: 0), animated: true)
        
        currentPage = index
    }
    
    // MARK: - Orientation Handling Functions -
    
    open func alignSubviews() {
        
        // Setup the new frames
        scrollView.contentSize = CGSize(width: CGFloat(pageCount) * scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        topBar.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: topBarHeight)
        blurView?.frame = topBar.bounds
        animatedBar.frame.size = CGSize(width: (containerView.frame.size.width / (CGFloat)(pageCount)) * 0.8, height: animatedBarHeight)
        if barShadow {
            shadowView.frame.size = CGSize(width: containerView.frame.size.width, height: 4)
            shadowViewGradient.frame = shadowView.bounds
        }
        
        // Set the new frame of the scrollview contents
        for (index, controller) in pageViews.enumerated() {
            controller?.view.frame = CGRect(x: CGFloat(index) * scrollView.bounds.size.width, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        }
        
        // Set the new frame for the top bar buttons
        var buttonsXPosition: CGFloat = 0
        for button in barButtons {
            button?.frame = CGRect(x: buttonsXPosition, y: 0, width: containerView.frame.size.width / CGFloat(pageCount), height: topBarHeight)
            buttonsXPosition += containerView.frame.size.width / CGFloat(pageCount)
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
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - SwiftPages: UIScrollViewDelegate

extension SwiftPages: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
        
        // The calculations for the animated bar's movements
        // The offset addition is based on the width of the animated bar (button width times 0.8)
        let offsetAddition = (containerView.frame.size.width / CGFloat(pageCount)) * 0.1
        animatedBar.frame = CGRect(x: (offsetAddition + (scrollView.contentOffset.x / CGFloat(pageCount))), y: animatedBar.frame.origin.y, width: animatedBar.frame.size.width, height: animatedBar.frame.size.height)
    }
}
