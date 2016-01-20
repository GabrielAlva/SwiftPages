//
//  SecondExampleVC.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 6/27/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit

class SecondExampleVC: UIViewController {
    
    @IBOutlet var swiftPagesView: SwiftPages!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initiation
        let VCIDs = ["FirstVC", "SecondVC", "ThirdVC", "FourthVC", "FifthVC"]
        let buttonTitles = ["Home", "Places", "Photos", "List", "Tags"]
        
        // Sample customization
        swiftPagesView.setOriginY(0.0)
        swiftPagesView.enableAeroEffectInTopBar(true)
        swiftPagesView.setButtonsTextColor(UIColor.whiteColor())
        swiftPagesView.setAnimatedBarColor(UIColor.whiteColor())
        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
    }
}
