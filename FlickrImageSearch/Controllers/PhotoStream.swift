//
//  PhotoStream.swift
//  FlickrImageSearch
//
//  Created by Andre Nguyen on 9/11/17.
//  Copyright © 2017 Andre Nguyen. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import Kingfisher
import SwiftOverlays

class PhotoStream: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var tableView             : UITableView!              // table representing photostream
    
    //MARK: Properties
    
    private var flickrAPI               : FlickrAPI!
    private var page                    : Int = 1                   // page indicator for photo search api
    
    fileprivate var searchController    : UISearchController!
    fileprivate var searchText          : String?                   // last searched term of user for lazy loading
    fileprivate var photos              : NSMutableArray = []       // array photos from the Flickr-API
    fileprivate var searchHistory       : NSMutableArray = []       // search history of user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title                                              = "Search Photo"
        
        // Setup the Search Controller
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let searchResultsController = storyboard.instantiateViewController(withIdentifier: "SearchResultsViewController") as? SearchResultsViewController else {
            fatalError("Failed to init Search Results View Controller")
        }
        
        searchResultsController.delegate                        = self
        
        self.searchController                                   = UISearchController(searchResultsController: searchResultsController)
        self.searchController.searchBar.delegate                = searchResultsController
        self.searchController.dimsBackgroundDuringPresentation  = false
        definesPresentationContext                              = true
        self.searchController?.delegate                         = self
        
        self.searchText                                         = ""
        
        // table view setup
        self.tableView.delegate                                 = self
        self.tableView.dataSource                               = self
        self.tableView.separatorColor                           = UIColor.clear
        self.tableView.tableHeaderView                          = self.searchController?.searchBar
        
        // Initialize FlickrAPI
        self.flickrAPI = FlickrAPI(withAPIKey: API.FlickrAPIKey)
        
    }
    
    /// Searches for photos via Flickr-API and clears photo stream if new search was started
    ///
    /// - Parameters:
    ///   - text: search term for photos
    ///   - clearResults: true if clearing photo stream needed, else false
    func searchPhoto(withText text: String, clearResults: Bool) {
        
        // Load indicator
        self.showWaitOverlayWithText("Loading images...")
        
        flickrAPI.photoSearch(withText: text, andPage: self.page) { (response, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Request failed", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else if let photos = response {
                if photos.count > 0 {
                    if clearResults {
                        self.page = 0
                        self.photos.removeAllObjects()
                    }
                    
                    self.photos.addObjects(from: photos)
                    self.tableView.reloadData()
                    
                    self.page += 1
                    
                    // remove load indicator
                    self.removeAllOverlays()
                }
                else {
                    let alert = UIAlertController(title: "Info", message: "No photos were found", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}

// MARK: - SearchResults Delegate

extension PhotoStream: SearchResultsProtocol {
    
    func search(byText text: String) {
        self.searchText = text
        self.searchPhoto(withText: text, clearResults: true)
    }
    
}

// MARK: - UISearchController Delegate
// Don't hide Search Results when search bar is empty

extension PhotoStream: UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
}

//MARK: UITableView Delegate, DataSource
extension PhotoStream : UITableViewDelegate, UITableViewDataSource {
    
    // If search is active, show search history count, else photos count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    // If search is active, show history, else photos
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForImage(indexPath: indexPath)
    }
    
    // Check if user scrolled to bottom, if so, load next set of pictures from incremented page
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == self.photos.count {
            
            guard let text = self.searchText else { return }
            
            self.searchPhoto(withText: text, clearResults: false)
        }
    }
    
    // MARK: - Private tableview functions
    
    /// The photo cell
    ///
    /// - Parameter indexPath: indexpath of tableview
    /// - Returns: the photo cell
    private func cellForImage(indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else { fatalError("Unexpected Table View Cell") }
        
        if let photo = photos[indexPath.row] as? FlickrPhoto {
            cell.configure(withViewModel: FlickrPhotoViewModel(flickrPhoto: photo))
        }
        
        return cell
    }
    
}
