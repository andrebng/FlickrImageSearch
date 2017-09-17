//
//  SearchResultsViewController.swift
//  FlickrImageSearch
//
//  Created by Andre Nguyen on 9/15/17.
//  Copyright © 2017 Nguyen. All rights reserved.
//

import UIKit

protocol SearchResultsProtocol {
    
    func search(byText text: String?)
    
}

class SearchResultsViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var tableView             : UITableView!
    
    // MARK: - 
    
    var delegate                        : SearchResultsProtocol?
    
    fileprivate var searchHistory       : NSMutableArray = []       // search history of user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Table View
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

// MARK: - Search Bar Delegate

extension SearchResultsViewController: UISearchBarDelegate {
    
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
            
            guard let delegate = self.delegate else {
                return
            }
            
            searchBar.text = ""
            self.dismiss(animated: true, completion: nil)
            delegate.search(byText: text)
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - Table View Data Source

extension SearchResultsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForHistory(indexPath: indexPath)
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

// MARK: - Table View Delegate

extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let text = self.searchHistory[indexPath.row] as? String {
            delegate?.search(byText: text)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
