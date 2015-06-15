//
//  SwiftPages.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 5/23/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit

class SwiftPages: UIViewController, UIScrollViewDelegate {
    
    private var containerView: UIView!
    private var scrollView: UIScrollView!
    private var animatedBar: UIView!
    var viewControllerIDs: [String] = []
    var buttonTitles: [String] = []
    private var pageViews: [UIViewController?] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Size and positions of the container view -
        var xOrigin:CGFloat = 0
        var yOrigin:CGFloat = 35
        var pagesContainerHeight = self.view.frame.height - 35
        var pagesContainerWidth = self.view.frame.width
        
        //Set the containerView, every item is constructed relative to this view
        containerView = UIView(frame: CGRectMake(xOrigin, yOrigin, pagesContainerWidth, pagesContainerHeight))
        containerView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(containerView)
        
        //Set the scrollview
        scrollView = UIScrollView(frame: CGRectMake(0, 42, containerView.frame.size.width, containerView.frame.size.height - 42))
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clearColor()
        containerView.addSubview(scrollView)
        
        // MARK: - View Controller ID Array -
        viewControllerIDs = ["FirstVC", "SecondVC", "ThirdVC", "FourthVC", "FifthVC"]
        
        // MARK: - Button Titles Array -
        //Important - Must Have The Same Number Of Items As The viewControllerIDs Array
        buttonTitles = ["First", "Second", "Third", "Fourth", "Fifth"]
        
        //Set the top bar buttons
        var buttonsXPosition: CGFloat = 0
        var buttonNumber = 0
        for item in buttonTitles
        {
            var barButton: UIButton!
            barButton = UIButton(frame: CGRectMake(buttonsXPosition, 0, containerView.frame.size.width/(CGFloat)(viewControllerIDs.count), 42))
            barButton.backgroundColor = UIColor.whiteColor()
            barButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            barButton.setTitle(buttonTitles[buttonNumber], forState: UIControlState.Normal)
            barButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            barButton.tag = buttonNumber
            barButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            containerView.addSubview(barButton)
            buttonsXPosition = containerView.frame.size.width/(CGFloat)(viewControllerIDs.count) + buttonsXPosition
            buttonNumber++
        }
        
        //Set up the animated UIView
        animatedBar = UIView(frame: CGRectMake(0, 40, (containerView.frame.size.width/(CGFloat)(viewControllerIDs.count))*0.8, 3))
        animatedBar.center.x = containerView.frame.size.width/(CGFloat)(viewControllerIDs.count * 2)
        animatedBar.backgroundColor = UIColor(red: 28/255, green: 95/255, blue: 185/255, alpha: 1)
        containerView.addSubview(animatedBar)
        
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
            
            newPageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(viewControllerIDs[page]) as! UIViewController
            newPageView.view.frame = frame
            scrollView.addSubview(newPageView.view)
            
            // 4
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
