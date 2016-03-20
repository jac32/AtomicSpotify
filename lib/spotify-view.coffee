control = require './control'

module.exports =
  class SpotifyView
    constructor: (serializedState) ->
      @element = document.createElement 'div'
      @element.classList.add 'spotify'

    setData: (tracks, albums, playlists) ->

      @element.innerHTML = ''

      console.log 'tracks', tracks
      console.log 'albums', albums
      console.log 'playlists', playlists

      tracklist  = setTracks @element, tracks
      console.log 'tracks set'
      albumlist = setAlbums @element, albums
      console.log 'albums set'
      playlistlist = setPlaylists @element, playlists
      console.log 'playlists set'
      console.log @element
      @element.appendChild tracklist
      @element.appendChild albumlist
      @element.appendChild playlistlist
      console.log 'HTML built'

    destroy: ->
      @element.remove()

    getElement: ->
      @element

setTracks = (menu, tracks) ->
  tracklist = document.createElement 'div'
  tracklist.classList.add 'tracklist'

  trackheader = document.createElement 'h2'
  trackheader.textContent = 'Tracks'
  tracklist.appendChild trackheader

  for x, i in tracks.tracks.items
    return tracklist if i >= 10
    result = document.createElement 'div'
    result.textContent = x.name + " - " + x.artists[0].name
    result.classList.add 'result'
    do (x) ->
      result.addEventListener "click", () ->
        control.playUri x.uri, x.album.uri
        menu.innerHTML = ''

    tracklist.appendChild result


setAlbums = (menu, albums) ->
  albumlist = document.createElement 'div'
  albumlist.classList.add 'albumlist'

  albumheader = document.createElement 'h2'
  albumheader.textContent = 'Albums'
  albumlist.appendChild albumheader
  console.log 'test'
  for x, i in albums.albums.items
    return albumlist if i > 10

    console.log i
    result = document.createElement 'div'
    result.textContent = x.name
    result.classList.add 'result'

    do (x) ->
      result.addEventListener "click", () ->
        control.playAlbumUri x.uri
        menu.innerHTML = ''
    albumlist.appendChild result


setPlaylists = (menu, playlists) ->
  playlistlist = document.createElement 'div'
  playlistlist.classList.add 'playlistlist'

  playlistheader = document.createElement 'h2'
  playlistheader.textContent = 'Playlists'
  playlistlist.appendChild playlistheader

  for x, i in playlists.playlists.items
    break if i > 10
    result = document.createElement 'div'
    result.textContent = x.name
    result.classList.add 'result'
    do (x) ->
      result.addEventListener "click", () ->
        control.playAlbumUri x.uri
        menu.innerHTML = ''
    playlistlist.appendChild result
  return playlistlist
