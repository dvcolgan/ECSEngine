class PokemonMovementSystem
    update: (delta, entityManager, assetManager) ->
        for [entity, movement, direction, arrows, gridPosition, pixelPosition] in entityManager.iterateEntitiesWithComponents(['PokemonMovementComponent', 'DirectionComponent', 'ActionInputComponent', 'GridPositionComponent', 'PixelPositionComponent'])
            tweens = entityManager.getComponents(entity, 'TweenComponent')
            moving = no
            for tween in tweens
                if tween.component == pixelPosition
                    moving = yes
                    break
            if not moving
                gridPosition.col = Math.round(pixelPosition.x / gridPosition.gridSize)
                gridPosition.row = Math.round(pixelPosition.y / gridPosition.gridSize)
                dx = dy = 0
                if arrows.left then dx -= 1
                if arrows.right then dx += 1
                if dx == 0
                    if arrows.up then dy -= 1
                    if arrows.down then dy += 1
                if dx > 0 or dx < 0 or dy > 0 or dy < 0
                    if dx < 0 then direction.direction = 'left'
                    if dx > 0 then direction.direction = 'right'
                    if dy < 0 then direction.direction = 'up'
                    if dy > 0 then direction.direction = 'down'

                    for [_, collisionLayer] in entityManager.iterateEntitiesWithComponents(['TilemapCollisionLayerComponent'])
                        tileIdx = (gridPosition.row+dy) * collisionLayer.tileData.width + (gridPosition.col+dx)
                        nextTile = collisionLayer.tileData.data[tileIdx]
                        if nextTile == 0
                            canMove = true
                            for [_, otherGridPosition, _] in entityManager.iterateEntitiesWithComponents(['GridPositionComponent', 'CollidableComponent'])
                                if (gridPosition.col+dx) == otherGridPosition.col and (gridPosition.row+dy) == otherGridPosition.row
                                    canMove = false
                            if canMove
                                if dx > 0 or dx < 0
                                    #pixelPosition.x += gridPosition.gridSize * dx
                                    entityManager.addComponent(entity, 'TweenComponent', {
                                        speed: movement.speed,
                                        start: pixelPosition.x, dest: pixelPosition.x + gridPosition.gridSize * dx,
                                        component: pixelPosition, attr: 'x', easingFn: 'linear'
                                    })
                                if dy > 0 or dy < 0
                                    #pixelPosition.y += gridPosition.gridSize * dy
                                    entityManager.addComponent(entity, 'TweenComponent', {
                                        speed: movement.speed,
                                        start: pixelPosition.y, dest: pixelPosition.y + gridPosition.gridSize * dy,
                                        component: pixelPosition, attr: 'y', easingFn: 'linear'
                                    })
                                gridPosition.doSync = false


class TweenSystem
    # PSEUDO CODE
    update: (delta, entityManager, assetManager) ->
        for [entity, tween] in entityManager.iterateEntitiesWithComponents(['TweenComponent'])
            if tween.start == tween.dest
                entityManager.removeComponent(entity, tween)

            if tween.current == null then tween.current = tween.start

            dir = if tween.start < tween.dest then 1 else -1

            if tween.easingFn == 'linear'
                tween.current += delta * tween.speed * dir
            else if tween.easingFn == 'ease-out-bounce'
                t = Math.abs(tween.current / tween.dest)
                c = delta * tween.speed * dir
                b = tween.start
                if t < (1/2.75)
                    tween.current = c*(7.5625*t*t) + b
                else if t < (2/2.75)
                    tween.current = c*(7.5625*(t-=(1.5/2.75))*t + .75) + b
                else if t < (2.5/2.75)
                    tween.current = c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b
                else
                    tween.current = c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b

            tween.component[tween.attr] = tween.current
            # TODO what happens if you add a tween that has the same start and dest?

            if (tween.start < tween.dest and tween.current > tween.dest) or (tween.start >= tween.dest and tween.current < tween.dest)
                tween.component[tween.attr] = tween.dest
                entityManager.removeComponent(entity, tween)


class CanvasRenderSystem
    constructor: (@cq) ->

    draw: (delta, entityManager, assetManager) ->
        camera = entityManager.getEntitiesWithComponents(['CameraComponent', 'PixelPositionComponent'])
        cameraPosition = entityManager.getComponent(camera, 'PixelPositionComponent')

        for [entity, position, color, shape, direction] in entityManager.iterateEntitiesWithComponents(['PixelPositionComponent', 'ColorComponent', 'ShapeRendererComponent', 'DirectionComponent'])
            @cq.fillStyle(color.color)
            if shape.type == 'rectangle'
                @cq.fillRect(position.x - cameraPosition.x, position.y - cameraPosition.y, shape.width, shape.height)
                @cq.beginPath()
                fromX = position.x + shape.width / 2
                fromY = position.y + shape.height / 2
                fromX -= cameraPosition.x
                fromY -= cameraPosition.y
                @cq.moveTo(fromX, fromY)
                toX = fromX
                toY = fromY
                switch direction.direction
                    when 'left'  then toX -= shape.width / 2
                    when 'right' then toX += shape.width / 2
                    when 'up'    then toY -= shape.width / 2
                    when 'down'  then toY += shape.width / 2
                @cq.lineTo(toX, toY)
                @cq.lineWidth = 4
                @cq.strokeStyle = 'black'
                @cq.lineCap = 'round'
                @cq.stroke()
            else
                throw 'NotImplementedException'


