##############
### ENGINE ###
##############

genUUID = ->
    `'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0,v=c=='x'?r:r&0x3|0x8;return v.toString(16);
    });`

class EntityManager
    constructor: ->
        @id = genUUID()
        @componentStores = {}
   
    createEntity: ->
        return genUUID()

    addComponent: (entity, component) ->
        if component.name not of @componentStores
            @componentStores[component.name] = {}
        store = @componentStores[component.name]

        if entity of store
            if component not in store[entity]
                store[entity].push(component)
        else
            store[entity] = [component]

    createEntityWithComponents: (components) ->
        entity = @createEntity()
        for component in components
            @addComponent(entity, component)
        return entity

    hasComponent: (entity, componentName) ->
        if componentName not of @componentStores
            return false
        else
            store = @componentStores[componentName]
            return entity of store and store[entity].length > 0

    getEntitiesWithComponent: (componentName) ->
        if componentName of @componentStores
            return Object.keys(@componentStores[componentName])
        else
            return []

    getEntitiesWithComponents: (componentNames) ->
        allEntities = {}
        numComponents = componentNames.length
        for componentName in componentNames
            for entity in @getEntitiesWithComponent(componentName)
                if entity of allEntities
                    allEntities[entity]++
                else
                    allEntities[entity] = 1
        result = []
        for entity, count of allEntities
            if count == numComponents
                result.push(entity)

        return result

    getComponent: (entity, componentName) ->
        if componentName not of @componentStores
            return null
        store = @componentStores[componentName]

        components = store[entity]
        if components and components.length > 0
            return components[0]
        else
            return null

    getComponents: (entity, componentName) ->
        if componentName not of @componentStores
            return null
        store = @componentStores[componentName]

        components = store[entity]
        if components
            return components
        else
            return []

    save: ->
        return JSON.stringify(@componentStores)

    load: (jsonString) ->
        @componentStores = JSON.parse(jsonString)



class Component
    constructor: (@name) ->
        @id = genUUID()


class System
    update: (delta, entityManager) ->
        throw 'Update must be implemented.'


##################
### COMPONENTS ###
##################

class PositionComponent extends Component
    constructor: (@x, @row) ->
        super('PositionComponent')


class RotationComponent extends Component
    constructor: (@angle) ->
        super('RotationComponent')

class FroggerMovementComponent extends Component

class HorizontalMovementComponent extends Component
    constructor: (@direction) ->
        super('HorizontalMovementComponent')


class ColorComponent extends Component
    constructor: (@color) ->
        super('ColorComponent')

class VelocityComponent extends Component
    constructor: (@maxSpeed) ->
        @dx = @dy = 0
        super('VelocityComponent')

class ShapeRendererComponent extends Component
    constructor: (@width, @height, @type) ->
        super('ShapeRendererComponent')

class ArrowKeyInputComponent extends Component
    constructor: ->
        @left = @right = @up = @down = off
        super('ArrowKeyInputComponent')


###############
### SYSTEMS ###
###############



class CanvasRenderSystem extends System
    constructor: (@cq) ->

    update: (delta, entityManager) ->
        entities = entityManager.getEntitiesWithComponents(['PositionComponent', 'ColorComponent', 'ShapeRendererComponent'])
        for entity in entities
            position = entityManager.getComponent(entity, 'PositionComponent')
            shape = entityManager.getComponent(entity, 'ShapeRendererComponent')
            color = entityManager.getComponent(entity, 'ColorComponent')

            @cq.fillStyle(color.color)
            switch shape.type
                when 'rectangle'
                    @cq.fillRect(position.x, position.row * Game.GRID_SIZE, shape.width, shape.height)
                else
                    throw 'NotImplementedException'


class InputSystem
    updateKey: (key, value, entityManager) ->
        entities = entityManager.getEntitiesWithComponent('ArrowKeyInputComponent')
        for entity in entities
            arrows = entityManager.getComponent(entity, 'ArrowKeyInputComponent')
            switch key
                when 'left'
                    arrows.left = value
                when 'right'
                    arrows.right = value
                when 'up'
                    arrows.up = value
                when 'down'
                    arrows.down = value


class MovementSystem
    update: (delta, entityManager) ->

        #for [entity, position, movement, arrows] in entityManager.iterateOverEntitiesWith(['PositionComponent', 'MovementComponent', 'ArrowKeyInputComponent'])

        entities = entityManager.getEntitiesWithComponents(['PositionComponent', 'VelocityComponent', 'ArrowKeyInputComponent'])
        for entity in entities
            position = entityManager.getComponent(entity, 'PositionComponent')
            velocity = entityManager.getComponent(entity, 'VelocityComponent')
            arrows = entityManager.getComponent(entity, 'ArrowKeyInputComponent')

            velocity.dx = velocity.dy = 0
            if arrows.left then velocity.dx -= velocity.maxSpeed * delta
            if arrows.right then velocity.dx += velocity.maxSpeed * delta
            if arrows.up then velocity.dy -= velocity.maxSpeed * delta
            if arrows.down then velocity.dy += velocity.maxSpeed * delta

            position.x += velocity.dx
            position.y += velocity.dy
            


class Game
    @SCREEN_WIDTH: 640
    @SCREEN_HEIGHT: 480
    @GRID_SIZE: 32
    @ROW_COUNT: 13

    constructor: ->
        @entityManager = new EntityManager()
        @cq = cq(Game.SCREEN_WIDTH, Game.SCREEN_HEIGHT).appendTo('body')

        background = @entityManager.createEntity()
        @entityManager.addComponent(background, new PositionComponent(0, 0))
        @entityManager.addComponent(background, new ColorComponent('#8BB54A'))
        @entityManager.addComponent(background, new ShapeRendererComponent(Game.SCREEN_WIDTH, Game.SCREEN_HEIGHT, 'rectangle'))

        player = @entityManager.createEntityWithComponents([
            new PositionComponent(Game.SCREEN_WIDTH / 2, Game.ROW_COUNT-1)
            new ShapeRendererComponent(Game.GRID_SIZE, Game.GRID_SIZE, 'rectangle')
            new ColorComponent('#33ff33')
            new VelocityComponent(0.4)
            new ArrowKeyInputComponent()
        ])


        @canvasRenderSystem = new CanvasRenderSystem(@cq)
        @inputSystem = new InputSystem()
        @movementSystem = new MovementSystem()

        @cq.framework
            onstep: (delta, time) =>
                @movementSystem.update(delta, @entityManager)

            onrender: (delta, time) =>
                @canvasRenderSystem.update(delta, @entityManager)
                
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


window.game = new Game()

"""
Behaviors:
    Move the car up/left/right/down
    Move dinosaurs horizontally across the screen
    The player dies when hit
    Collision between car and dinosaur
    Fuel meter that goes down when you drive, you explode if you run out
    The player wins when reaching a tunnel at the top



Components
    Cell Position:
        col: int
        row: int

    Screen Position:
        x: int
        y: int

    Color:
        color: string

    Rotation:
        angle: float

    Fuel Level:
        amount: int
        capacity: int

    ShapeRenderer:
        width: int
        height: int
        shape: enum{Rectangle, Triangle, Ellipse}

    Exit:
        col: int
        row: int

Entities:
    player
    dinosaurs


"""

