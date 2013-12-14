Number.prototype.clamp = (min, max) -> Math.min(Math.max(@, min), max)

genUUID = ->
    `'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0,v=c=='x'?r:r&0x3|0x8;return v.toString(16);
    });`


class EventManager
    constructor: ->
        @queue = []
        @listeners = {}
        @oneTimeListeners = {}

    _addEvent: (eventName, entity, callback, listeners) ->
        if entity not of listeners
            listeners[entity] = {}

        if eventName not of listeners[entity]
            listeners[entity][eventName] = []

        listeners[entity][eventName].push(callback)

    subscribeOnce: (eventName, entity, callback) ->
        @_addEvent(eventName, entity, callback, @oneTimeListeners)

    subscribe: (eventName, entity, callback) ->
        @_addEvent(eventName, entity, callback, @listeners)

    trigger: (eventName, entity, data) ->
        @queue.push([eventName, entity, data])

    pump: ->
        while yes and yes or yes
            currentQueue = @queue
            @queue = []
            for [eventName, entity, data] in currentQueue
                if entity of @listeners
                    if eventName of @listeners[entity]
                        for callback in @listeners[entity][eventName]
                            callback(entity, data)
                if entity of @oneTimeListeners
                    if eventName of @oneTimeListeners[entity]
                        for callback in @oneTimeListeners[entity][eventName]
                            list = @oneTimeListeners[entity][eventName]
                            callback(entity, data)
                        @oneTimeListeners[entity][eventName] = []
            if @queue.length == 0 then break



class EntityManager
    constructor: (@components) ->
        @id = genUUID()
        @componentStores = {}
   
    createEntity: ->
        return genUUID()

    addComponent: (entity, componentName, args) ->
        # Make sure we have a store for this component
        if componentName not of @componentStores
            @componentStores[componentName] = {}
        store = @componentStores[componentName]

        # Clone the component
        component = JSON.parse(JSON.stringify(@components[componentName]))

        # Fill in initial values
        for key, value of args
            if key not of component
                console.log 'unknown component variable: ' + key
            component[key] = value
        component._name = componentName

        # Add it to the store
        if entity of store
            store[entity].push(component)
        else
            store[entity] = [component]

        return component

    removeComponent: (entity, component) ->
        if component._name not of @componentStores
            return null
        store = @componentStores[component._name]
        components = store[entity]
        idx = components.indexOf(component)
        if idx > -1
            component = components.splice(idx, 1)
            if components.length == 0
                delete store[entity]
            return component
        return null

    createEntityWithComponents: (components) ->
        entity = @createEntity()
        for [componentName, args] in components
            @addComponent(entity, componentName, args)
        return entity

    getEntitiesHavingComponent: (componentName) ->
        if componentName of @componentStores
            return Object.keys(@componentStores[componentName])
        else
            return []

    getEntitiesHavingComponents: (componentNames) ->
        allEntities = {}
        numComponents = componentNames.length
        for componentName in componentNames
            for entity in @getEntitiesHavingComponent(componentName)
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
            return []
        store = @componentStores[componentName]

        components = store[entity]
        if components
            return components
        else
            return []

    entityHasComponent: (entity, componentName) ->
        not not @getComponent(entity, componentName)

    # Main selector methods

    # This could be optimized later if needed, currently it is just a method mashup.
    iterateEntitiesAndComponents: (componentNames) ->
        results = []
        for entity in @getEntitiesHavingComponents(componentNames)
            result = [entity]
            for componentName in componentNames
                result.push(@getComponent(entity, componentName))
            results.push(result)
        return results
            
    getFirstEntityAndComponents: (componentNames) ->
        entities = @getEntitiesHavingComponents(componentNames)
        if entities.length > 0
            entity = entities[0]
            result = [entity]
            for componentName in componentNames
                result.push(@getComponent(entity, componentName))
            return result
        else
            return []

    save: ->
        return JSON.stringify(@componentStores)

    load: (jsonString) ->
        @componentStores = JSON.parse(jsonString)
