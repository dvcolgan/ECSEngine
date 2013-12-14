class GameState
    constructor: ->
        @assetManager = new AssetManager()

        @loadAssets()

        @assetManager.start =>
            @eventManager = new EventManager()
            @entityManager = new EntityManager(window.components)

            @create()


    start: (@cq) ->
        @cq.framework
            onstep: (delta, time) =>
                @step(delta, time)

            onrender: (delta, time) =>
                @render(delta, time)
                
            onkeydown: (key) =>
                @keyDown(key)

            onkeyup: (key) =>
                @keyUp(key)

    loadAssets: ->
    create: ->
    step: (delta, time) ->
    render: (delta, time) ->
    keyUp: (key) ->
    keyDown: (key) ->


class TitleScreenState extends GameState
    loadAssets: ->
        @assetManager.loadImage('title-screen.png')

    create: ->

    render: (delta, time) ->
        @cq.drawImage(@assetManager.assets['title-screen.png'], 0, 0)

    keyUp: (key) ->
        if key == 'space'
            game.changeState(new PlayState())


class PlayState extends GameState

    loadAssets: ->
        @assetManager.loadImage('pokemon-tiles.png')
        @assetManager.loadImage('pikachu-sprites.png')
        @assetManager.loadImage('pokemon-dialog-box.png')
        @assetManager.loadTilemap('pokemon-level.json')
        @assetManager.loadAudio('audiotest.ogg')

    create: ->
        player = @entityManager.createEntityWithComponents([
            ['PlayerComponent', {}]
            ['PixelPositionComponent', { x: 4 * Game.GRID_SIZE, y: 4 * Game.GRID_SIZE }]
            ['GridPositionComponent', { col: 4, row: 4, gridSize: Game.GRID_SIZE }]
            ['PokemonMovementComponent', { speed: 0.15 }]
            ['ActionInputComponent', {}]
            ['KeyboardArrowsInputComponent', {}]
            ['CameraFollowsComponent', {}]
            ['CollidableComponent', {}]
            ['DirectionComponent', {}]
            ['AnimationComponent', { currentAction: 'walk-down', spritesheetUrl: 'pikachu-sprites.png', width: 32, height: 32 }]
            ['AnimationActionComponent', { name:  'walk-down', row: 0, indices: [0,1,0,2], frameLength: 200 }]
            ['AnimationActionComponent', { name:    'walk-up', row: 1, indices: [0,1,0,2], frameLength: 200 }]
            ['AnimationActionComponent', { name:  'walk-left', row: 2, indices: [0,1],     frameLength: 200 }]
            ['AnimationActionComponent', { name: 'walk-right', row: 3, indices: [0,1],     frameLength: 200 }]
        ])

        camera = @entityManager.createEntityWithComponents([
            ['CameraComponent', {}]
            ['PixelPositionComponent', { x: 0, y: 0 }]
            ['GridPositionComponent', { col: 0, row: 0 }]
        ])

        dialogBox = @entityManager.createEntityWithComponents([
            ['DialogBoxComponent', {}]
            ['DialogBoxTextComponent', { text: "OAK: It's unsafe!\nWild Pokemon live\nin the tall grass!" }]
            ['ActionInputComponent', { enabled: no }]
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
                ['PokemonMovementComponent', { speed: 0.15 }]
                ['ActionInputComponent', {}]
                ['RandomArrowsInputComponent', {}]
                ['CollidableComponent', {}]
                ['DirectionComponent', {}]
                ['AnimationComponent', { currentAction: 'walk-down', spritesheetUrl: 'pikachu-sprites.png', width: 32, height: 32 }]
                ['AnimationActionComponent', { name:  'walk-down', row: 0, indices: [0,1,0,2], frameLength: 200 }]
                ['AnimationActionComponent', { name:    'walk-up', row: 1, indices: [0,1,0,2], frameLength: 200 }]
                ['AnimationActionComponent', { name:  'walk-left', row: 2, indices: [0,1],     frameLength: 200 }]
                ['AnimationActionComponent', { name: 'walk-right', row: 3, indices: [0,1],     frameLength: 200 }]
            ])

        @tilemapRenderingSystem = new TilemapRenderingSystem(@cq, @entityManager, @eventManager, @assetManager)
        @canvasRenderSystem = new CanvasRenderSystem(@cq, @entityManager, @eventManager, @assetManager)
        @dialogRenderingSystem = new DialogRenderingSystem(@cq, @entityManager, @eventManager, @assetManager)
        @animatedSpriteSystem = new AnimatedSpriteSystem(@cq, @entityManager, @eventManager, @assetManager)
        @inputSystem = new InputSystem(@cq, @entityManager, @eventManager, @assetManager)
        @randomInputSystem = new RandomInputSystem(@cq, @entityManager, @eventManager, @assetManager)
        @movementSystem = new MovementSystem(@cq, @entityManager, @eventManager, @assetManager)
        @tweenSystem = new TweenSystem(@cq, @entityManager, @eventManager, @assetManager)
        @pokemonMovementSystem = new PokemonMovementSystem(@cq, @entityManager, @eventManager, @assetManager)
        @cameraFollowingSystem = new CameraFollowingSystem(@cq, @entityManager, @eventManager, @assetManager)
        @animationDirectionSyncSystem = new AnimationDirectionSyncSystem(@cq, @entityManager, @eventManager, @assetManager)
        @battleTriggerSystem = new BattleTriggerSystem(@cq, @entityManager, @eventManager, @assetManager)

    step: (delta, time) ->
        @eventManager.pump()
        @randomInputSystem.update(delta)
        @movementSystem.update(delta)
        @tweenSystem.update(delta)
        @pokemonMovementSystem.update(delta)
        @animatedSpriteSystem.update(delta)
        @cameraFollowingSystem.update(delta)
        @dialogRenderingSystem.update(delta)
        @animationDirectionSyncSystem.update(delta)

    render: (delta, time) ->
        @cq.clear('white')
        @tilemapRenderingSystem.draw(delta)
        @canvasRenderSystem.draw(delta)
        @animatedSpriteSystem.draw(delta)
        @dialogRenderingSystem.draw(delta)

    keyDown: (key) ->
        @inputSystem.updateKey(key, on)

    keyUp: (key) =>
        @inputSystem.updateKey(key, off)

        if key == 'space'
            localStorage.setItem('save', @entityManager.save())
        if key == 'escape'
            @entityManager.load(localStorage.getItem('save'))

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


