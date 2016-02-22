//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Janaki Burugula on Feb/18/2016.
//  Copyright © 2016 janaki. All rights reserved.
//

import Foundation
import UIKit

class PhotoAlbumCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if imageView.image == nil {
            
            activityIndicator.startAnimating()
        }
    }
}
