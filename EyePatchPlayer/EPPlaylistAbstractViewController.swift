//
//  EPPlaylistAbstractViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 29/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//


import UIKit
import VK_ios_sdk
import DGActivityIndicatorView

class EPPlaylistAbstractViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, EPPlaylistDelegate, EPTrackTableViewCellDelegate {

    var activityIndicatorView: DGActivityIndicatorView!
    var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var playlist: EPMusicPlaylist!
    var filteredPlaylist: EPMusicPlaylist!

    fileprivate var readyToResignFirstResponder = true
    //settings for searchbar
    internal var shouldDrawSearchBar = true
    internal var shouldHideSearchBarWhenLoaded = true
    internal var shouldIgnoreLocalSearch = false
    internal var shouldShowActivityIndicator = true

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(becomeFirstResponder), name: NSNotification.Name(rawValue: "MenuDidHide"), object: nil)

        self.automaticallyAdjustsScrollViewInsets = false
        loadCell()

        performAdditionalSetup()

        self.tableView.alpha = 0

        if shouldDrawSearchBar {
            self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 320, height: 44));
            self.searchBar.delegate = self
            self.tableView.tableHeaderView = searchBar
        }

        if shouldShowActivityIndicator {
            activityIndicatorView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.lineScaleParty, tintColor: UIView.defaultTintColor(), size: 30)
            self.view.addSubview(activityIndicatorView)
//            self.view.insertSubview(activityIndicatorView, belowSubview: self.tableView)
            activityIndicatorView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
