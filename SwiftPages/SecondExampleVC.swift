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

        var VCIDs : [String] = ["FirstVC", "SecondVC", "ThirdVC"]
        var buttonTitles : [String] = ["First", "Second", "Third"]
        swiftPagesView.setOriginY(0.0)
        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
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
