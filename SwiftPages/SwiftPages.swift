//
//  SwiftPages.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 5/23/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit

class SwiftPages: UIViewController, UIScrollViewDelegate {
    
    var containerView: UIView!
    var scrollView: UIScrollView!
    var firstButton: UIButton!
    var secondButton: UIButton!
    var animatedBar: UIView!
    
    var pageViews: [UIViewController?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        
        //The number of pages within the scrollView
        let pageCount = 2
        
        //Fill the pageViews array with nil
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        //Set the content size of the scrollview and load the pages
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(pageCount), pagesScrollViewSize.height)
        loadVisiblePages()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // MARK: - Size and positions of the container view
        var xOrigin:CGFloat = 0
        var yOrigin:CGFloat = 35
        var pagesContainerHeight = self.view.frame.height - 35
        var pagesContainerWidth = self.view.frame.width
        
        //Set the containerView, every item is constructed relative to this view
        containerView = UIView(frame: CGRectMake(xOrigin, yOrigin, pagesContainerWidth, pagesContainerHeight))
        containerView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(containerView)
        
        //Set the scrollview
        scrollView = UIScrollView(frame: CGRectMake(0, 42, containerView.frame.size.width, containerView.frame.size.height - 42))
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        containerView.addSubview(scrollView)
        
        //Set the first button
        firstButton = UIButton(frame: CGRectMake(0, 0, containerView.frame.size.width/2, 41))
        firstButton.backgroundColor = UIColor.whiteColor()
        firstButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        firstButton.setTitle("First VC", forState: UIControlState.Normal)
        firstButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        firstButton.tag = 1
        firstButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(firstButton)
        
        //Set the second button
        secondButton = UIButton(frame: CGRectMake(containerView.frame.size.width/2, 0, containerView.frame.size.width/2, 41))
        secondButton.backgroundColor = UIColor.whiteColor()
        secondButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        secondButton.setTitle("Second VC", forState: UIControlState.Normal)
        secondButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        secondButton.tag = 2
        secondButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(secondButton)
        
        //Set up the animated UIView
        animatedBar = UIView(frame: CGRectMake(0, 39, (containerView.frame.size.width/2)*0.8, 3))
        animatedBar.center.x = containerView.frame.size.width/4
        animatedBar.backgroundColor = UIColor(red: 28/255, green: 95/255, blue: 185/255, alpha: 1)
        containerView.addSubview(animatedBar)
    }
    
    func barButtonAction(sender:UIButton?)
    {
        switch (sender!.tag) {
        case 1:
            [scrollView .setContentOffset(CGPointMake(0, 0), animated: true)]
        case 2:
            let pagesScrollViewSize = scrollView.frame.size
            [scrollView .setContentOffset(CGPointMake(pagesScrollViewSize.width, 0), animated: true)]
        default:
            println("No Selection")
        }
    }
    
    // MARK: - Scroll view related functions
    
    func loadPage(page: Int) {
        
        if page < 0 || page >= 2 {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        if let pageView = pageViews[page] {
            //Do nothing. The view is already loaded.
        } else {
            //Calculate the frame position for this page
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            //Create the variable that will hold the desired VC
            var newPageView:UIViewController
            
            //Determine which VC to put on screen and add it as a subview of the scrollView.
            if (page == 0) {
                newPageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FirstVC") as! UIViewController
            } else {
                newPageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SecondVC") as! UIViewController
            }
            newPageView.view.frame = frame
            scrollView.addSubview(newPageView.view)
            
            //Replace the nil value in the pageView array with the view that's been just created, that way it wont load again.
            pageViews[page] = newPageView
        }
    }
    
    func loadVisiblePages() {
        
        //The indexes of the pages to be created
        let firstPage = 0
        let lastPage = 1
        
        //Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
        
        //The calculations for the animated bar's movements
        var xFromCenter = self.view.frame.size.width - scrollView.contentOffset.x
        var offsetAddition = self.view.frame.width/4 - (((self.view.frame.width/2)*0.8)/2)
        
        animatedBar.frame = CGRectMake((offsetAddition + (scrollView.contentOffset.x/2)), animatedBar.frame.origin.y, animatedBar.frame.size.width, animatedBar.frame.size.height);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
