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
        self.searchController                                   = UISearchController(searchResultsController: nil)
        self.searchController.dimsBackgroundDuringPresentation  = false
        definesPresentationContext                              = true
        self.searchController?.searchBar.delegate               = self
        
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
        }
    }
    
}

// MARK: UISearchBar Delegate
extension PhotoStream : UISearchBarDelegate {
    
    // if search begins, set to reload table to show search-history
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchController.isActive = true
        self.tableView.reloadData()
    }
    
    // if search ends, search for photo and load photos
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text else {
            return
        }
        
        if text.characters.count > 0 {
            
            // add search term to history
            if !self.searchHistory.contains(text) {
                self.searchHistory.add(text)
            }
            
            self.searchText = text
            self.searchController.isActive = false
            self.searchPhoto(withText: text, clearResults: true)
        }
    }
    
    // if search canceled, reload table to photos
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
        self.tableView.reloadData()
    }
    
}

//MARK: UITableView Delegate, DataSource
extension PhotoStream : UITableViewDelegate, UITableViewDataSource {
    
    // If search is active, show search history count, else photos count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchController.isActive { return self.searchHistory.count }
        
        return self.photos.count
    }
    
    // If search is active, show history, else photos
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.searchController.isActive { return cellForHistory(indexPath: indexPath) }
        
        return cellForImage(indexPath: indexPath)
    }
    
    // if search is active, selected row is used as search term
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.searchController.isActive {
            
            guard let text = self.searchHistory[indexPath.row] as? String else { return }
            
            self.searchPhoto(withText: text, clearResults: true)
            self.searchController.isActive = false
        }
    }
    
    // Check if user scrolled to bottom, if so, load next set of pictures from incremented page
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == self.photos.count {
            
            guard let text = self.searchText else { return }
            
            self.searchPhoto(withText: text, clearResults: false)
        }
    }
    
    // set height for search-history-cell (SimpleCell) or photo-cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // simple cell height for history
        if self.searchController.isActive { return 42 }
        
        // height for photo cell
        return 185
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
    
    /// The history search cell of type SimpleCell
    ///
    /// - Parameter indexPath: indexpath of tableview
    /// - Returns: the SimpleCell, containig history search term
    private func cellForHistory(indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SimpleCell.reuseIdentifier, for: indexPath) as? SimpleCell else { fatalError("Unexpected Table View Cell") }
        
        if let text = self.searchHistory[indexPath.row] as? String {
            cell.searchTerm.text = text
        }
        
        return cell
    }
    
}
