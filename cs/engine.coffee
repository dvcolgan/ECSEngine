Number.prototype.clamp = (min, max) -> Math.min(Math.max(@, min), max)

genUUID = ->
    `'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0,v=c=='x'?r:r&0x3|0x8;return v.toString(16);
    });`

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
            
    getSingletonEntityWithComponent: (componentName) ->
        entities = @getEntitiesWithComponent(componentName)
        if entities.length == 0
            return null
        else if entities.length > 1
            throw 'Multiple instances of singleton component!'
        else
            return entities[0]

    createEntityWithComponents: (components) ->
        entity = @createEntity()
        for [componentName, args] in components
            @addComponent(entity, componentName, args)
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
            return []
        store = @componentStores[componentName]

        components = store[entity]
        if components
            return components
        else
            return []

    entityHasComponent: (entity, componentName) ->
        not not @getComponent(entity, componentName)

    # This could be optimized later if needed, currently it is just a method mashup.
    iterateEntitiesWithComponents: (componentNames) ->
        results = []
        for entity in @getEntitiesWithComponents(componentNames)
            result = [entity]
            for componentName in componentNames
                result.push(@getComponent(entity, componentName))
            results.push(result)
        return results

    save: ->
        return JSON.stringify(@componentStores)

    load: (jsonString) ->
        @componentStores = JSON.parse(jsonString)
