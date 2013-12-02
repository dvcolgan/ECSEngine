
class MovementSystem
    update: (delta, entityManager) ->

        #for [entity, position, movement, arrows] in entityManager.iterateOverEntitiesWith(['PositionComponent', 'MovementComponent', 'ArrowKeyInputComponent'])

        entities = entityManager.getEntitiesWithComponents(['PositionComponent', 'VelocityComponent', 'ArrowKeyInputComponent'])
        for entity in entities
            position = entityManager.getComponent(entity, 'PositionComponent')
            velocity = entityManager.getComponent(entity, 'VelocityComponent')
            arrows = entityManager.getComponent(entity, 'ArrowKeyInputComponent')
            console.log arrows.up

            velocity.dx = velocity.dy = 0
            if arrows.left then velocity.dx -= velocity.maxSpeed * delta
            if arrows.right then velocity.dx += velocity.maxSpeed * delta
            if arrows.up then velocity.dy -= velocity.maxSpeed * delta
            if arrows.down then velocity.dy += velocity.maxSpeed * delta

            position.x += velocity.dx
            position.y += velocity.dy
