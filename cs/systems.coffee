class PokemonMovementSystem
    update: (delta, entityManager, assetManager) ->
        for [entity, movement, direction, input, gridPosition, pixelPosition] in entityManager.iterateEntitiesAndComponents(['PokemonMovementComponent', 'DirectionComponent', 'ActionInputComponent', 'GridPositionComponent', 'PixelPositionComponent'])
            if not input.enabled then continue

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
                if input.left then dx -= 1
                if input.right then dx += 1
                if dx == 0
                    if input.up then dy -= 1
                    if input.down then dy += 1
                if dx > 0 or dx < 0 or dy > 0 or dy < 0
                    if dx < 0 then direction.direction = 'left'
                    if dx > 0 then direction.direction = 'right'
                    if dy < 0 then direction.direction = 'up'
                    if dy > 0 then direction.direction = 'down'

                    for [_, collisionLayer] in entityManager.iterateEntitiesAndComponents(['TilemapCollisionLayerComponent'])
                        tileIdx = (gridPosition.row+dy) * collisionLayer.tileData.width + (gridPosition.col+dx)
                        nextTile = collisionLayer.tileData.data[tileIdx]
                        if nextTile == 0
                            canMove = true
                            for [_, otherGridPosition, _] in entityManager.iterateEntitiesAndComponents(['GridPositionComponent', 'CollidableComponent'])
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
        for [entity, tween] in entityManager.iterateEntitiesAndComponents(['TweenComponent'])
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
        [camera, _, cameraPosition] = entityManager.getFirstEntityAndComponents(['CameraComponent', 'PixelPositionComponent'])

        for [entity, position, color, shape, direction] in entityManager.iterateEntitiesAndComponents(['PixelPositionComponent', 'ColorComponent', 'ShapeRendererComponent', 'DirectionComponent'])
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
        for [entity, _, input] in entityManager.iterateEntitiesAndComponents(['KeyboardArrowsInputComponent', 'ActionInputComponent'])
            if input.enabled or value == off
                if value == off
                    if key == 'left'  then input.left = off
                    if key == 'right' then input.right = off
                    if key == 'up'    then input.up = off
                    if key == 'down'  then input.down = off
                    if key == 'z' or key == 'semicolon' then input.action = off
                    if key == 'x' or key == 'q'     then input.cancel = off
                else
                    # TODO MAKE A COFFEESCRIPT PRECOMPILER
                    #{% for dir in ['left', 'right', 'up', 'down'] %}
                    #    if key == '{{ dir }}' then if input.{{ dir }} == 'hit' then input.{{ dir }} = 'held' else input.{{ dir }} = 'hit'

                    if key == 'left'
                        if input.left  == 'hit' then input.left  = 'held' else input.left  = 'hit'
                    if key == 'right'
                        if input.right == 'hit' then input.right = 'held' else input.right = 'hit'
                    if key == 'up'
                        if input.up    == 'hit' then input.up    = 'held' else input.up    = 'hit'
                    if key == 'down'
                        if input.down  == 'hit' then input.down  = 'held' else input.down  = 'hit'

                    if key == 'z' or key == 'semicolon'
                        if input.action == 'hit' then input.action = 'held' else input.action = 'hit'
                    if key == 'x' or key == 'q'
                        if input.cancel == 'hit' then input.cancel = 'held' else input.cancel = 'hit'

# TODO make this generic for any key using a nice hash table
class RandomInputSystem
    update: (delta, entityManager, assetManager) ->
        for [entity, _, input] in entityManager.iterateEntitiesAndComponents(['RandomArrowsInputComponent', 'ActionInputComponent'])
            input.left = input.right = input.up = input.down = false
            chance = 0.002
            if Math.random() < chance
                if input.left   == 'hit' then input.left   = 'held' else input.left   = 'hit'
            if Math.random() < chance
                if input.right  == 'hit' then input.right  = 'held' else input.right  = 'hit'
            if Math.random() < chance
                if input.up     == 'hit' then input.up     = 'held' else input.up     = 'hit'
            if Math.random() < chance
                if input.down   == 'hit' then input.down   = 'held' else input.down   = 'hit'
            if Math.random() < chance
                if input.action == 'hit' then input.action = 'held' else input.action = 'hit'
                


class MovementSystem
    update: (delta, entityManager, assetManager) ->
        for [entity, position, velocity, input] in entityManager.iterateEntitiesAndComponents(['PixelPositionComponent', 'VelocityComponent', 'ArrowKeyInputComponent'])
            velocity.dx = velocity.dy = 0
            if input.left then velocity.dx -= velocity.maxSpeed * delta
            if input.right then velocity.dx += velocity.maxSpeed * delta
            if input.up then velocity.dy -= velocity.maxSpeed * delta
            if input.down then velocity.dy += velocity.maxSpeed * delta

            position.x += velocity.dx
            position.y += velocity.dy


class CameraFollowingSystem
    update: (delta, entityManager, assetManager) ->
        [camera, _, cameraPosition] = entityManager.getFirstEntityAndComponents(['CameraComponent', 'PixelPositionComponent'])
        [followee, _, followeePosition] = entityManager.getFirstEntityAndComponents(['CameraFollowsComponent', 'PixelPositionComponent'])

        #[mapLayer, mapLayerComponent] = entityManager.getFirstEntityAndComponents(['TilemapVisibleLayerComponent'])

        #mapWidth = mapLayerComponent.tileWidth * mapLayerComponent.tileData.width
        #mapHeight = mapLayerComponent.tileHeight * mapLayerComponent.tileData.height

        cameraPosition.x = followeePosition.x - (Game.SCREEN_WIDTH / 2 - 32)
        cameraPosition.y = followeePosition.y - (Game.SCREEN_HEIGHT / 2 - 16)
        #cameraPosition.x = cameraPosition.x.clamp(0, mapWidth - Game.SCREEN_WIDTH)
        #cameraPosition.y = cameraPosition.y.clamp(0, mapHeight - Game.SCREEN_HEIGHT)


