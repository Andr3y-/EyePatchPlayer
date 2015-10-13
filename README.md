# EyePatchPlayer
DONE:

- [x] Cache for Offline Playback
- [x] VK Status Broadcast
- [x] Streaming from Web
- [x] Fully functional player with playback control, shuffle and playlists
- [x] Remote playback control from iOS (lock and bottom pan menu)
- [x] Album Covers in App & on the Lock Screen
- [x] Reworked shuffle to have a separate playlist (of ID') instead which is infinite for switching tracks
- [x] EPMusicPlayerDelegate as a separate class for code clarity
- [x] EPMusicPlayerRemoteManager controlling player (even when player VC is not visible)
- [x] Friends' Playlists
- [x] Pause when headphones are disconnected, resume when headphones are connected
- [x] Display cached status for tracks 
- [x] Show duration in the playlist

TODO:
- [ ] 
- [ ] Ability to Edit Track (Title/Artist) for correct spelling
- [ ] Ability to Add Search Results into a playlist
- [ ] Ability to Search and Manually select a desired Album Cover (iTunes)
- [ ] Tracks from messages
- [ ] Download Queue
- [ ] Move elapsed time on Remote Control to UpdateProgress Method, perhaps, implement it in a separate class for code clarity
- [ ] Play Selection / Search Results
- [ ] Equalizer
- [ ] Player Widget visible across all screens of the application
- [ ] Removing remote controls from playerViewController
- [ ] Displaying download progress
- [ ] Last.fm scrobbling
- [ ] Settings Page with
-   [ ] Last.fm (once API becomes available)
-   [ ] Status broadcast
-   [ ] Cache Policy
- [ ] Global Search
- [ ] Recommendations (based on a playlist/single song)
- [ ] Extensively Visualised Playback Statistics
- [ ] UI Improvements

TOFIX:

- [ ] Double Authentication with VK
- [ ] Rare bug with playback time being reset to 0 while playing