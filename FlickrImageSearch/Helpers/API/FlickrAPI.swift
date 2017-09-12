//
//  FlickrAPI.swift
//  FlickrImageSearch
//
//  Created by Andre Nguyen on 9/11/17.
//  Copyright © 2017 Andre Nguyen. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper

class FlickrAPI {
    
    //MARK: Vars
    private let flickrAPIKey: String?
    
    init(withAPIKey flickrKey: String) {
        self.flickrAPIKey = flickrKey
    }
    
    /// Returns the URL for a HTTP call of the Flickr-API
    /// Returns 10 photos per page
    ///
    /// - Parameters:
    ///   - method: HTTP method of Flickr-API (e.g. "flickr.photos.search")
    ///   - api_key: generated API-KEY (stored in Constants)
    ///   - parameters: parameters for the HTTP call
    /// - Returns: url for API call
    private func api(method: String, api_key: String, parameters: String) -> String {
        return "\(API.FlickrAPIURL)?method=\(method)&api_key=\(api_key)&\(parameters)&format=json&nojsoncallback=1&per_page=10"
        
    }
    
    /// Flickr-API-Call using the "flickr.photos.search" method, to retrieve photos based on search text from a given page
    ///
    /// - Parameters:
    ///   - text: search term
    ///   - page: which page
    ///   - completion: completion handler to retrieve result
    public func photoSearch(withText text: String, andPage page: Int, completion: @escaping (_ success: Bool, _ results: [FlickrPhoto]?, _ message: String) -> Void) {
        
        guard let urlEncodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(false, nil, "Invalid search term")
            return
        }
        
        let url = api(method: "flickr.photos.search", api_key: API.FlickrAPIKey, parameters: "text=\(urlEncodedText)&page=\(page)")
        
        // make a call to the "flickr.photos.search"-API to retrieve photos of given search term
        Alamofire.request(url).responseObject { (response: DataResponse<FlickrPhotosResult>) in
            
            switch response.result {
            case .success:
                
                if response.response?.statusCode == 200 {
                    
                    guard let flickrPhotos = response.result.value else {
                        completion(false, nil, "An error occurred retrieving the information")
                        return
                    }
                    
                    guard let photos = flickrPhotos.photos else {
                        completion(false, nil, "Error retrieving photos")
                        return
                    }
                    
                    guard let photosCount = photos.photos?.count else {
                        completion(false, nil, "Error retrieving count of photos")
                        return
                    }
                    
                    if photosCount > 0 {
                        completion(true, photos.photos, "Success")
                    }
                    else {
                        completion(false, nil, "No photos found")
                    }
                    
                }
                else {
                    completion(false, nil, "Status code: \(response.response?.statusCode ?? -1)")
                }
                
                break
            case .failure:
                completion(false, nil, "An unknown error occured. Please try again later.")
                break
            }
        }
    }
    
}
