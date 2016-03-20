SpotifyWebApi = require 'spotify-web-api-node'
moment = require 'moment'

applescript = require 'applescript'
HEAD = 'tell application "spotify" to '
VERBOSE = false

CURRENT = ""

module.exports = control =

  toggleVebosity: ->
    VERBOSE = !VERBOSE

  checkTrack: ->
    execScript(detailScript 'name').then (name) ->
      unless name == CURRENT
        trackDetails()
    , (err) ->
      console.log 'Could not get track name'
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
      if VERBOSE
        atom.notifications.addSuccess 'Toggling Play/Pause'
      trackDetails()
    , (err) ->
      atom.notifications.addError 'Play/Pause failed'

  playNext: ->
    script = HEAD + 'play next track'
    execScript(script).then (rst) ->
      atom.notifications.addSuccess 'Playing next track...'
    , (err) ->
      atom.notifications.addError 'Could not play next track'

  playPrev: ->
    script = HEAD + 'play previous track'
    execScript(script).then (rst) ->
      atom.notifications.addSuccess 'Playing previous track...'
    , (err) ->
      atom.notifications.addError 'Could not play previous track'

  incVol: -> adjVol(10)
  decVol: -> adjVol(-10)



adjVol = (variant) ->
  getVol().then (vol) ->
    vol = Math.max(Math.min(vol += variant, 100), 0)
    script = "#{HEAD} set sound volume to #{vol}"
    execScript(script).then (name) ->
      atom.notifications.addSuccess "Volume: #{vol}"
  , (err) ->
    atom.notifications.addError 'Could not adjust volume'
    , (err) ->
      atom.notifications.addError 'Could not adjust volume'

getVol = ->
  script = "#{HEAD} get sound volume"
  return execScript(script)


trackDetails = ->
  execScript(detailScript 'name').then (name) ->
    execScript(detailScript 'artist').then (artist) ->
      atom.notifications.addSuccess name + ' - ' + artist
      CURRENT = name
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
