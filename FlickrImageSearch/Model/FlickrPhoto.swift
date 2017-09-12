//
//  FlickrPhotos.swift
//  FlickrImageSearch
//
//  Created by Andre Nguyen on 9/11/17.
//  Copyright © 2017 Andre Nguyen. All rights reserved.
//

import ObjectMapper

class FlickrPhotosResult : Mappable {
    
    var photos : FlickrPhotos?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        photos <- map["photos"]
    }
    
}

class FlickrPhotos : Mappable {
    
    var photos: [FlickrPhoto]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        photos <- map["photo"]
    }
    
}

class FlickrPhoto : Mappable {
    
    var farm: NSNumber = 0.0
    var server: String = ""
    var photoId: String = ""
    var secret: String = ""
    var imageURL: String = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        farm <- map["farm"]
        server <- map["server"]
        photoId <- map["id"]
        secret <- map["secret"]
        
        self.imageURL = "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret).jpg"
    }
    
    init(ofFarm farm: NSNumber, atServer server: String, withPhotoId photoId: String, andSecret secret: String) {
        
        self.farm = farm
        self.server = server
        self.photoId = photoId
        self.secret = secret
        
        self.imageURL = "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret).jpg"
    }
}
