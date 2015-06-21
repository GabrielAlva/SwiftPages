//
//  SwiftPages.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 5/23/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit

class SwiftPages: UIViewController, UIScrollViewDelegate {
    
    //Item variables
    private var containerView : UIView!
    private var scrollView : UIScrollView!
    private var topBar : UIView!
    private var animatedBar : UIView!
    var viewControllerIDs : [String] = []
    var buttonTitles : [String] = []
    var buttonImages : [UIImage] = []
    private var pageViews : [UIViewController?] = []
    
    // MARK: - API's -
    //Color variables
    var animatedBarColor = UIColor(red: 28/255, green: 95/255, blue: 185/255, alpha: 1)
    var topBarBackground = UIColor.whiteColor()
    var buttonsTextColor = UIColor.grayColor()
    var containerViewBackground = UIColor.clearColor()
    //Item size variables
    var topBarHeight : CGFloat = 42
    var animatedBarHeight : CGFloat = 3
    //Bar item variables
    var buttonsWithImages : Bool = false
    var BarShadow : Bool = true
    var buttonsTextFontAndSize : UIFont = UIFont(name: "HelveticaNeue-Light", size: 20)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Size And Positions Of The Container View -
        var xOrigin:CGFloat = 0
        var yOrigin:CGFloat = 35
        var pagesContainerHeight = self.view.frame.height - 35
        var pagesContainerWidth = self.view.frame.width
        
        //Set the containerView, every item is constructed relative to this view
        containerView = UIView(frame: CGRectMake(xOrigin, yOrigin, pagesContainerWidth, pagesContainerHeight))
        containerView.backgroundColor = containerViewBackground
        self.view.addSubview(containerView)
        
        //Set the top bar
        topBar = UIView(frame: CGRectMake(0, 0, containerView.frame.size.width, topBarHeight))
        topBar.backgroundColor = topBarBackground
        containerView.addSubview(topBar)
        
        //Set the scrollview
        scrollView = UIScrollView(frame: CGRectMake(0, topBarHeight, containerView.frame.size.width, containerView.frame.size.height - topBarHeight))
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clearColor()
        containerView.addSubview(scrollView)
        
        // MARK: - View Controller ID Array -
        if viewControllerIDs.count == 0 {
            viewControllerIDs = ["FirstVC", "SecondVC", "ThirdVC", "FourthVC", "FifthVC"]
        }
        
        // MARK: - Button Titles/Images Array -
        //Important - Titles/Images Array must Have The Same Number Of Items As The viewControllerIDs Array
        if buttonTitles.count == 0 {
            buttonTitles = ["First", "Second", "Third", "Fourth", "Fifth"]
        }
        //Button images (Added if the buttonsWithImages var is set to true)
        if buttonImages.count == 0 {
            buttonImages = [UIImage(named:"Ovals.png")!,
                UIImage(named:"VerticalLines.png")!,
                UIImage(named:"HorizontalLines.png")!,
                UIImage(named:"SquareTriangle.png")!,
                UIImage(named:"Circle.png")!]
        }
        
        //Set the top bar buttons
        var buttonsXPosition: CGFloat = 0
        var buttonNumber = 0
        //Check to see if the top bar will be created with images ot text
        if (!buttonsWithImages) {
            for item in buttonTitles
            {
                var barButton: UIButton!
                barButton = UIButton(frame: CGRectMake(buttonsXPosition, 0, containerView.frame.size.width/(CGFloat)(viewControllerIDs.count), topBarHeight))
                barButton.backgroundColor = UIColor.clearColor()
                barButton.titleLabel!.font = buttonsTextFontAndSize
                barButton.setTitle(buttonTitles[buttonNumber], forState: UIControlState.Normal)
                barButton.setTitleColor(buttonsTextColor, forState: UIControlState.Normal)
                barButton.tag = buttonNumber
                barButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
                topBar.addSubview(barButton)
                buttonsXPosition = containerView.frame.size.width/(CGFloat)(viewControllerIDs.count) + buttonsXPosition
                buttonNumber++
            }
        } else {
            for item in buttonImages
            {
                var barButton: UIButton!
                barButton = UIButton(frame: CGRectMake(buttonsXPosition, 0, containerView.frame.size.width/(CGFloat)(viewControllerIDs.count), topBarHeight))
                barButton.backgroundColor = UIColor.clearColor()
                barButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                barButton.setImage(item, forState: .Normal)
                barButton.tag = buttonNumber
                barButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
                topBar.addSubview(barButton)
                buttonsXPosition = containerView.frame.size.width/(CGFloat)(viewControllerIDs.count) + buttonsXPosition
                buttonNumber++
            }
        }
        
        
        //Set up the animated UIView
        animatedBar = UIView(frame: CGRectMake(0, topBarHeight - animatedBarHeight + 1, (containerView.frame.size.width/(CGFloat)(viewControllerIDs.count))*0.8, animatedBarHeight))
        animatedBar.center.x = containerView.frame.size.width/(CGFloat)(viewControllerIDs.count * 2)
        animatedBar.backgroundColor = animatedBarColor
        containerView.addSubview(animatedBar)
        