class TilemapRenderingSystem
    constructor: (@cq) ->

    draw: (delta, entityManager, assetManager) ->
        [camera, _, cameraPosition] = entityManager.getFirstEntityAndComponents(['CameraComponent', 'PixelPositionComponent'])

        entities = entityManager.getEntitiesHavingComponent('TilemapVisibleLayerComponent')
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
        [playerEntity, _, playerGridPosition, playerDirection, playerInput] = entityManager.getFirstEntityAndComponents(['PlayerComponent', 'GridPositionComponent', 'DirectionComponent', 'ActionInputComponent'])
        if playerInput.enabled
            if playerInput.action == 'hit'
                for [otherEntity, otherDirection, otherGridPosition, ] in entityManager.iterateEntitiesAndComponents(['DirectionComponent', 'GridPositionComponent'])
                    dx = if playerDirection.direction == 'left' then -1 else if playerDirection.direction == 'right' then 1 else 0
                    dy = if playerDirection.direction ==   'up' then -1 else if playerDirection.direction ==  'down' then 1 else 0
                    if otherGridPosition.col == playerGridPosition.col + dx and otherGridPosition.row == playerGridPosition.row + dy

                        # Found the other person we are talking to
                        if playerDirection.direction == 'left' then otherDirection.direction = 'right'
                        if playerDirection.direction == 'right' then otherDirection.direction = 'left'
                        if playerDirection.direction == 'up' then otherDirection.direction = 'down'
                        if playerDirection.direction == 'down' then otherDirection.direction = 'up'

                        playerInput.enabled = no
                        otherInput = entityManager.getComponent(otherEntity, 'ActionInputComponent')
                        if otherInput then otherInput.enabled = no

                        [dialogBoxEntity, dialogBox, dialogInput] = entityManager.getFirstEntityAndComponents(['DialogBoxComponent', 'ActionInputComponent'])
                        dialogBox.visible = true
                        dialogBox.talkee = otherEntity
                        dialogInput.enabled = yes
                        break
        else
            [dialogBoxEntity, dialogBox, dialogBoxText, dialogInput] = entityManager.getFirstEntityAndComponents(['DialogBoxComponent', 'DialogBoxTextComponent', 'ActionInputComponent'])
            if dialogInput.action == 'hit'
                dialogInput.enabled = no
                dialogBox.visible = false
                [playerEntity, _, playerInput] = entityManager.getFirstEntityAndComponents(['PlayerComponent', 'ActionInputComponent'])
                playerInput.enabled = yes
                talkeeInput = entityManager.getComponent(dialogBox.talkee, 'ActionInputComponent')
                if talkeeInput then talkeeInput.enabled = yes

            

    draw: (delta, entityManager, assetManager) ->
        [_, dialogBox, dialogBoxText] = entityManager.getFirstEntityAndComponents(['DialogBoxComponent', 'DialogBoxTextComponent'])
        
        if dialogBox.visible
            @cq.font('16px "Press Start 2P"').textBaseline('top').fillStyle('black')

            image = assetManager.assets['pokemon-dialog-box.png']
            @cq.drawImage(image, 0, Game.SCREEN_HEIGHT - image.height)

            for line, i in dialogBoxText.text.split('\n')
                @cq.fillText(line, 18, Game.SCREEN_HEIGHT - image.height + 22 + 20 * i)


class AnimationDirectionSyncSystem
    update: (delta, entityManager, assetManager) ->
        for [animationEntity, animation, direction] in entityManager.iterateEntitiesAndComponents(['AnimationComponent', 'DirectionComponent'])
            animation.currentAction = 'walk-' + direction.direction

class AnimatedSpriteSystem
    constructor: (@cq) ->

    update: (delta, entityManager, assetManager) ->
        for [animationEntity, animation] in entityManager.iterateEntitiesAndComponents(['AnimationComponent'])
            actions = entityManager.getComponents(animationEntity, 'AnimationActionComponent')
            for action in actions
                if action.name == animation.currentAction
                    action.frameElapsedTime += delta
                    if action.frameElapsedTime > action.frameLength
                        action.frameElapsedTime = 0
                        action.currentFrame++
                        if action.currentFrame >= action.indices.length
                            action.currentFrame = 0
                    break

    draw: (delta, entityManager, assetManager) ->
        [camera, _, cameraPosition] = entityManager.getFirstEntityAndComponents(['CameraComponent', 'PixelPositionComponent'])

        for [animationEntity, animation, animationPosition] in entityManager.iterateEntitiesAndComponents(['AnimationComponent', 'PixelPositionComponent'])

            actions = entityManager.getComponents(animationEntity, 'AnimationActionComponent')
            for action in actions
                if action.name == animation.currentAction

                    imageX = action.indices[action.currentFrame] * animation.width
                    imageY = action.row * animation.height

                    screenX = Math.floor(animationPosition.x - cameraPosition.x)
                    screenY = Math.floor(animationPosition.y - cameraPosition.y)
                    @cq.drawImage(
                        assetManager.assets[animation.spritesheetUrl],
                        imageX, imageY,
                        animation.width, animation.height,
                        screenX, screenY,
                        animation.width, animation.height
                    )
                    break
