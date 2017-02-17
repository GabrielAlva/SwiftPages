//
//  VerticalViewController.swift
//  RAReorderableLayout-Demo
//
//  Created by Ryo Aoyama on 11/17/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit


// MARK: - VerticalViewController

class VerticalViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var imagesForSection0 = [UIImage]()
    var imagesForSection1 = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "RAReorderableLayout"
        
        collectionView.register(UINib(nibName: "verticalCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        for index in 0..<18 {
            let name = "Sample\(index).jpg"
            let image = UIImage(named: name)
            imagesForSection0.append(image!)
        }
        
        for index in 18..<30 {
            let name = "Sample\(index).jpg"
            let image = UIImage(named: name)
            imagesForSection1.append(image!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: 0, right: 0)
    }
}


// MARK: - VerticalViewController: RAReorderableLayoutDelegate

extension VerticalViewController: RAReorderableLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let threePiecesWidth = floor(screenWidth / 3.0 - ((2.0 / 3) * 2))
        let twoPiecesWidth = floor(screenWidth / 2.0 - (2.0 / 2))
        if indexPath.section == 0 {
            return CGSize(width: threePiecesWidth, height: threePiecesWidth)
        } else {
            return CGSize(width: twoPiecesWidth, height: twoPiecesWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, allowMoveAtIndexPath indexPath: IndexPath) -> Bool {
        if collectionView.numberOfItems(inSection: indexPath.section) <= 1 {
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, atIndexPath: IndexPath, didMoveToIndexPath toIndexPath: IndexPath) {
        var photo: UIImage
        if atIndexPath.section == 0 {
            photo = imagesForSection0.remove(at: atIndexPath.item)
        } else {
            photo = imagesForSection1.remove(at: atIndexPath.item)
        }
        
        if toIndexPath.section == 0 {
            self.imagesForSection0.insert(photo, at: toIndexPath.item)
        } else {
            self.imagesForSection1.insert(photo, at: toIndexPath.item)
        }
    }
}


// MARK: - VerticalViewController: RAReorderableLayoutDataSource

extension VerticalViewController: RAReorderableLayoutDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return imagesForSection0.count
        } else {
            return imagesForSection1.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "verticalCell", for: indexPath) as! RACollectionViewCell
        
        if indexPath.section == 0 {
            cell.imageView.image = imagesForSection0[indexPath.item]
        } else {
            cell.imageView.image = imagesForSection1[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 0.3
        }
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 100.0, left: 100.0, bottom: 100.0, right: 100.0)
    }
    
    func scrollTrigerPaddingInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: collectionView.contentInset.top, left: 0, bottom: collectionView.contentInset.bottom, right: 0)
    }
}


// MARK: - RACollectionViewCell

class RACollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var gradientLayer: CAGradientLayer?
    var hilightedCover: UIView!
    
    override var isHighlighted: Bool {
        didSet {
            hilightedCover.isHidden = !isHighlighted
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        hilightedCover.frame = bounds
        applyGradation(imageView)
    }
    
    fileprivate func configure() {
        imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        hilightedCover = UIView()
        hilightedCover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hilightedCover.backgroundColor = UIColor(white: 0, alpha: 0.5)
        hilightedCover.isHidden = true
        addSubview(hilightedCover)
    }
    
    fileprivate func applyGradation(_ gradientView: UIView!) {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
        
        gradientLayer = CAGradientLayer()
        gradientLayer!.frame = gradientView.bounds
        
        let mainColor = UIColor(white: 0, alpha: 0.3).cgColor
        let subColor = UIColor.clear.cgColor
        gradientLayer!.colors = [subColor, mainColor]
        gradientLayer!.locations = [0, 1]
        
        gradientView.layer.addSublayer(gradientLayer!)
    }
}
