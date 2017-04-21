//
//  EPAlbumListViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 19/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//
import UIKit
import VK_ios_sdk
import DGActivityIndicatorView

class EPAlbumListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var searchBar: UISearchBar!
    var userID: Int!
    var albumList = [EPAlbum]()
    var filteredAlbumList = [EPAlbum]()
    var activityIndicatorView: DGActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Albums"
        
        activityIndicatorView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.lineScaleParty, tintColor: UIView.defaultTintColor(), size: 30)
        self.view.addSubview(activityIndicatorView)
        //            self.view.insertSubview(activityIndicatorView, belowSubview: self.tableView)
        activityIndicatorView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        activityIndicatorView.startAnimating()
        
        self.tableView.alpha = 0
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 320, height: 44));
        self.searchBar.delegate = self
        
        self.tableView.tableHeaderView = searchBar;
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        drawRightMenuButton()
        loadData()
        
        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        print("loading albums list of a user with ID: \(userID)")
        
        EPHTTPVKManager.getAlbumsOfUserWithID(userID, count: nil) { (result, albums) -> Void in
            if result {
                if let albumsReceived = albums {
                    self.albumList = albumsReceived
                    
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                    self.applyOffset()
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        () -> Void in
                        //animations
                        self.tableView.alpha = 1
                        self.activityIndicatorView.alpha = 0
                        
                        }, completion: {
                            (result: Bool) -> Void in
                            //completion
                            self.activityIndicatorView.stopAnimating()
                    }) 
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if (searchText.characters.count > 0) {
            
            self.filteredAlbumList = self.albumList.filter({ (album:EPAlbum) -> Bool in
                album.title.lowercased().contains(searchText.lowercased())
            })
            self.tableView.reloadData()
        } else {
            self.filteredAlbumList = [EPAlbum]()
            self.tableView.reloadData()
        }
    }
    
    func applyOffset() {
        var contentOffset = self.tableView.contentOffset
        contentOffset.y += self.searchBar!.frame.height
        self.tableView.contentOffset = contentOffset
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CellIdentifier")
        }
        let album: EPAlbum
        if (self.filteredAlbumList.count > 0) {
            album = self.filteredAlbumList[indexPath.row]
        } else {
            album = self.albumList[indexPath.row]
        }
        
        cell!.textLabel?.text = album.title
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let text = searchBar.text else {
            return 0
        }
        return text.characters.count > 0 ? self.filteredAlbumList.count : self.albumList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var selectedAlbum: EPAlbum!
        guard let text = searchBar.text else {
            return
        }
        if (text.characters.count > 0) {
            selectedAlbum = self.filteredAlbumList[indexPath.row]
        } else {
            selectedAlbum = self.albumList[indexPath.row]
        }
        
        self.performSegue(withIdentifier: "seguePlaylist", sender: selectedAlbum)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "seguePlaylist":
            if let selectedAlbum = sender as? EPAlbum {
                
                let destinationViewController = segue.destination as! EPPlaylistViewController
                destinationViewController.album = selectedAlbum
                destinationViewController.userID = userID
            }
            break
            
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectRow()
    }
    
    func deselectRow() {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
}
