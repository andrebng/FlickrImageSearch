//
//  FlickrPhotoViewModel.swift
//  FlickrImageSearch
//
//  Created by Andre Nguyen on 9/15/17.
//  Copyright © 2017 Nguyen. All rights reserved.
//

import Foundation

struct FlickrPhotoViewModel {
    
    // MARK: - Properties
    
    var flickrPhoto: FlickrPhoto
    
    // MARK: -
    
    var farm: String {
        return flickrPhoto.farm.stringValue
    }
    
    var server: String {
        return flickrPhoto.server
    }
    
    var photoId: String {
        return flickrPhoto.photoId
    }
    
    var secret: String {
        return flickrPhoto.secret
    }
    
    var imageURL: URL? {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret).jpg")
    }
    
}
