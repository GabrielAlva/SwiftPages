//
//  FirstExampleVC.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 6/27/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit

class FirstExampleVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let SPView : SwiftPages!
        SPView = SwiftPages(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        
        var VCIDs : [String] = ["FirstVC", "SecondVC", "ThirdVC", "FourthVC", "FifthVC"]
        
        var buttonImages : [UIImage] = [UIImage(named:"Home Icon.png")!,
                                        UIImage(named:"Places Icon.png")!,
                                        UIImage(named:"Grid Icon.png")!,
                                        UIImage(named:"HorizontalLines.png")!,
                                        UIImage(named:"Circle.png")!]
        
        SPView.initializeWithVCIDsArrayAndButtonImagesArray(VCIDs, buttonImagesArray: buttonImages)
        
        self.view.addSubview(SPView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
