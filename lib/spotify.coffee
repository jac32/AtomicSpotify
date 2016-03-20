SpotifyWebApi = require 'spotify-web-api-node'
control = require './control'
SpotifyView = require './spotify-view'
{CompositeDisposable} = require 'atom'

spotifyApi = new SpotifyWebApi ->
  clientId : '0f39154551684e12b45ba72e18d830b6',
  clientSecret : '57cb935d95f14c1ab427ff62eb37f148',
  redirectUri : 'NA'

module.exports = Spotify =
  subscriptions: null
  myPackageView: null
  leftPanel: null

#leftPanel = atom.workspace.addLeftPanel(item: spotifyView.getElement(), visible: true) kendrick

  activate: (state) ->
    @spotifyView = new SpotifyView(state.spotifyViewState)
    @searchPanel = atom.workspace.addLeftPanel(item: @spotifyView.getElement(), visible: false)

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'spotify:current-track': => control.currentTrack()
    @subscriptions.add atom.commands.add 'atom-workspace', 'spotify:play-pause': => control.playPause()
    @subscriptions.add atom.commands.add 'atom-workspace', 'spotify:play-next': => control.playNext()
    @subscriptions.add atom.commands.add 'atom-workspace', 'spotify:play-prev': => control.playPrev()
    @subscriptions.add atom.commands.add 'atom-workspace', 'spotify:track-duration': => control.trackDuration()
    @subscriptions.add atom.commands.add 'atom-workspace', 'spotify:toggle-verbosity': => control.toggleVebosity()
    @subscriptions.add atom.commands.add 'atom-workspace', 'spotify:play-selection': => playSelection()
    @subscriptions.add atom.commands.add 'atom-workspace', 'spotify:search-selection': => searchSelection()

  deactivate: ->
    @subscriptions.dispose()


playSelection = ->
  if editor = atom.workspace.getActiveTextEditor()
    selection = editor.getSelectedText()
    control.playUri selection


searchSelection = () ->
  if editor = atom.workspace.getActiveTextEditor()
    selection = editor.getSelectedText()
    searchTracks(selection).then (tracks) ->
      searchAlbums(selection).then (albums) ->
        searchPlayLists(selection).then (playlists) ->
          Spotify.spotifyView.setData(tracks, albums, playlists)

          unless Spotify.searchPanel.isVisible()
            Spotify.searchPanel.show()
          track = tracks.tracks.items[0]
          #control.playUri track.uri, track.album.uri

searchTracks = (query) ->
  spotifyApi.searchTracks(query).then (data) ->
    return data.body
  , (err) ->
    console.log 'Track search failed', err

searchAlbums = (query) ->
  spotifyApi.searchAlbums(query).then (data) ->
    return data.body
  , (err) ->
    console.log 'Album search failed', err

searchPlayLists = (query) ->
  spotifyApi.searchPlaylists(query).then (data) ->
    return data.body
  , (err) ->
    console.log 'Playlist search failed', err
