//
//  EPFriendListViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 08/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk
import EPPUIKit

class EPFriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var searchBar: UISearchBar!
    var userID: Int!
    var friends = [EPFriend]()
    var filteredFriends = [EPFriend]()
    var activityIndicatorView: DGActivityIndicatorView!

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Friends"

        activityIndicatorView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.lineScaleParty, tintColor: UIView.defaultTintColor(), size: 30)
        self.view.addSubview(activityIndicatorView)
        //            self.view.insertSubview(activityIndicatorView, belowSubview: self.tableView)
        activityIndicatorView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        activityIndicatorView.startAnimating()

        self.filteredFriends = [EPFriend]()
        self.tableView.alpha = 0
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 320, height: 44));
        self.searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar;
        print("EPFriendListViewController, userID = \(userID)")
        drawRightMenuButton()
        loadData()

        // Do any additional setup after loading the view.
    }

    func loadData() {
        print("loading friend list of a user with ID: \(userID)")

        let friendsRequest: VKRequest = VKRequest(method: "friends.get", andParameters: [VK_API_OWNER_ID: userID, VK_API_COUNT: 2000, "order": "hints", "fields": "domain"], andHttpMethod: "GET")

        friendsRequest.execute(resultBlock: {
            (response) -> Void in
            if let responseJSON = response?.json as? NSDictionary {
                if let friendDictionaries = responseJSON["items"] as? [NSDictionary] {
                    for friendDict in friendDictionaries {
                        let friend = EPFriend(response: friendDict)
                        self.friends.append(friend)
                    }
                }

//                self.friends = responseJSON["items"] as! [NSDictionary]
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
        }, errorBlock: {
            (error) -> Void in

        })
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if (searchText.characters.count > 0) {

            self.filteredFriends = self.friends.filter({ (friend:EPFriend) -> Bool in
                friend.firstName.lowercased().contains(searchText.lowercased()) || friend.lastName.lowercased().contains(searchText.lowercased())
            })
            
            self.tableView.reloadData()
        } else {
            self.filteredFriends = [EPFriend]()
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
        let friend: EPFriend
        if (self.filteredFriends.count > 0) {
            friend = self.filteredFriends[indexPath.row]
        } else {
            friend = self.friends[indexPath.row]
        }

        cell!.textLabel?.text = friend.firstName + " " + friend.lastName

        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let text = searchBar.text else {
            return 0
        }
        return text.characters.count > 0 ? self.filteredFriends.count : self.friends.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var selectedFriend: EPFriend!
        guard let text = searchBar.text else {
            return
        }
        if (text.characters.count > 0) {
            selectedFriend = self.filteredFriends[indexPath.row]
        } else {
            selectedFriend = self.friends[indexPath.row]
        }

        self.performSegue(withIdentifier: "seguePlaylist", sender: selectedFriend)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "seguePlaylist":
            if let selectedFriend = sender as? EPFriend {
                let destinationViewController = segue.destination as! EPPlaylistViewController

                destinationViewController.user = selectedFriend
                destinationViewController.userID = selectedFriend.ID

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
