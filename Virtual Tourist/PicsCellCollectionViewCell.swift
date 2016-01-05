//
//  PicsCellCollectionViewCell.swift
//  
//
//  Created by arianne on 2015-09-10.
//
//

import UIKit

class PicsCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var flickPIcs: UIImageView!
    
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    
//    override func prepareForReuse()
//    {
//        super.prepareForReuse()
//    //    self.photoImageView.image = nil
//        self.selected = false
//    }

    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            if newValue {
                super.selected = true
                self.flickPIcs.alpha = 0.5
                print("selected")
            } else if newValue == false {
                super.selected = false
                self.flickPIcs.alpha = 1.0
                print("deselected")
            }
        }
    }


}
