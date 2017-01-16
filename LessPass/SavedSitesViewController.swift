//
//  SavedSitesViewController.swift
//  LessPass UI
//
//  Created by Daniel Slupskiy on 14.01.17.
//  Copyright © 2017 Daniel Slupskiy. All rights reserved.
//

import UIKit

class SavedSitesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,UISearchDisplayDelegate {

    @IBOutlet weak var tableView: UITableView!
    dynamic var sites = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        addObserver(self, forKeyPath: "sites", options: .new, context: nil)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(SavedSitesViewController.getSitesList), for: .valueChanged)
        
        getSitesList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "siteCell", for: indexPath)
        cell.textLabel?.text = sites[indexPath.row]
        cell.detailTextLabel?.text = sites[indexPath.row] + " login"
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sites.remove(at: indexPath.row)
        }
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
}
