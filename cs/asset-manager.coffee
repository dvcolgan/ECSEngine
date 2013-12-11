class AssetManager
    constructor: ->
        @imagesPrefix = 'images/'
        @tilemapsPrefix = 'levels/'
        @imagesToLoad = []
        @tilemapsToLoad = []
        @assets = {}
        @remaining = 0

    loadImage: (url) ->
        @imagesToLoad.push(url)

    loadTilemap: (url) ->
        @tilemapsToLoad.push(url)

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
                @remaining--
                if @remaining == 0
                    callback()
            @assets[imgUrl] = img
