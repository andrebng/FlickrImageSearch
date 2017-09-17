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
    
    // MARK: - Properties
    
    @IBOutlet var tableView             : UITableView!              // table representing photostream
    
    // MARK: -
    
    var viewModel: PhotoStreamViewViewModel!
    
    // MARK: -
    
    fileprivate var searchText          : String?                   // last searched term of user for lazy loading
    fileprivate var tmpPhotoCount       : Int  = 0                  // tmp count for lazy loading
    
    // MARK: -
    
    private var searchController        : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title                                              = "Search Photo"
        
        // Init View Model
        self.viewModel = PhotoStreamViewViewModel()
        
        self.viewModel.didUpdatePhotos = { [unowned self] (photos) in
            self.tableView.reloadData()
        }
        
        self.viewModel.queryingDidChange = { [unowned self] (querying) in
            if querying {
                self.showWaitOverlayWithText("Loading images...")
            }
            else {
                self.removeAllOverlays()
            }
        }
        
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
        
    }
}

// MARK: - SearchResults Delegate

extension PhotoStream: SearchResultsProtocol {
    
    func search(byText text: String?) {
        self.tmpPhotoCount = 0
        self.viewModel.resetPhotos = true
        
        if let text = text {
            self.searchText = text
            self.viewModel.query = text
        }
        else {
            guard let searchText = self.searchText else { return }
            self.viewModel.query = searchText
        }
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
        return self.viewModel.numberOfPhotos
    }
    
    // If search is active, show history, else photos
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForImage(indexPath: indexPath)
    }
    
    // Check if user scrolled to bottom, if so, load next set of pictures from incremented page
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == self.viewModel.numberOfPhotos && tmpPhotoCount < viewModel.numberOfPhotos {
            
            tmpPhotoCount = viewModel.numberOfPhotos
            
            guard let text = self.searchText else { return }
            self.viewModel.query = text
        }
    }
    
    // MARK: - Private tableview functions
    
    /// The photo cell
    ///
    /// - Parameter indexPath: indexpath of tableview
    /// - Returns: the photo cell
    private func cellForImage(indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else { fatalError("Unexpected Table View Cell") }
        
        if let viewModel = self.viewModel.viewModelForPhoto(at: indexPath.row) {
            cell.configure(withViewModel: viewModel)
        }
        
        return cell
    }
    
}
