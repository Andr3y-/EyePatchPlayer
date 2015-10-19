//
//  EPFriendListViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 08/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPFriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var searchBar: UISearchBar!
    var userID:Int!
    var friends = [EPFriend]()
    var filteredFriends = [EPFriend]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Friends"
        
        self.filteredFriends = [EPFriend]()
        self.tableView.alpha = 0
        self.searchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44));
        self.searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar;
        log("EPFriendListViewController, userID = \(userID)")
        drawRightMenuButton()
        loadData()

        // Do any additional setup after loading the view.
    }

    func loadData() {
        print("loading friend list of a user with ID: \(userID)")
        
        let friendsRequest: VKRequest = VKRequest(method: "friends.get", andParameters: [VK_API_OWNER_ID : userID, VK_API_COUNT : 2000, "order" : "hints", "fields" : "domain"], andHttpMethod: "GET")

        friendsRequest.executeWithResultBlock({ (response) -> Void in
            if let responseJSON = response.json as? NSDictionary {
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
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.tableView.alpha = 1
                })

            }
        }, errorBlock: { (error) -> Void in
                
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if (searchText.characters.count>0){
            
            let predicate = NSPredicate(format: "firstName contains[c] %@ OR lastName contains[c] %@", searchText, searchText) // if you need case sensitive search avoid '[c]' in the predicate
            let arrayCast =  self.friends as NSArray
            self.filteredFriends = arrayCast.filteredArrayUsingPredicate(predicate) as! [EPFriend]
            self.tableView.reloadData()
        } else {
            self.filteredFriends = [EPFriend]()
            self.tableView.reloadData()
        }
    }
    
    func applyOffset(){
        var contentOffset = self.tableView.contentOffset
        contentOffset.y += CGRectGetHeight(self.searchBar!.frame)
        self.tableView.contentOffset = contentOffset
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("CellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CellIdentifier")
        }
        let friend: EPFriend
        if (self.filteredFriends.count > 0){
            friend = self.filteredFriends[indexPath.row]
        } else {
            friend = self.friends[indexPath.row]
        }
        
        cell!.textLabel?.text = friend.firstName + " " + friend.lastName
        
//        if let firstName = friend["first_name"] as? String {
//            if let lastName = friend["last_name"] as? String {
//                cell!.textLabel?.text = firstName + " " + lastName
//            }
//        }
        
//        cell!.textLabel?.text = track["first_name"] as? String
//        cell!.textLabel?.text = track["last_name"] as? String
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let text = searchBar.text else {
            return 0
        }
        return text.characters.count > 0 ? self.filteredFriends.count : self.friends.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var selectedFriend: EPFriend!
        guard let text = searchBar.text else {
            return
        }
        if (text.characters.count > 0){
            selectedFriend = self.filteredFriends[indexPath.row]
        } else {
            selectedFriend = self.friends[indexPath.row]
        }
        
        self.performSegueWithIdentifier("seguePlaylist", sender: selectedFriend)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            case "seguePlaylist":
                if let selectedFriend = sender as? EPFriend {
                    let destinationViewController = segue.destinationViewController as! EPPlaylistViewController
                    
                    destinationViewController.user = selectedFriend
                    destinationViewController.userID = selectedFriend.ID

                }
            break
            
        default:
            break
        }
    }

}
