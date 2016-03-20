SpotifyWebApi = require 'spotify-web-api-node'
moment = require 'moment'

applescript = require 'applescript'
HEAD = 'tell application "spotify" to '
VERBOSE = false

module.exports = control =

  toggleVebosity: ->
    VERBOSE = !VERBOSE

  currentTrack: ->
    trackDetails()

  playUri: (track, context) ->
    script = HEAD + 'play track "' + track + '" in context "' + context + '"'
    execScript(script).then (rst) ->
      trackDetails()
    , (err) ->
      atom.notifications.addError 'Could not play track'

  playAlbumUri: (album) ->
    script = HEAD + 'play track "' + album + '"'
    console.log script
    execScript(script).then (rst) ->
      trackDetails()
    , (err) ->
      atom.notifications.addError 'Could not play track'


  playPause: ->
    script = HEAD + 'playpause'
    execScript(script).then (rst) ->
      atom.notifications.addSuccess 'Toggling Play/Pause'
    , (err) ->
      atom.notifications.addError 'Play/Pause failed'

  playNext: ->
    script = HEAD + 'play next track'
    execScript(script).then (rst) ->
      atom.notifications.addSuccess 'Playing next track...'
      trackDetails()
    , (err) ->
      atom.notifications.addError 'Could not play next track'

    playPrev: ->
      script = HEAD + 'play prev track'
      execScript(script).then (rst) ->
        atom.notifications.addSuccess 'Playing previous track...'
        trackDetails()
      , (err) ->
        atom.notifications.addError 'Could not play previous track'

trackDetails = ->
  execScript(detailScript 'name').then (name) ->
    execScript(detailScript 'artist').then (artist) ->
      atom.notifications.addSuccess name + ' - ' + artist
      if VERBOSE
        execScript(detailScript 'album').then (album) ->
          atom.notifications.addInfo 'Album: ' + album
          execScript(detailScript 'duration').then (duration) ->
            atom.notifications.addInfo 'duration: ' + moment.utc(duration).format('HH:mm:ss')
            execScript(detailScript 'popularity').then (popularity) ->
              atom.notifications.addInfo 'Popularity: ' + popularity + '/100'

detailScript = (detail) ->
  return HEAD + 'get ' + detail + ' of current track'

execScript = (script) ->
  return new Promise (resolve, reject) ->
    applescript.execString script, (err, rtn) ->
      if err
        console.log script
        reject reason: 'Script failed to execute'
      else
        resolve rtn