class InputSystem
    updateKey: (key, value, entityManager, assetManager) ->
        for [entity, _, arrows] in entityManager.iterateEntitiesWithComponents(['KeyboardArrowsInputComponent', 'ActionInputComponent'])
            switch key
                when 'left'
                    arrows.left = value
                when 'right'
                    arrows.right = value
                when 'up'
                    arrows.up = value
                when 'down'
                    arrows.down = value


class RandomInputSystem
    update: (delta, entityManager, assetManager) ->
        for [entity, _, arrows] in entityManager.iterateEntitiesWithComponents(['RandomArrowsInputComponent', 'ActionInputComponent'])
            arrows.left = arrows.right = arrows.up = arrows.down = false
            chance = 0.002
            if Math.random() < chance then arrows.left = true
            if Math.random() < chance then arrows.right = true
            if Math.random() < chance then arrows.up = true
            if Math.random() < chance then arrows.down = true


class MovementSystem
    update: (delta, entityManager, assetManager) ->
        for [entity, position, velocity, arrows] in entityManager.iterateEntitiesWithComponents(['PixelPositionComponent', 'VelocityComponent', 'ArrowKeyInputComponent'])
            velocity.dx = velocity.dy = 0
            if arrows.left then velocity.dx -= velocity.maxSpeed * delta
            if arrows.right then velocity.dx += velocity.maxSpeed * delta
            if arrows.up then velocity.dy -= velocity.maxSpeed * delta
            if arrows.down then velocity.dy += velocity.maxSpeed * delta

            position.x += velocity.dx
            position.y += velocity.dy


class CameraFollowingSystem
    update: (delta, entityManager, assetManager) ->
        camera = entityManager.getSingletonEntityWithComponent('CameraComponent')
        cameraPosition = entityManager.getComponent(camera, 'PixelPositionComponent')
        followee = entityManager.getSingletonEntityWithComponent('CameraFollowsComponent')
        followeePosition = entityManager.getComponent(followee, 'PixelPositionComponent')

        mapLayer = entityManager.getEntitiesWithComponent('TilemapVisibleLayerComponent')[0]
        mapLayerComponent = entityManager.getComponent(mapLayer, 'TilemapVisibleLayerComponent')

        mapWidth = mapLayerComponent.tileWidth * mapLayerComponent.tileData.width
        mapHeight = mapLayerComponent.tileHeight * mapLayerComponent.tileData.height

        cameraPosition.x = followeePosition.x - (Game.SCREEN_WIDTH / 2 - 32)
        cameraPosition.y = followeePosition.y - (Game.SCREEN_HEIGHT / 2 - 16)
        cameraPosition.x = cameraPosition.x.clamp(0, mapWidth - Game.SCREEN_WIDTH)
        cameraPosition.y = cameraPosition.y.clamp(0, mapHeight - Game.SCREEN_HEIGHT)


class TilemapRenderingSystem
    constructor: (@cq) ->

    draw: (delta, entityManager, assetManager) ->
        camera = entityManager.getSingletonEntityWithComponent('CameraComponent')
        cameraPosition = entityManager.getComponent(camera, 'PixelPositionComponent')

        entities = entityManager.getEntitiesWithComponent('TilemapVisibleLayerComponent')
        layers = []
        for entity in entities
            layers.push(entityManager.getComponent(entity, 'TilemapVisibleLayerComponent'))

        layers.sort((a, b) -> a.zIndex - b.zIndex)

        for layer in layers
            tileImage = assetManager.assets[layer.tileImageUrl]

            tileImageTilesWide = tileImage.width / layer.tileWidth
            tileImageTilesHigh = tileImage.height / layer.tileHeight

            startCol = Math.floor(cameraPosition.x/layer.tileWidth)
            startRow = Math.floor(cameraPosition.y/layer.tileHeight)

            endCol = startCol + Math.ceil(Game.SCREEN_WIDTH/layer.tileWidth)
            endRow = startRow + Math.ceil(Game.SCREEN_HEIGHT/layer.tileWidth)

            for row in [startRow..endRow]
                for col in [startCol..endCol]
                    tileIdx = row * layer.tileData.width + col
                    if col < layer.tileData.width and col >= 0 and row < layer.tileData.height and row >= 0

                        thisTile = layer.tileData.data[tileIdx] - 1
                        thisTileImageX = (thisTile % tileImageTilesWide) * layer.tileWidth
                        thisTileImageY = Math.floor(thisTile / tileImageTilesWide) * layer.tileHeight
                        screenX = Math.floor(col * layer.tileWidth - cameraPosition.x)
                        screenY = Math.floor(row * layer.tileHeight - cameraPosition.y)
                        @cq.drawImage(
                            tileImage,
                            thisTileImageX, thisTileImageY,
                            layer.tileWidth, layer.tileHeight,
                            screenX, screenY,
                            layer.tileWidth, layer.tileHeight
                        )


class DialogRenderingSystem
    constructor: (@cq) ->
    update: (delta, entityManager, assetManager) ->
        


    draw: (delta, entityManager, assetManager) ->
        result = entityManager.getEntitiesWithComponents('DialogBoxComponent', 'VisibleComponent')
        if result.length > 0
            dialogBox = result[0]
            dialogBoxText = entityManager.getComponent(dialogBox, 'DialogBoxTextComponent')

            @cq.font('16px "Press Start 2P"').textBaseline('top').fillStyle('black')

            image = assetManager.assets['pokemon-dialog-box.png']
            @cq.drawImage(image, 0, Game.SCREEN_HEIGHT - image.height)

            for line, i in dialogBoxText.text.split('\n')
                @cq.fillText(line, 18, Game.SCREEN_HEIGHT - image.height + 22 + 20 * i)
