//
//  FlickrAPI.swift
//  FlickrImageSearch
//
//  Created by Andre Nguyen on 9/11/17.
//  Copyright © 2017 Andre Nguyen. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper

enum DataManagerError: Error {
    
    case unknown
    case failedRequest
    case invalidResponse
    
}

final class FlickrAPI {
    
    typealias PhotoDataCompletion = ([FlickrPhoto]?, DataManagerError?) -> ()
    
    // MARK: - Properties
    
    private let flickrAPIKey: String?
    
    // MARK: - Public Interface
    
    init(withAPIKey flickrKey: String) {
        self.flickrAPIKey = flickrKey
    }
    
    /// Flickr-API-Call using the "flickr.photos.search" method, to retrieve photos based on search text from a given page
    ///
    /// - Parameters:
    ///   - text: search term
    ///   - page: which page
    ///   - completion: completion handler to retrieve result
    public func photoSearch(withText text: String, andPage page: Int, completion: @escaping PhotoDataCompletion) {
        
        guard let urlEncodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(nil, .failedRequest)
            return
        }
        
        let url = api(method: API.FlickrAPISearchMethod, api_key: API.FlickrAPIKey, parameters: "text=\(urlEncodedText)&page=\(page)")
        
        // make a call to the "flickr.photos.search"-API to retrieve photos of given search term
        Alamofire.request(url).responseObject { (response: DataResponse<FlickrPhotosResult>) in
            self.didFetchPhotoData(response: response, completion: completion)
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    private func didFetchPhotoData(response: DataResponse<FlickrPhotosResult>, completion: PhotoDataCompletion) {
        switch response.result {
        case .success:
            
            if response.response?.statusCode == 200 {
                
                var error = DataManagerError.unknown
                
                if let flickrPhotos = response.result.value, let photos = flickrPhotos.photos {
                    completion(photos.photos, nil)
                }
                else {
                    error = .invalidResponse
                }
                
                completion(nil, error)
            }
            else {
                completion(nil, .failedRequest)
            }
            
            break
        case .failure:
            completion(nil, .failedRequest)
            break
        }
    }
    
}
