// Generated by CoffeeScript 1.6.3
var BattleState, BattleTransitionState, Game, GameState, PlayState, TitleScreenState, _ref, _ref1, _ref2, _ref3,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

GameState = (function() {
  function GameState() {
    var _this = this;
    this.assetManager = new AssetManager();
    this.loadAssets();
    this.assetManager.start(function() {
      _this.eventManager = new EventManager();
      _this.entityManager = new EntityManager(window.components);
      return _this.create();
    });
  }

  GameState.prototype.start = function(cq) {
    var _this = this;
    this.cq = cq;
    return this.cq.framework({
      onstep: function(delta, time) {
        return _this.step(delta, time);
      },
      onrender: function(delta, time) {
        return _this.render(delta, time);
      },
      onkeydown: function(key) {
        return _this.keyDown(key);
      },
      onkeyup: function(key) {
        return _this.keyUp(key);
      }
    });
  };

  GameState.prototype.loadAssets = function() {};

  GameState.prototype.create = function() {};

  GameState.prototype.step = function(delta, time) {};

  GameState.prototype.render = function(delta, time) {};

  GameState.prototype.keyUp = function(key) {};

  GameState.prototype.keyDown = function(key) {};

  return GameState;

})();

TitleScreenState = (function(_super) {
  __extends(TitleScreenState, _super);

  function TitleScreenState() {
    _ref = TitleScreenState.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  TitleScreenState.prototype.loadAssets = function() {
    return this.assetManager.loadImage('title-screen.png');
  };

  TitleScreenState.prototype.create = function() {};

  TitleScreenState.prototype.render = function(delta, time) {
    return this.cq.drawImage(this.assetManager.assets['title-screen.png'], 0, 0);
  };

  TitleScreenState.prototype.keyUp = function(key) {
    if (key === 'space') {
      return game.changeState(new PlayState());
    }
  };

  return TitleScreenState;

})(GameState);

PlayState = (function(_super) {
  __extends(PlayState, _super);

  function PlayState() {
    this.keyUp = __bind(this.keyUp, this);
    _ref1 = PlayState.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  PlayState.prototype.loadAssets = function() {
    this.assetManager.loadImage('pokemon-tiles.png');
    this.assetManager.loadImage('pikachu-sprites.png');
    this.assetManager.loadImage('pokemon-dialog-box.png');
    this.assetManager.loadTilemap('pokemon-level.json');
    return this.assetManager.loadAudio('audiotest.ogg');
  };

  PlayState.prototype.create = function() {
    var camera, dialogBox, i, npc, player, _i;
    player = this.entityManager.createEntityWithComponents([
      ['PlayerComponent', {}], [
        'PixelPositionComponent', {
          x: 4 * Game.GRID_SIZE,
          y: 4 * Game.GRID_SIZE
        }
      ], [
        'GridPositionComponent', {
          col: 4,
          row: 4,
          gridSize: Game.GRID_SIZE
        }
      ], [
        'PokemonMovementComponent', {
          speed: 0.15
        }
      ], ['ActionInputComponent', {}], ['KeyboardArrowsInputComponent', {}], ['CameraFollowsComponent', {}], ['CollidableComponent', {}], ['DirectionComponent', {}], [
        'AnimationComponent', {
          currentAction: 'walk-down',
          spritesheetUrl: 'pikachu-sprites.png',
          width: 32,
          height: 32
        }
      ], [
        'AnimationActionComponent', {
          name: 'walk-down',
          row: 0,
          indices: [0, 1, 0, 2],
          frameLength: 200
        }
      ], [
        'AnimationActionComponent', {
          name: 'walk-up',
          row: 1,
          indices: [0, 1, 0, 2],
          frameLength: 200
        }
      ], [
        'AnimationActionComponent', {
          name: 'walk-left',
          row: 2,
          indices: [0, 1],
          frameLength: 200
        }
      ], [
        'AnimationActionComponent', {
          name: 'walk-right',
          row: 3,
          indices: [0, 1],
          frameLength: 200
        }
      ]
    ]);
    camera = this.entityManager.createEntityWithComponents([
      ['CameraComponent', {}], [
        'PixelPositionComponent', {
          x: 0,
          y: 0
        }
      ], [
        'GridPositionComponent', {
          col: 0,
          row: 0
        }
      ]
    ]);
    dialogBox = this.entityManager.createEntityWithComponents([
      ['DialogBoxComponent', {}], [
        'DialogBoxTextComponent', {
          text: "OAK: It's unsafe!\nWild Pokemon live\nin the tall grass!"
        }
      ], [
        'ActionInputComponent', {
          enabled: false
        }
      ], ['KeyboardArrowsInputComponent', {}]
    ]);
    this.initializeMap('pokemon-level.json');
    for (i = _i = 0; _i <= 3; i = ++_i) {
      npc = this.entityManager.createEntityWithComponents([
        [
          'PixelPositionComponent', {
            x: Math.round(Math.random() * Game.SCREEN_WIDTH / Game.GRID_SIZE) * Game.GRID_SIZE,
            y: Math.round(Math.random() * Game.SCREEN_HEIGHT / Game.GRID_SIZE) * Game.GRID_SIZE
          }
        ], [
          'GridPositionComponent', {
            col: 4,
            row: 4,
            gridSize: Game.GRID_SIZE
          }
        ], [
          'PokemonMovementComponent', {
            speed: 0.15
          }
        ], ['ActionInputComponent', {}], ['RandomArrowsInputComponent', {}], ['CollidableComponent', {}], ['DirectionComponent', {}], [
          'AnimationComponent', {
            currentAction: 'walk-down',
            spritesheetUrl: 'pikachu-sprites.png',
            width: 32,
            height: 32
          }
        ], [
          'AnimationActionComponent', {
            name: 'walk-down',
            row: 0,
            indices: [0, 1, 0, 2],
            frameLength: 200
          }
        ], [
          'AnimationActionComponent', {
            name: 'walk-up',
            row: 1,
            indices: [0, 1, 0, 2],
            frameLength: 200
          }
        ], [
          'AnimationActionComponent', {
            name: 'walk-left',
            row: 2,
            indices: [0, 1],
            frameLength: 200
          }
        ], [
          'AnimationActionComponent', {
            name: 'walk-right',
            row: 3,
            indices: [0, 1],
            frameLength: 200
          }
        ]
      ]);
    }
    this.tilemapRenderingSystem = new TilemapRenderingSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.canvasRenderSystem = new CanvasRenderSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.dialogRenderingSystem = new DialogRenderingSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.animatedSpriteSystem = new AnimatedSpriteSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.inputSystem = new InputSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.randomInputSystem = new RandomInputSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.movementSystem = new MovementSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.tweenSystem = new TweenSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.pokemonMovementSystem = new PokemonMovementSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.cameraFollowingSystem = new CameraFollowingSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    this.animationDirectionSyncSystem = new AnimationDirectionSyncSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
    return this.battleTriggerSystem = new BattleTriggerSystem(this.cq, this.entityManager, this.eventManager, this.assetManager);
  };

  PlayState.prototype.step = function(delta, time) {
    this.eventManager.pump();
    this.randomInputSystem.update(delta);
    this.movementSystem.update(delta);
    this.tweenSystem.update(delta);
    this.pokemonMovementSystem.update(delta);
    this.animatedSpriteSystem.update(delta);
    this.cameraFollowingSystem.update(delta);
    this.dialogRenderingSystem.update(delta);
    return this.animationDirectionSyncSystem.update(delta);
  };

  PlayState.prototype.render = function(delta, time) {
    this.cq.clear('white');
    this.tilemapRenderingSystem.draw(delta);
    this.canvasRenderSystem.draw(delta);
    this.animatedSpriteSystem.draw(delta);
    return this.dialogRenderingSystem.draw(delta);
  };

  PlayState.prototype.keyDown = function(key) {
    return this.inputSystem.updateKey(key, true);
  };

  PlayState.prototype.keyUp = function(key) {
    this.inputSystem.updateKey(key, false);
    if (key === 'space') {
      localStorage.setItem('save', this.entityManager.save());
    }
    if (key === 'escape') {
      return this.entityManager.load(localStorage.getItem('save'));
    }
  };

  PlayState.prototype.initializeMap = function(dataUrl) {
    var i, layer, mapData, _i, _len, _ref2, _results;
    mapData = this.assetManager.assets['pokemon-level.json'];
    _ref2 = mapData.layers;
    _results = [];
    for (i = _i = 0, _len = _ref2.length; _i < _len; i = ++_i) {
      layer = _ref2[i];
      if (i === 3 || i === 5) {
        continue;
      }
      if (layer.properties.layertype === 'visible') {
        _results.push(layer = this.entityManager.createEntityWithComponents([
          [
            'TilemapVisibleLayerComponent', {
              tileData: layer,
              tileImageUrl: 'pokemon-tiles.png',
              tileWidth: mapData.tilewidth,
              tileHeight: mapData.tileheight,
              zIndex: i
            }
          ]
        ]));
      } else {
        _results.push(layer = this.entityManager.createEntityWithComponents([
          [
            'TilemapCollisionLayerComponent', {
              tileData: layer
            }
          ]
        ]));
      }
    }
    return _results;
  };

  return PlayState;

})(GameState);

BattleTransitionState = (function(_super) {
  __extends(BattleTransitionState, _super);

  function BattleTransitionState() {
    _ref2 = BattleTransitionState.__super__.constructor.apply(this, arguments);
    return _ref2;
  }

  BattleTransitionState.prototype.create = function(previousScreen) {
    var c;
    this.previousScreen = previousScreen;
    this.wipeX = 0;
    c = document.createElement("canvas");
    return this.hiddenCtx = c.getContext("2d");
  };

  BattleTransitionState.prototype.step = function(delta, time) {
    this.wipeY += 1 * delta;
    if (this.wipeY > Game.SCREEN_HEIGHT) {
      return game.state = new BattleState();
    }
  };

  BattleTransitionState.prototype.render = function(delta, time) {
    this.cq.drawImage(this.previousScreen, 0, 0);
    return this.cq.fillRect(0, 0, Game.SCREEN_WIDTH, this.wipeY);
  };

  return BattleTransitionState;

})(GameState);

BattleState = (function(_super) {
  __extends(BattleState, _super);

  function BattleState() {
    this.keyUp = __bind(this.keyUp, this);
    _ref3 = BattleState.__super__.constructor.apply(this, arguments);
    return _ref3;
  }

  BattleState.prototype.loadAssets = function() {
    this.assetManager.loadImage('pokemon-tiles.png');
    this.assetManager.loadImage('pikachu-sprites.png');
    this.assetManager.loadImage('pokemon-dialog-box.png');
    return this.assetManager.loadTilemap('pokemon-level.json');
  };

  BattleState.prototype.create = function() {};

  BattleState.prototype.step = function(delta, time) {};

  BattleState.prototype.render = function(delta, time) {};

  BattleState.prototype.keyDown = function(key) {
    return this.inputSystem.updateKey(key, true);
  };

  BattleState.prototype.keyUp = function(key) {
    this.inputSystem.updateKey(key, false);
    if (key === 'space') {
      localStorage.setItem('save', this.entityManager.save());
    }
    if (key === 'escape') {
      return this.entityManager.load(localStorage.getItem('save'));
    }
  };

  BattleState.prototype.initializeMap = function(dataUrl) {
    var i, layer, mapData, _i, _len, _ref4, _results;
    mapData = this.assetManager.assets['pokemon-level.json'];
    _ref4 = mapData.layers;
    _results = [];
    for (i = _i = 0, _len = _ref4.length; _i < _len; i = ++_i) {
      layer = _ref4[i];
      if (i === 3 || i === 5) {
        continue;
      }
      if (layer.properties.layertype === 'visible') {
        _results.push(layer = this.entityManager.createEntityWithComponents([
          [
            'TilemapVisibleLayerComponent', {
              tileData: layer,
              tileImageUrl: 'pokemon-tiles.png',
              tileWidth: mapData.tilewidth,
              tileHeight: mapData.tileheight,
              zIndex: i
            }
          ]
        ]));
      } else {
        _results.push(layer = this.entityManager.createEntityWithComponents([
          [
            'TilemapCollisionLayerComponent', {
              tileData: layer
            }
          ]
        ]));
      }
    }
    return _results;
  };

  return BattleState;

})(GameState);

Game = (function() {
  Game.SCREEN_WIDTH = 320;

  Game.SCREEN_HEIGHT = 288;

  Game.GRID_SIZE = 32;

  Game.states = [];

  function Game() {
    this.cq = cq(Game.SCREEN_WIDTH, Game.SCREEN_HEIGHT).appendTo('.gameboy');
    this.states.push(new TitleScreenState());
  }

  Game.prototype.pushState = function(state) {
    return this.states.push(state);
  };

  Game.prototype.popState = function() {
    return this.states.pop();
  };

  return Game;

})();

window.game = new Game();
