//
//  TestClass.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 5/21/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit

class TestClass: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView!
    var firstButton: UIButton!
    var secondButton: UIButton!
    var animatedBar: UIView!
    
    var pageViews: [UIViewController?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func FirstPage(sender: AnyObject) {
        [scrollView .setContentOffset(CGPointMake(0, 0), animated: true)]
    }
    
    @IBAction func SecondPage(sender: AnyObject) {
        let pagesScrollViewSize = scrollView.frame.size
        [scrollView .setContentOffset(CGPointMake(pagesScrollViewSize.width, 0), animated: true)]
    }
    
    override func viewDidLayoutSubviews() {
        // 1
        
        let pageCount = 3
        
        // 3
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // 4
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * 3.0, pagesScrollViewSize.height)
        
        // 5
        loadVisiblePages()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //Set the scrollview
        scrollView = UIScrollView(frame: CGRectMake(0, 77, self.view.frame.width, self.view.frame.height-77))
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        
        //Set the buttons
        //let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        firstButton = UIButton(frame: CGRectMake(0, 35, self.view.frame.width/2, 41))
        firstButton.backgroundColor = UIColor.whiteColor()
        firstButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        firstButton.setTitle("First VC", forState: UIControlState.Normal)
        firstButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        firstButton.tag = 1
        firstButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(firstButton)
        
        //let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        secondButton = UIButton(frame: CGRectMake(self.view.frame.width/2, 35, self.view.frame.width/2, 41))
        secondButton.backgroundColor = UIColor.whiteColor()
        secondButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        secondButton.setTitle("Second VC", forState: UIControlState.Normal)
        secondButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        secondButton.tag = 2
        secondButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(secondButton)
        
        //Set up the animated UIView
        animatedBar = UIView(frame: CGRectMake(0, 74, (self.view.frame.width/2)*0.8, 3))
        animatedBar.center.x = self.view.frame.width/4
        animatedBar.backgroundColor = UIColor(red: 28/255, green: 95/255, blue: 185/255, alpha: 1)
        self.view.addSubview(animatedBar)
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
    
    func loadPage(page: Int) {
        println("Original Page int: \(page)")
        if page < 0 || page >= 3 {
            // If it's outside the range of what you have to display, then do nothing
            println("Entered the first part")
            return
        }
        
        // 1
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
            println("Do nothing. The view is already loaded. - 1")
        } else {
            println("Load page. - 2")
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            //            let newPageView = UIView()
            //            var randomRed:CGFloat = CGFloat(drand48())
            //            var randomGreen:CGFloat = CGFloat(drand48())
            //            var randomBlue:CGFloat = CGFloat(drand48())
            //            newPageView.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
            //            newPageView.frame = frame
            //            scrollView.addSubview(newPageView)
            var newPageView:UIViewController
            
            println("Page: \(page)")
            if (page == 0) {
                println("firstVC")
                newPageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FirstVC") as! UIViewController
            } else if (page == 1) {
                println("secondVC")
                newPageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SecondVC") as! UIViewController
            }
            else {
                println("thirdVC")
                newPageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ThirdVC") as! UIViewController
            }
            newPageView.view.frame = frame
            scrollView.addSubview(newPageView.view)
            
            // 4
            pageViews[page] = newPageView
        }
    }
    
    //    func purgePage(page: Int) {
    //
    //        if page < 0 || page >= 1 {
    //            // If it's outside the range of what you have to display, then do nothing
    //            return
    //        }
    //
    //        // Remove a page from the scroll view and reset the container array
    //        if let pageView = pageViews[page] {
    //            pageView.removeFromSuperview()
    //            pageViews[page] = nil
    //        }
    //
    //    }
    
    func loadVisiblePages() {
        
        // Work out which pages you want to load
        let firstPage = 0
        let lastPage = 2
        
        // Purge anything before the first page
        //        for index in 0..<firstPage {
        //            purgePage(index)
        //        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            println("Loop entered")
            loadPage(index)
        }
        
        // Purge anything after the last page
        //        for index in (lastPage + 1)..<(pageImages.count) {
        //            purgePage(index)
        //        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
        
        //println("Frame width: \(self.view.frame.size.width)")
        //println("contentOffset: \(scrollView.contentOffset.x)")
        
        var xFromCenter = self.view.frame.size.width - scrollView.contentOffset.x
        
        //        let pageWidth = scrollView.frame.size.width
        //        let page = Int(floor((scrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2.0)))
        //        println("Page: \(page)")
        //        var xCoor = (self.view.frame.size.width/2) * CGFloat(page)
        //        println("Xcoor: \(xCoor)")
        
        var alpha = self.view.frame.width/4 - (((self.view.frame.width/2)*0.8)/2)
        
        animatedBar.frame = CGRectMake((alpha + (scrollView.contentOffset.x/2)), animatedBar.frame.origin.y, animatedBar.frame.size.width, animatedBar.frame.size.height);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
