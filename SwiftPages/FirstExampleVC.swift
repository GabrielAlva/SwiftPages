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
        
        automaticallyAdjustsScrollViewInsets = false
        
        // Instantiation and the setting of the size and position
        let swiftPagesView = SwiftPages(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        
        // Initiation
        let VCIDs = ["FirstVC", "SecondVC", "ThirdVC", "FourthVC", "FifthVC"]
        let buttonImages = [
            UIImage(named:"HomeIcon.png")!,
            UIImage(named:"LocationIcon.png")!,
            UIImage(named:"CollectionIcon.png")!,
            UIImage(named:"ListIcon.png")!,
            UIImage(named:"StarIcon.png")!
        ]
        
        // Sample customization
        swiftPagesView.initializeWithVCIDsArrayAndButtonImagesArray(VCIDs, buttonImagesArray: buttonImages)
        swiftPagesView.setTopBarBackground(UIColor(red: 244/255, green: 164/255, blue: 96/255, alpha: 1.0))
        swiftPagesView.setAnimatedBarColor(UIColor(red: 255/255, green: 250/255, blue: 205/255, alpha: 1.0))
        
        self.view.addSubview(swiftPagesView)
    }
}