        //Add the bar shadow (set to true or false with the BarShadow var)
        if (BarShadow){
            let barShadowImageView = UIImageView(image: UIImage(named:"BarShadow.png")!)
            barShadowImageView.frame = CGRect(x: 0, y: topBarHeight, width: containerView.frame.size.width, height: 4)
            containerView.addSubview(barShadowImageView)
        }
        
        let pageCount = viewControllerIDs.count
        
        //Fill the array containing the VC instances with nil objects as placeholders
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        //Defining the content size of the scrollview
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageCount),
            height: pagesScrollViewSize.height)
        
        //Load the pages to show initially
        loadVisiblePages()
    }
    
    func initializeWithVCIDsArrayAndButtonTitlesArray (VCIDsArray: [String], buttonTitlesArray: [String])
    {
        if VCIDsArray.count == buttonTitlesArray.count {
            viewControllerIDs = VCIDsArray
            buttonTitles = buttonTitlesArray
            buttonsWithImages = false
        } else {
            println("Initilization failed, the VC ID array count does not match the button titles array count.")
        }
    }
    
    func initializeWithVCIDsArrayAndButtonImagesArray (VCIDsArray: [String], buttonImagesArray: [UIImage])
    {
        if VCIDsArray.count == buttonImagesArray.count {
            viewControllerIDs = VCIDsArray
            buttonImages = buttonImagesArray
            buttonsWithImages = true
        } else {
            println("Initilization failed, the VC ID array count does not match the button images array count.")
        }
    }
    
    func loadPage(page: Int)
    {
        if page < 0 || page >= viewControllerIDs.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        //Use optional binding to check if the view has already been loaded
        if let pageView = pageViews[page]
        {
            // Do nothing. The view is already loaded.
        } else
        {
            println("Loading Page \(page)")
            //The pageView instance is nil, create the page
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            //Create the variable that will hold the VC being load
            var newPageView:UIViewController
            
            //Look for the VC by its identifier in the storyboard and add it to the scrollview
            newPageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(viewControllerIDs[page]) as! UIViewController
            newPageView.view.frame = frame
            scrollView.addSubview(newPageView.view)
            
            //Replace the nil in the pageViews array with the VC just created
            pageViews[page] = newPageView
        }
    }
    
    func loadVisiblePages() {
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
    
    func barButtonAction(sender:UIButton?)
    {
        var index:Int = sender!.tag
        let pagesScrollViewSize = scrollView.frame.size
        [scrollView .setContentOffset(CGPointMake(pagesScrollViewSize.width * (CGFloat)(index), 0), animated: true)]
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
        
        //The calculations for the animated bar's movements
        //The offset addition is based on the width of the animated bar (button width times 0.8)
        var offsetAddition = (containerView.frame.size.width/(CGFloat)(viewControllerIDs.count))*0.1
        animatedBar.frame = CGRectMake((offsetAddition + (scrollView.contentOffset.x/(CGFloat)(viewControllerIDs.count))), animatedBar.frame.origin.y, animatedBar.frame.size.width, animatedBar.frame.size.height);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