//            activityIndicatorView.
            activityIndicatorView.startAnimating()
        }

        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        drawRightMenuButton()
        loadData()
    }

    func performAdditionalSetup() {

    }

    func loadData() {

    }

    func dataReady() {
        print("data ready")

        if self.playlist != nil {
            //sometimes requests fail even in a case of success block
            self.playlist.delegate = self
            EPMusicPlayer.sharedInstance.playlist.delegate = self
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.reloadData()

            self.highlightActiveTrack(EPMusicPlayer.sharedInstance.isPlaying(), animated: true)
        }

        if shouldDrawSearchBar && shouldHideSearchBarWhenLoaded {
            self.applyOffset()
        }

        if self.shouldShowActivityIndicator {
            self.activityIndicatorView.alpha = 1
        }
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            //animations
            self.tableView.alpha = 1

            if self.shouldShowActivityIndicator {
                self.activityIndicatorView.alpha = 0
            }

        }, completion: {
            (result: Bool) -> Void in
            //completion
            if self.shouldShowActivityIndicator {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.alpha = 0
            }
        }) 
    }

    func dataNotReady() {

        if self.activityIndicatorView.animating {
            return
        }

        if shouldShowActivityIndicator {
            self.activityIndicatorView.startAnimating()

            if self.shouldShowActivityIndicator {
                self.activityIndicatorView.alpha = 0
            }

            UIView.animate(withDuration: 0.1, animations: {
                () -> Void in
                //animations
                self.activityIndicatorView.alpha = 1
            }, completion: {
                (result: Bool) -> Void in
                if self.shouldShowActivityIndicator {
                    self.activityIndicatorView.alpha = 1
                }
            }) 
        }
    }

    func loadCell() {
        let nibName = UINib(nibName: "EPTrackTableViewCell", bundle: nil)
        self.tableView.register(nibName, forCellReuseIdentifier: "TrackCell")
    }

    //MARK: Filtering & Local Search

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if (searchText.characters.count > 0) {

            filterSongsInArray()
            self.tableView.reloadData()
            highlightActiveTrack(true, animated: true)
        } else {
            self.filteredPlaylist = nil
            self.tableView.reloadData()
            highlightActiveTrack(false, animated: false)
        }
    }

    func filterSongsInArray() {
        
        guard let searchText = searchBar.text?.lowercased() else {
            return
        }
        
        let searchTextWords = searchText.components(separatedBy: " ").filter { (word) -> Bool in
            word.characters.count > 0
        }
        
        self.filteredPlaylist = EPMusicPlaylist(tracks: self.playlist.tracks.filter({ (track:EPTrack) -> Bool in
            var matchCount = 0
            
            for word in searchTextWords {
                if track.artist.lowercased().contains(word) || track.title.lowercased().contains(word) {
                    matchCount += 1
                }
            }
            
            return matchCount == searchTextWords.count
        }))
    }

    func highlightActiveTrack(_ scroll: Bool, animated: Bool) {
        if hasFilterActive() {
            for track in self.filteredPlaylist.tracks {

                if track.uniqueID == EPMusicPlayer.sharedInstance.activeTrack.uniqueID {
                    if let index = self.filteredPlaylist.tracks.index(of: track) {
                        self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)

                    }
                }

            }
        } else {
            for track in self.playlist.tracks {
                if track.uniqueID == EPMusicPlayer.sharedInstance.activeTrack.uniqueID {
                    if let index = self.playlist.tracks.index(of: track) {
                        self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: scroll ? UITableViewScrollPosition.middle : UITableViewScrollPosition.none)
                    }
                }
            }
        }
    }

    func applyOffset() {
        var contentOffset = self.tableView.contentOffset
        contentOffset.y += self.searchBar!.frame.height
        self.tableView.contentOffset = contentOffset
    }

    //MARK: TableView DataSource & Delegate

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: EPTrackTableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: "TrackCell") as? EPTrackTableViewCell

        if cell == nil {
            cell = EPTrackTableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "TrackCell")
        }
        let track: EPTrack
        if (hasFilterActive()) {
            track = self.filteredPlaylist.tracks[indexPath.row]
        } else {
            track = self.playlist.tracks[indexPath.row]
        }
        
        cell?.delegate = self
        cell?.setupLayoutForTrack(track)
        cell!.titleLabel?.text = track.title
        cell!.artistLabel?.text = track.artist
        cell?.durationLabel.text = track.duration.durationString

        if let downloadProgress = EPHTTPTrackDownloadManager.downloadProgressForTrack(track) {
            cell!.setupDownloadProgress(downloadProgress)
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let searchBarVar = searchBar, let text = searchBarVar.text else {
            return self.playlist.tracks.count
        }

        return text.characters.count > 0 ? self.filteredPlaylist.tracks.count : self.playlist.tracks.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAtIndexPath")

        let selectedTrack: EPTrack!
        if self.hasFilterActive() {
            selectedTrack = self.filteredPlaylist.tracks[indexPath.row]
        } else {
            selectedTrack = self.playlist.tracks[indexPath.row]
        }

        if selectedTrack.uniqueID != EPMusicPlayer.sharedInstance.activeTrack.uniqueID {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("didDeselectRowAtIndexPath")
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }

    func hasFilterActive() -> Bool {

        if shouldIgnoreLocalSearch {
            return false
        }

        guard let searchBarVar = searchBar, let text = searchBarVar.text else {
            return false
        }

        return (text.characters.count > 0)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //MARK: EPPlaylist Delegate

    func playlistDidSetTrackActive(_ track: EPTrack) {
        print("playlistDidSetTrackActive")

        let index: Int?

        if self.hasFilterActive() {
            index = self.filteredPlaylist.indexOfTrack(track)
        } else {
            index = self.playlist.indexOfTrack(track)
        }


        if let indexPathsForSelectedRow = self.tableView.indexPathForSelectedRow {
            print("hasIndexPathForSelectedRow = 1")
            self.tableView.deselectRow(at: indexPathsForSelectedRow, animated: true)
        } else {
            print("hasIndexPathForSelectedRow = 0")
        }

        if let index = index {
            self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.none)
        }

    }

    func playlistDidChangeOrder() {
        print("PlaylistVC: playlistDidChangeOrder")
        UIView.transition(with: tableView,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations:
                {
                    () -> Void in
                    self.tableView.reloadData()
                },
                completion: nil)
        self.highlightActiveTrack(true, animated: false)
    }

    //EPTrackTableViewCellDelegate

    func cellDetectedPrimaryTap(_ cell: EPTrackTableViewCell) {
        print("cellDetectedPrimaryTap")
        let selectedTrack: EPTrack!

        //        cell.setSelected(true, animated: true)
        if let indexPathsForSelectedRow = self.tableView.indexPathForSelectedRow {
            print("hasIndexPathForSelectedRow = 1")
            self.tableView.deselectRow(at: indexPathsForSelectedRow, animated: true)
        } else {
            print("hasIndexPathForSelectedRow = 0")
        }

        self.tableView.selectRow(at: self.tableView.indexPath(for: cell), animated: true, scrollPosition: UITableViewScrollPosition.none)

        if let indexPath = self.tableView.indexPath(for: cell) {

            if self.hasFilterActive() {
                selectedTrack = self.filteredPlaylist.tracks[indexPath.row]
                self.filteredPlaylist.delegate = self
                EPMusicPlayer.sharedInstance.playTrackFromPlaylist(selectedTrack, playlist: self.filteredPlaylist)

            } else {
                selectedTrack = self.playlist.tracks[indexPath.row]
                self.playlist.delegate = self
                EPMusicPlayer.sharedInstance.playTrackFromPlaylist(selectedTrack, playlist: self.playlist)

            }
        }
    }

    func cellDetectedSecondaryTap(_ cell: EPTrackTableViewCell) {

        let selectedTrack: EPTrack!

        if let indexPath = self.tableView.indexPath(for: cell) {
            if self.hasFilterActive() {
                selectedTrack = self.filteredPlaylist.tracks[indexPath.row]
            } else {
                selectedTrack = self.playlist.tracks[indexPath.row]
            }

            if selectedTrack.isCached {
                //handle is cached stuff to allow deletion in the future?
                return
            }
            
            if let _ = EPHTTPTrackDownloadManager.downloadProgressForTrack(selectedTrack) {
                //  Track is downloading
                if EPHTTPTrackDownloadManager.cancelTrackDownload(selectedTrack) {
                    //animate download cancelled
                    print("download cancelled")

                    
                } else {
                    //download cancellation failed
                    print("download cancellation failed")
                }
                
            } else {
                //  Track is NOT downloading
                cell.progressIndicatorView.progress = 0
                cell.progressIndicatorView.animateRotation(true)
                
                EPHTTPTrackDownloadManager.downloadTrack(selectedTrack, completion: {
                    (result, track) -> Void in
                    
                    }, progressBlock: {
                        (progressValue) -> Void in
                        if let progress = selectedTrack.downloadProgress {
                            progress.percentComplete = progressValue
                        }
                })
            }
        }
    }

    //hide keyboard when scrolling begins



    //MARK: Shaking

    override var canBecomeFirstResponder : Bool {
        return true
    }

    override var canResignFirstResponder : Bool {
        return readyToResignFirstResponder
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        self.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        super.viewWillDisappear(animated)
        readyToResignFirstResponder = true
        self.resignFirstResponder()
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == UIEventSubtype.motionShake {
            print("shake detected by \(self)")
            if EPSettings.shouldDetectShakeToShuffle() {
                handleShake()
            }
        }
    }

    func handleShake() {
        
        if self.playlist == nil {
            //  This may occur when playlist has not yet been loaded (VK Request Pending) but shake was detected
            return
        }
        
        EPPlayerWidgetView.sharedInstance.shuffleButtonView.setOn(true, animated: true)
        
        if self.hasFilterActive() {
            self.filteredPlaylist.reshuffle()
        } else {
            self.playlist.reshuffle()
        }
        
    }
}
