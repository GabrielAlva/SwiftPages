//
//  DemoCollectionVC.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 6/22/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit

class DemoCollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    var collectionViewImages : [UIImage] = [UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!,
                                            UIImage(named:"testImage.png")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        
        cell.cellImage.image = collectionViewImages[indexPath.row]
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
