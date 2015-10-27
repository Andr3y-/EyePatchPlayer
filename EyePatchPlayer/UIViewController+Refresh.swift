//
//  UIViewController+Refresh.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 27/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
extension UIViewController {
    func setupRefresh() {
        if self.respondsToSelector("tableView"){
            if let tableView = self.performSelector("tableView").takeRetainedValue() as? UITableView {
                let refreshControl = UIRefreshControl()
                refreshControl.addTarget(self, action: "tableRefresh", forControlEvents: UIControlEvents.ValueChanged)
                tableView.addSubview(refreshControl)
            }
        }
    }

    func stopRefreshing() {
        if self.respondsToSelector("tableView"){
            if let tableView = self.performSelector("tableView").takeRetainedValue() as? UITableView {
                for view in tableView.subviews {
                    if view.isKindOfClass(UIRefreshControl) {
                        if let refreshControlView = view as? UIRefreshControl {
                            if refreshControlView.refreshing {
                                refreshControlView.endRefreshing()
                            }
                        }
                    }
                }
            }
        }
    }

    func startRefreshing() {
        if self.respondsToSelector("tableView"){
            if let tableView = self.performSelector("tableView").takeRetainedValue() as? UITableView {
                for view in tableView.subviews {
                    if view.isKindOfClass(UIRefreshControl) {
                        if let refreshControlView = view as? UIRefreshControl {
                            if !refreshControlView.refreshing {
                                refreshControlView.beginRefreshing()
                            }
                        }
                    }
                }
            }
        }
    }
}