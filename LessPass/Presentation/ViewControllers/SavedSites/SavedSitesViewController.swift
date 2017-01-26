//
//  SavedSitesViewController.swift
//  LessPass UI
//
//  Created by Daniel Slupskiy on 14.01.17.
//  Copyright © 2017 Daniel Slupskiy. All rights reserved.
//

import UIKit
import SCLAlertView

class SavedSitesViewController: UIViewController, LoginViewControllerDelegate,LessPassViewControllerDelegate {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var accountBarButton: UIBarButtonItem!
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate dynamic var allSites = [SavedOption]()
    fileprivate var filteredSites = [SavedOption]()
    fileprivate var sitesToDisplay: [SavedOption] {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredSites
        }
        return allSites
    }
    
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addObserver(self, forKeyPath: "allSites", options: .new, context: nil)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(SavedSitesViewController.getSitesList), for: .valueChanged)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        

        getSitesList()
    }
    
    internal func tryToAutologin() {
        if let token = KeychainSwift().get("token") {
            API.token = token
            API.refreshToken(onSuccess: {_ in 
                self.accountBarButton.title = "Log out"
                self.getSitesList()
            }, onFailure: { _ in
                API.token = nil
            })
        }
    }
    
    @IBAction fileprivate func accountDidPressed(_ sender: Any) {
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
    fileprivate func presentLoginViewControler() {
        performSegue(withIdentifier: "presentLoginViewController", sender: self)
    }
    internal func getSitesList() {
        if API.isUserAuthorized {
            accountBarButton.title = "Log out"
            API.refreshToken(onSuccess: { _ in
                
            }, onFailure: { _ in
                
            })
            API.getAllOptions(onSuccess: { downloadedSites in
                self.allSites = downloadedSites
            }, onFailure: { _ in
                SCLAlertView().showError("Error", subTitle: "Cannot receive sites list")
            })
        } else {
           allSites = []
            if tableView.refreshControl!.isRefreshing {
                SCLAlertView().showError("Error", subTitle: "You need to authorize first")
            }
        }
        tableView.refreshControl!.endRefreshing()
    }

    internal override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            switch keyPath {
            case "allSites":
                tableView.isHidden = !API.isUserAuthorized
                tableView.reloadData()
            default:
                break
            }
        }
    }
    
    fileprivate func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredSites = allSites.filter { site in
            return site.site.lowercased().contains(searchText.lowercased())
                || site.login.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    internal override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        switch segueIdentifier {
        case "presentLoginViewController":
            let viewController = segue.destination as! LoginViewController
            viewController.delegate = self
        case "showLessPassNew":
            let viewController = (segue.destination as! UINavigationController).childViewControllers[0] as! LessPassViewController
            setNavigationItem(onDestinationViewController: viewController)
            viewController.delegate = self
        case "showLessPassSaved":
            let viewController = (segue.destination as! UINavigationController).childViewControllers[0] as! LessPassViewController
            viewController.choosedSavedOption = sender as? SavedOption
            setNavigationItem(onDestinationViewController: viewController)
            viewController.delegate = self
        default:
            return
        }
    }

    func setNavigationItem(onDestinationViewController destinationViewController: UIViewController) {
        destinationViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        destinationViewController.navigationItem.leftItemsSupplementBackButton = true
    }
}


extension SavedSitesViewController: UITableViewDataSource {
    internal func numberOfSections(in tableView: UITableView) -> Int {
        var result = 0
        if sitesToDisplay.count != 0 {
            tableView.separatorStyle = .singleLine
            result = 1
            tableView.backgroundView = nil
        }
        else {
            tableView.separatorStyle = .none
        }
        return result
    }
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sitesToDisplay.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "siteCell", for: indexPath)
        let site = sitesToDisplay[indexPath.row]
        cell.textLabel?.text = site.site
        cell.detailTextLabel?.text = site.login
        return cell
    }
}

extension SavedSitesViewController: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showLessPassSaved", sender: sitesToDisplay[indexPath.row])
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let site =  sitesToDisplay[indexPath.row]
            API.deleteOption(withId: site.id!, onSuccess: {
                self.allSites.remove(at: self.allSites.index(of: site)!)
                self.updateSearchResults(for: self.searchController)
            }, onFailure: { _ in
                self.tableView.isEditing = false
            })
            
        }
    }
}

extension SavedSitesViewController: UISearchResultsUpdating {
    internal func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
