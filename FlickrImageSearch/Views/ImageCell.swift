//
//  ImageCell.swift
//  FlickrImageSearch
//
//  Created by Andre Nguyen on 9/11/17.
//  Copyright © 2017 Andre Nguyen. All rights reserved.
//

import UIKit
import Kingfisher

class ImageCell: UITableViewCell {
    
    // MARK: - Type Properties
    
    static let reuseIdentifier = "ImageCell"
    
    // MARK: - Properties
    
    @IBOutlet var photoImageView: UIImageView!
    
    // MARK: - Configuration
    
    func configure(withViewModel viewModel: FlickrPhotoViewModel) {
        photoImageView.kf.setImage(with: viewModel.imageURL)
    }
}
