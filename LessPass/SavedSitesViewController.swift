//
//  SavedSitesViewController.swift
//  LessPass UI
//
//  Created by Daniel Slupskiy on 14.01.17.
//  Copyright © 2017 Daniel Slupskiy. All rights reserved.
//

import UIKit

class SavedSitesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    dynamic var sites = [String]()
    var filteredSites = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addObserver(self, forKeyPath: "sites", options: .new, context: nil)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(SavedSitesViewController.getSitesList), for: .valueChanged)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        getSitesList()
    }
    
    func getSitesList() {
        sites.append("Site 1")
        sites.append("Site 2")
        sites.append("Site 3")
        sites.append("Site 4")
        sites.append("Site 5")
        tableView.refreshControl!.endRefreshing()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            switch keyPath {
            case "sites":
                tableView.isHidden = sites.count == 0
                tableView.reloadData()
            default:
                break
            }
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredSites = sites.filter { site in
            return site.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
}

extension SavedSitesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredSites.count
        }
        return sites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "siteCell", for: indexPath)
        let site: String
        if searchController.isActive && searchController.searchBar.text != "" {
            site = filteredSites[indexPath.row]
        } else {
            site = sites[indexPath.row]
        }
        cell.textLabel?.text = site
        cell.detailTextLabel?.text = site + " login"
        return cell
    }
}

extension SavedSitesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sites.remove(at: indexPath.row)
        }
    }
}

extension SavedSitesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