class BattleTransitionState extends GameState
    create: (@previousScreen) ->
        @wipeX = 0
        c=document.createElement("canvas")
        @hiddenCtx = c.getContext("2d")

    step: (delta, time) ->
        @wipeY += 1 * delta
        if @wipeY > Game.SCREEN_HEIGHT
            game.state = new BattleState()

    render: (delta, time) ->
        @cq.drawImage(@previousScreen, 0, 0)
        @cq.fillRect(0, 0, Game.SCREEN_WIDTH, @wipeY)


class BattleState extends GameState

    loadAssets: ->
        @assetManager.loadImage('pokemon-tiles.png')
        @assetManager.loadImage('pikachu-sprites.png')
        @assetManager.loadImage('pokemon-dialog-box.png')
        @assetManager.loadTilemap('pokemon-level.json')

    create: ->

    step: (delta, time) ->

    render: (delta, time) ->

    keyDown: (key) ->
        @inputSystem.updateKey(key, on)

    keyUp: (key) =>
        @inputSystem.updateKey(key, off)

        if key == 'space'
            localStorage.setItem('save', @entityManager.save())
        if key == 'escape'
            @entityManager.load(localStorage.getItem('save'))

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


class Game
    #@SCALE_FACTOR: 2
    @SCREEN_WIDTH: 320
    @SCREEN_HEIGHT: 288
    @GRID_SIZE: 32
    @states = []

    constructor: ->
        @cq = cq(Game.SCREEN_WIDTH, Game.SCREEN_HEIGHT).appendTo('.gameboy')
        @states.push(new TitleScreenState())

    pushState: (state) ->
        @states.push(state)

    popState: ->
        @states.pop()


window.game = new Game()
