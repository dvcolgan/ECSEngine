class AssetManager
    constructor: ->
        @imagesPrefix = 'images/'
        @tilemapsPrefix = 'levels/'
        @audiosPrefix = 'audio/'
        @imagesToLoad = []
        @tilemapsToLoad = []
        @audiosToLoad = []
        @assets = {}
        @remaining = 0

    loadImage: (url) ->
        @imagesToLoad.push(url)

    loadTilemap: (url) ->
        @tilemapsToLoad.push(url)

    loadAudio: (url) ->
        @audiosToLoad.push(url)

    start: (callback) ->
        for tilemapUrl in @tilemapsToLoad
            ((tilemapUrl) =>
                xhr = new XMLHttpRequest()
                xhr.open('GET', @tilemapsPrefix + tilemapUrl, true)
                xhr.url = tilemapUrl
                @remaining++
                xhr.onreadystatechange = =>
                    if xhr.readyState == 4
                        @assets[xhr.url] = JSON.parse(xhr.response)
                        @remaining--
                        if @remaining == 0
                            callback()
                xhr.send()
            )(tilemapUrl)

        for imgUrl in @imagesToLoad
            img = new Image()
            img.src = @imagesPrefix + imgUrl
            @remaining++
            img.onload = =>
                console.log 'loaded image'
                @remaining--
                if @remaining == 0
                    callback()
            @assets[imgUrl] = img

        for audioUrl in @audiosToLoad
            audio = new Audio()
            audio.addEventListener('canplaythrough', (=>
                console.log 'loaded audio'
                @remaining--
                if @remaining == 0
                    callback()
            ), false)
            audio.src = @audiosPrefix + audioUrl
            @remaining++
            @assets[audioUrl] = audio


