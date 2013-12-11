class Game
    #@SCALE_FACTOR: 2
    @SCREEN_WIDTH: 320
    @SCREEN_HEIGHT: 288
    @GRID_SIZE: 32

    constructor: ->
        @assetManager = new AssetManager()

        @assetManager.loadImage('pokemon-tiles.png')
        @assetManager.loadImage('pokemon-dialog-box.png')
        @assetManager.loadTilemap('pokemon-level.json')

        @assetManager.start =>
            @entityManager = new EntityManager(window.components)
            @cq = cq(Game.SCREEN_WIDTH, Game.SCREEN_HEIGHT).appendTo('.gameboy')
            #@cq.context.scale(Game.SCALE_FACTOR,Game.SCALE_FACTOR)
            #@cq.context.imageSmoothingEnabled = false
            #@cq.context.mozImageSmoothingEnabled = false
            #@cq.context.webkitImageSmoothingEnabled = false

            player = @entityManager.createEntityWithComponents([
                ['PixelPositionComponent', { x: 4 * Game.GRID_SIZE, y: 4 * Game.GRID_SIZE }]
                ['GridPositionComponent', { col: 4, row: 4, gridSize: Game.GRID_SIZE }]
                ['ShapeRendererComponent', { width: Game.GRID_SIZE, height: Game.GRID_SIZE, type: 'rectangle' }]
                ['ColorComponent', { color: '#33ff33' }]
                ['PokemonMovementComponent', { speed: 0.15 }]
                ['ActionInputComponent', {}]
                ['KeyboardArrowsInputComponent', {}]
                ['CameraFollowsComponent', {}]
                ['CollidableComponent', {}]
                ['DirectionComponent', {}]
            ])

            camera = @entityManager.createEntityWithComponents([
                ['CameraComponent', {}]
                ['PixelPositionComponent', { x: 0, y: 0 }]
                ['GridPositionComponent', { col: 0, row: 0 }]
            ])

            dialogBox = @entityManager.createEntityWithComponents([
                ['DialogBoxComponent', {}]
                ['DialogBoxTextComponent', { text: "OAK: It's unsafe!\nWild Pokemon live\nin the tall grass!" }]
                ['ActionInputComponent', {}]
                ['KeyboardArrowsInputComponent', {}]
            ])

            @initializeMap('pokemon-level.json')

            for i in [0..3]
                npc = @entityManager.createEntityWithComponents([
                    ['PixelPositionComponent', {
                        x: Math.round(Math.random() * Game.SCREEN_WIDTH / Game.GRID_SIZE) * Game.GRID_SIZE,
                        y: Math.round(Math.random() * Game.SCREEN_HEIGHT / Game.GRID_SIZE) * Game.GRID_SIZE
                    }]
                    ['GridPositionComponent', { col: 4, row: 4, gridSize: Game.GRID_SIZE }]
                    ['ShapeRendererComponent', { width: Game.GRID_SIZE, height: Game.GRID_SIZE, type: 'rectangle' }]
                    ['ColorComponent', { color: 'red' }]
                    ['PokemonMovementComponent', { speed: 0.15 }]
                    ['ActionInputComponent', {}]
                    ['RandomArrowsInputComponent', {}]
                    ['CollidableComponent', {}]
                    ['DirectionComponent', {}]
                ])

            @tilemapRenderingSystem = new TilemapRenderingSystem(@cq)
            @canvasRenderSystem = new CanvasRenderSystem(@cq)
            @dialogRenderingSystem = new DialogRenderingSystem(@cq)
            @inputSystem = new InputSystem()
            @randomInputSystem = new RandomInputSystem()
            @movementSystem = new MovementSystem()
            @tweenSystem = new TweenSystem()
            @pokemonMovementSystem = new PokemonMovementSystem()
            @cameraFollowingSystem = new CameraFollowingSystem()

            @cq.framework
                onstep: (delta, time) =>
                    @randomInputSystem.update(delta, @entityManager, @assetManager)
                    @movementSystem.update(delta, @entityManager, @assetManager)
                    @pokemonMovementSystem.update(delta, @entityManager, @assetManager)
                    @tweenSystem.update(delta, @entityManager, @assetManager)
                    @cameraFollowingSystem.update(delta, @entityManager, @assetManager)

                onrender: (delta, time) =>
                    @cq.clear('white')
                    @tilemapRenderingSystem.draw(delta, @entityManager, @assetManager)
                    @canvasRenderSystem.draw(delta, @entityManager, @assetManager)
                    @dialogRenderingSystem.draw(delta, @entityManager, @assetManager)
                    
                onresize: (width, height) ->
                onousedown: (x, y) ->
                onmouseup: (x, y) ->
                onmousemove: (x, y) ->
                onmousewheel: (delta) ->
                ontouchstart: (x, y, touches) ->
                ontouchend: (x, y, touches) ->
                ontouchmove: (x, y, touches) ->

                onkeydown: (key) =>
                    @inputSystem.updateKey(key, on, @entityManager)
                onkeyup: (key) =>
                    @inputSystem.updateKey(key, off, @entityManager)
                    if key == 'space'
                        localStorage.setItem('save', @entityManager.save())
                    if key == 'escape'
                        @entityManager.load(localStorage.getItem('save'))

                ongamepaddown: (button, gamepad) ->
                ongamepadup: (button, gamepad) ->
                ongamepadmove: (xAxis, yAxis, gamepad) ->
                ondropimage: (image) ->


    initializeMap: (dataUrl) ->
        mapData = @assetManager.assets['pokemon-level.json']

        for layer, i in mapData.layers
            if i == 3 or i == 5
                continue
            if layer.properties.layertype == 'visible'
                layer = @entityManager.createEntityWithComponents([
                    ['TilemapVisibleLayerComponent', { tileData: layer, tileImageUrl: 'pokemon-tiles.png', tileWidth: mapData.tilewidth, tileHeight: mapData.tileheight, zIndex: i }]
                ])
            else
                layer = @entityManager.createEntityWithComponents([
                    ['TilemapCollisionLayerComponent', { tileData: layer }]
                ])


window.game = new Game()
