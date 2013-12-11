window.components =
    PlayerComponent: {}

    PixelPositionComponent:
        x: 0
        y: 0

    RotationComponent:
        angle: 0

    DirectionComponent:
        direction: 'down' #or 'left', 'right', 'up'

    GridPositionComponent:
        col: 0
        row: 0
        gridSize: 32

    ColorComponent:
        color: 'black'

    VelocityComponent:
        maxSpeed: 4
        dx: 0
        dy: 0

    ShapeRendererComponent:
        width: 32
        height: 32
        type: 'rectangle'

    ActionInputComponent:
        left: off
        right: off
        up: off
        down: off
        action: off
        enabled: yes

    RandomArrowsInputComponent: {}

    KeyboardArrowsInputComponent: {}

    PokemonMovementComponent:
        speed: 0.2

    CollidableComponent: {}

    IsPokemonMovingComponent:
        dx: 0
        dy: 0
        destCol: 0
        destRow: 0

    ExitComponent: {}

    CameraComponent: {}

    CameraFollowsComponent: {}

    TweenComponent:
        speed: 0
        start: 0
        current: null
        dest: 0
        component: null
        attr: ''
        easingFn: null

    TilemapVisibleLayerComponent:
        tileData: null
        tileImageUrl: ''
        tileWidth: 32
        tileHeight: 32
        zIndex: 0

    TilemapCollisionLayerComponent:
        tileData: null

    TilemapOutdoorCollisionComponent: {}

    TilemapIndoorCollisionComponent: {}

    DialogBoxComponent:
        visible: false
        talkee: null

    DialogBoxTextComponent:
        text: ''

