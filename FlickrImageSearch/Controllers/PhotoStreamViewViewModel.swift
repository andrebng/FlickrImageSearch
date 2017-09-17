//
//  PhotoStreamViewViewModel.swift
//  FlickrImageSearch
//
//  Created by Andre Nguyen on 9/17/17.
//  Copyright © 2017 Nguyen. All rights reserved.
//

import Foundation

class PhotoStreamViewViewModel {
    
    // MARK: Properties
    
    var query: String = "" {
        didSet {
            page += 1
            searchForPhoto(searchTerm: query, forPage: page)
        }
    }
    
    var resetPhotos: Bool = false {
        didSet {
            if resetPhotos {
                mutablePhotos.removeAllObjects()
                photos.removeAll()
                page = 0
            }
        }
    }
    
    // MARK: - Public Interface
    
    var queryingDidChange: ((Bool) -> ())?
    var didUpdatePhotos: (([FlickrPhoto]) -> ())?
    
    // MARK: -
    
    var numberOfPhotos: Int { return photos.count }
    var hasPhotos: Bool { return numberOfPhotos > 0 }
    
    // MARK: Private Properties
    
    private var page: Int = 0
    
    private var querying: Bool = false {
        didSet {
            queryingDidChange?(querying)
        }
    }
    
    private var photos: [FlickrPhoto] = [] {
        didSet {
            didUpdatePhotos?(photos)
        }
    }
    
    private var mutablePhotos: NSMutableArray = NSMutableArray()
    
    // MARK: - 
    
    private lazy var flickrAPI = FlickrAPI(withAPIKey: API.FlickrAPIKey)
    
    // MARK: - Public Interface
    
    func photo(at index: Int) -> FlickrPhoto? {
        guard index < photos.count else { return nil }
        return photos[index]
    }
    
    func viewModelForPhoto(at index: Int) -> FlickrPhotoViewModel? {
        let photo = photos[index]
        return FlickrPhotoViewModel(flickrPhoto: photo)
    }
    
    // MARK: - Helper Methods
    
    func searchForPhoto(searchTerm: String?, forPage: Int) {
        guard let searchTerm = searchTerm, !searchTerm.isEmpty else {
            photos = []
            return
        }
        
        querying = true
        
        flickrAPI.photoSearch(withText: searchTerm, andPage: page) { [weak self] (photos, error) in
            guard let photos = photos else { return }
            
            self?.querying = false
            
            if let error = error {
                print("Unable to forward photos (\(error))")
            }
            else {
                self?.mutablePhotos.addObjects(from: photos)
                self?.photos = self?.mutablePhotos as! [FlickrPhoto]
            }
        }
    }
}
