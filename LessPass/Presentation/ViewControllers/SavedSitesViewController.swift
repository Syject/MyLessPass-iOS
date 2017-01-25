//
//  SavedSitesViewController.swift
//  LessPass UI
//
//  Created by Daniel Slupskiy on 14.01.17.
//  Copyright © 2017 Daniel Slupskiy. All rights reserved.
//

import UIKit
import SCLAlertView

class SavedSitesViewController: UIViewController, LoginViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accountBarButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    dynamic var sites = [SavedOption]()
    var filteredSites = [SavedOption]()
    
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
    
    @IBAction func accountDidPressed(_ sender: Any) {
        
        if API.isUserAuthorized {
            API.unauthorizeUser()
            getSitesList()
            accountBarButton.title = "Log in"
            KeychainSwift().delete("email")
            KeychainSwift().delete("password")
            KeychainSwift().delete("token")
        } else {
            presentLoginViewControler()
        }
    }
    func presentLoginViewControler() {
        performSegue(withIdentifier: "presentLoginViewController", sender: self)
    }
    func getSitesList() {
        if API.isUserAuthorized {
            accountBarButton.title = "Log out"
            API.refreshToken(onSuccess: { _ in
                
            }, onFailure: { _ in
            
            })
            API.getAllOptions(onSuccess: { downloadedSites in
                self.sites = downloadedSites
            }, onFailure: { _ in
                SCLAlertView().showError("Error", subTitle: "Cannot receive sites list")
            })
            
            
        } else {
            sites = []
            if tableView.refreshControl!.isRefreshing {
                SCLAlertView().showError("Error", subTitle: "You need to authorize first")
            }
        }
        tableView.refreshControl!.endRefreshing()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            switch keyPath {
            case "sites":
                tableView.isHidden = !API.isUserAuthorized
                tableView.reloadData()
            default:
                break
            }
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredSites = sites.filter { site in
            return site.site.lowercased().contains(searchText.lowercased())
                || site.login.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueIdentifier = segue.identifier else {
            return
        }
        switch segueIdentifier {
        case "presentLoginViewController":
            let viewController = segue.destination as! LoginViewController
            viewController.delegate = self
        default:
            return
        }
    }
}

extension SavedSitesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var result = 0
        if sites.count != 0 {
            tableView.separatorStyle = .singleLine
            result = 1
            tableView.backgroundView = nil
        }
        else {
            tableView.separatorStyle = .none
        }
        return result
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredSites.count
        }
        return sites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "siteCell", for: indexPath)
        let site: SavedOption
        if searchController.isActive && searchController.searchBar.text != "" {
            site = filteredSites[indexPath.row]
        } else {
            site = sites[indexPath.row]
        }
        cell.textLabel?.text = site.site
        cell.detailTextLabel?.text = site.login
        return cell
    }
}

extension SavedSitesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            API.deleteOption(withId: sites[indexPath.row].id, onSuccess: {
                self.sites.remove(at: indexPath.row)
            }, onFailure: { _ in
                self.tableView.isEditing = false
            })
            
        }
    }
}

extension SavedSitesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
