// Generated by CoffeeScript 1.6.3
var AnimatedSpriteSystem, AnimationDirectionSyncSystem, BattleTriggerSystem, CameraFollowingSystem, CanvasRenderSystem, DialogRenderingSystem, InputSystem, MovementSystem, PokemonMovementSystem, RandomInputSystem, System, TilemapRenderingSystem, TweenSystem, _ref, _ref1, _ref10, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

System = (function() {
  function System(cq, entityManager, eventManager, assetManager) {
    this.cq = cq;
    this.entityManager = entityManager;
    this.eventManager = eventManager;
    this.assetManager = assetManager;
  }

  return System;

})();

PokemonMovementSystem = (function(_super) {
  __extends(PokemonMovementSystem, _super);

  function PokemonMovementSystem() {
    _ref = PokemonMovementSystem.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  PokemonMovementSystem.prototype.update = function(delta) {
    var canMove, collisionLayer, direction, dx, dy, entity, gridPosition, input, movement, moving, newCol, newRow, nextTile, otherGridPosition, pixelPosition, tileIdx, tween, tweens, _, _i, _j, _len, _len1, _ref1, _ref2, _results;
    _ref1 = this.entityManager.iterateEntitiesAndComponents(['PokemonMovementComponent', 'DirectionComponent', 'ActionInputComponent', 'GridPositionComponent', 'PixelPositionComponent']);
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      _ref2 = _ref1[_i], entity = _ref2[0], movement = _ref2[1], direction = _ref2[2], input = _ref2[3], gridPosition = _ref2[4], pixelPosition = _ref2[5];
      if (!input.enabled) {
        continue;
      }
      tweens = this.entityManager.getComponents(entity, 'TweenComponent');
      moving = false;
      for (_j = 0, _len1 = tweens.length; _j < _len1; _j++) {
        tween = tweens[_j];
        if (tween.component === pixelPosition) {
          moving = true;
          break;
        }
      }
      if (!moving) {
        newCol = Math.round(pixelPosition.x / gridPosition.gridSize);
        newRow = Math.round(pixelPosition.y / gridPosition.gridSize);
        if (newCol !== gridPosition.col || newRow !== gridPosition.row) {
          gridPosition.col = newCol;
          gridPosition.row = newRow;
          gridPosition.justEntered = true;
        } else {
          gridPosition.justEntered = false;
        }
        dx = dy = 0;
        if (input.left) {
          dx -= 1;
        }
        if (input.right) {
          dx += 1;
        }
        if (dx === 0) {
          if (input.up) {
            dy -= 1;
          }
          if (input.down) {
            dy += 1;
          }
        }
        if (dx !== 0 || dy !== 0) {
          if (dx < 0) {
            direction.direction = 'left';
          }
          if (dx > 0) {
            direction.direction = 'right';
          }
          if (dy < 0) {
            direction.direction = 'up';
          }
          if (dy > 0) {
            direction.direction = 'down';
          }
          _results.push((function() {
            var _k, _l, _len2, _len3, _ref3, _ref4, _ref5, _ref6, _results1,
              _this = this;
            _ref3 = this.entityManager.iterateEntitiesAndComponents(['TilemapCollisionLayerComponent']);
            _results1 = [];
            for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
              _ref4 = _ref3[_k], _ = _ref4[0], collisionLayer = _ref4[1];
              tileIdx = (gridPosition.row + dy) * collisionLayer.tileData.width + (gridPosition.col + dx);
              nextTile = collisionLayer.tileData.data[tileIdx];
              if (nextTile === 0) {
                canMove = true;
                _ref5 = this.entityManager.iterateEntitiesAndComponents(['GridPositionComponent', 'CollidableComponent']);
                for (_l = 0, _len3 = _ref5.length; _l < _len3; _l++) {
                  _ref6 = _ref5[_l], _ = _ref6[0], otherGridPosition = _ref6[1], _ = _ref6[2];
                  if ((gridPosition.col + dx) === otherGridPosition.col && (gridPosition.row + dy) === otherGridPosition.row) {
                    canMove = false;
                  }
                }
                if (canMove) {
                  if (dx > 0 || dx < 0) {
                    this.entityManager.addComponent(entity, 'TweenComponent', {
                      speed: movement.speed,
                      start: pixelPosition.x,
                      dest: pixelPosition.x + gridPosition.gridSize * dx,
                      component: pixelPosition,
                      attr: 'x',
                      easingFn: 'linear'
                    });
                  }
                  if (dy > 0 || dy < 0) {
                    this.entityManager.addComponent(entity, 'TweenComponent', {
                      speed: movement.speed,
                      start: pixelPosition.y,
                      dest: pixelPosition.y + gridPosition.gridSize * dy,
                      component: pixelPosition,
                      attr: 'y',
                      easingFn: 'linear'
                    });
                  }
                  _results1.push((function(entity) {
                    return _this.eventManager.subscribeOnce('tween-end', entity, function() {
                      return _this.eventManager.trigger('movement-enter-square', entity, {
                        col: gridPosition.col,
                        row: gridPosition.row
                      });
                    });
                  })(entity));
                } else {
                  _results1.push(void 0);
                }
              } else {
                _results1.push(void 0);
              }
            }
            return _results1;
          }).call(this));
        } else {
          _results.push(void 0);
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return PokemonMovementSystem;

})(System);

TweenSystem = (function(_super) {
  __extends(TweenSystem, _super);

  function TweenSystem() {
    _ref1 = TweenSystem.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  TweenSystem.prototype.update = function(delta) {
    var b, c, dir, entity, t, tween, _i, _len, _ref2, _ref3, _results;
    _ref2 = this.entityManager.iterateEntitiesAndComponents(['TweenComponent']);
    _results = [];
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      _ref3 = _ref2[_i], entity = _ref3[0], tween = _ref3[1];
      if (tween.start === tween.dest) {
        this.entityManager.removeComponent(entity, tween);
      }
      if (tween.current === null) {
        tween.current = tween.start;
      }
      dir = tween.start < tween.dest ? 1 : -1;
      if (tween.easingFn === 'linear') {
        tween.current += delta * tween.speed * dir;
      } else if (tween.easingFn === 'ease-out-bounce') {
        t = Math.abs(tween.current / tween.dest);
        c = delta * tween.speed * dir;
        b = tween.start;
        if (t < (1 / 2.75)) {
          tween.current = c * (7.5625 * t * t) + b;
        } else if (t < (2 / 2.75)) {
          tween.current = c * (7.5625 * (t -= 1.5 / 2.75) * t + .75) + b;
        } else if (t < (2.5 / 2.75)) {
          tween.current = c * (7.5625 * (t -= 2.25 / 2.75) * t + .9375) + b;
        } else {
          tween.current = c * (7.5625 * (t -= 2.625 / 2.75) * t + .984375) + b;
        }
      }
      tween.component[tween.attr] = tween.current;
      if ((tween.start < tween.dest && tween.current > tween.dest) || (tween.start >= tween.dest && tween.current < tween.dest)) {
        tween.component[tween.attr] = tween.dest;
        this.entityManager.removeComponent(entity, tween);
        _results.push(this.eventManager.trigger('tween-end', entity, {}));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return TweenSystem;

})(System);

CanvasRenderSystem = (function(_super) {
  __extends(CanvasRenderSystem, _super);

  function CanvasRenderSystem() {
    _ref2 = CanvasRenderSystem.__super__.constructor.apply(this, arguments);
    return _ref2;
  }

  CanvasRenderSystem.prototype.draw = function(delta) {
    var camera, cameraPosition, color, direction, entity, fromX, fromY, position, shape, toX, toY, _, _i, _len, _ref3, _ref4, _ref5, _results;
    _ref3 = this.entityManager.getFirstEntityAndComponents(['CameraComponent', 'PixelPositionComponent']), camera = _ref3[0], _ = _ref3[1], cameraPosition = _ref3[2];
    _ref4 = this.entityManager.iterateEntitiesAndComponents(['PixelPositionComponent', 'ColorComponent', 'ShapeRendererComponent', 'DirectionComponent']);
    _results = [];
    for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
      _ref5 = _ref4[_i], entity = _ref5[0], position = _ref5[1], color = _ref5[2], shape = _ref5[3], direction = _ref5[4];
      this.cq.fillStyle(color.color);
      if (shape.type === 'rectangle') {
        this.cq.fillRect(position.x - cameraPosition.x, position.y - cameraPosition.y, shape.width, shape.height);
        this.cq.beginPath();
        fromX = position.x + shape.width / 2;
        fromY = position.y + shape.height / 2;
        fromX -= cameraPosition.x;
        fromY -= cameraPosition.y;
        this.cq.moveTo(fromX, fromY);
        toX = fromX;
        toY = fromY;
        switch (direction.direction) {
          case 'left':
            toX -= shape.width / 2;
            break;
          case 'right':
            toX += shape.width / 2;
            break;
          case 'up':
            toY -= shape.width / 2;
            break;
          case 'down':
            toY += shape.width / 2;
        }
        this.cq.lineTo(toX, toY);
        this.cq.lineWidth = 4;
        this.cq.strokeStyle = 'black';
        this.cq.lineCap = 'round';
        _results.push(this.cq.stroke());
      } else {
        throw 'NotImplementedException';
      }
    }
    return _results;
  };

  return CanvasRenderSystem;

})(System);

InputSystem = (function(_super) {
  __extends(InputSystem, _super);

  function InputSystem() {
    _ref3 = InputSystem.__super__.constructor.apply(this, arguments);
    return _ref3;
  }

  InputSystem.prototype.updateKey = function(key, value) {
    var entity, input, _, _i, _len, _ref4, _ref5, _results;
    _ref4 = this.entityManager.iterateEntitiesAndComponents(['KeyboardArrowsInputComponent', 'ActionInputComponent']);
    _results = [];
    for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
      _ref5 = _ref4[_i], entity = _ref5[0], _ = _ref5[1], input = _ref5[2];
      if (input.enabled || value === false) {
        if (value === false) {
          if (key === 'left') {
            input.left = false;
          }
          if (key === 'right') {
            input.right = false;
          }
          if (key === 'up') {
            input.up = false;
          }
          if (key === 'down') {
            input.down = false;
          }
          if (key === 'z' || key === 'semicolon') {
            input.action = false;
          }
          if (key === 'x' || key === 'q') {
            _results.push(input.cancel = false);
          } else {
            _results.push(void 0);
          }
        } else {
          if (key === 'left') {
            if (input.left === 'hit') {
              input.left = 'held';
            } else {
              input.left = 'hit';
            }
          }
          if (key === 'right') {
            if (input.right === 'hit') {
              input.right = 'held';
            } else {
              input.right = 'hit';
            }
          }
          if (key === 'up') {
            if (input.up === 'hit') {
              input.up = 'held';
            } else {
              input.up = 'hit';
            }
          }
          if (key === 'down') {
            if (input.down === 'hit') {
              input.down = 'held';
            } else {
              input.down = 'hit';
            }
          }
          if (key === 'z' || key === 'semicolon') {
            if (input.action === 'hit') {
              input.action = 'held';
            } else {
              input.action = 'hit';
            }
          }
          if (key === 'x' || key === 'q') {
            if (input.cancel === 'hit') {
              _results.push(input.cancel = 'held');
            } else {
              _results.push(input.cancel = 'hit');
            }
          } else {
            _results.push(void 0);
          }
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return InputSystem;

})(System);

RandomInputSystem = (function(_super) {
  __extends(RandomInputSystem, _super);

  function RandomInputSystem() {
    _ref4 = RandomInputSystem.__super__.constructor.apply(this, arguments);
    return _ref4;
  }

  RandomInputSystem.prototype.update = function(delta) {
    var chance, entity, input, _, _i, _len, _ref5, _ref6, _results;
    _ref5 = this.entityManager.iterateEntitiesAndComponents(['RandomArrowsInputComponent', 'ActionInputComponent']);
    _results = [];
    for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
      _ref6 = _ref5[_i], entity = _ref6[0], _ = _ref6[1], input = _ref6[2];
      input.left = input.right = input.up = input.down = false;
      chance = 0.002;
      if (Math.random() < chance) {
        if (input.left === 'hit') {
          input.left = 'held';
        } else {
          input.left = 'hit';
        }
      }
      if (Math.random() < chance) {
        if (input.right === 'hit') {
          input.right = 'held';
        } else {
          input.right = 'hit';
        }
      }
      if (Math.random() < chance) {
        if (input.up === 'hit') {
          input.up = 'held';
        } else {
          input.up = 'hit';
        }
      }
      if (Math.random() < chance) {
        if (input.down === 'hit') {
          input.down = 'held';
        } else {
          input.down = 'hit';
        }
      }
      if (Math.random() < chance) {
        if (input.action === 'hit') {
          _results.push(input.action = 'held');
        } else {
          _results.push(input.action = 'hit');
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return RandomInputSystem;

})(System);

MovementSystem = (function(_super) {
  __extends(MovementSystem, _super);

  function MovementSystem() {
    _ref5 = MovementSystem.__super__.constructor.apply(this, arguments);
    return _ref5;
  }

  MovementSystem.prototype.update = function(delta) {
    var entity, input, position, velocity, _i, _len, _ref6, _ref7, _results;
    _ref6 = this.entityManager.iterateEntitiesAndComponents(['PixelPositionComponent', 'VelocityComponent', 'ActionInputComponent']);
    _results = [];
    for (_i = 0, _len = _ref6.length; _i < _len; _i++) {
      _ref7 = _ref6[_i], entity = _ref7[0], position = _ref7[1], velocity = _ref7[2], input = _ref7[3];
      velocity.dx = velocity.dy = 0;
      if (input.left) {
        velocity.dx -= velocity.maxSpeed * delta;
      }
      if (input.right) {
        velocity.dx += velocity.maxSpeed * delta;
      }
      if (input.up) {
        velocity.dy -= velocity.maxSpeed * delta;
      }
      if (input.down) {
        velocity.dy += velocity.maxSpeed * delta;
      }
      position.x += velocity.dx;
      _results.push(position.y += velocity.dy);
    }
    return _results;
  };

  return MovementSystem;

})(System);

CameraFollowingSystem = (function(_super) {
  __extends(CameraFollowingSystem, _super);

  function CameraFollowingSystem() {
    _ref6 = CameraFollowingSystem.__super__.constructor.apply(this, arguments);
    return _ref6;
  }

  CameraFollowingSystem.prototype.update = function(delta) {
    var camera, cameraPosition, followee, followeePosition, _, _ref7, _ref8;
    _ref7 = this.entityManager.getFirstEntityAndComponents(['CameraComponent', 'PixelPositionComponent']), camera = _ref7[0], _ = _ref7[1], cameraPosition = _ref7[2];
    _ref8 = this.entityManager.getFirstEntityAndComponents(['CameraFollowsComponent', 'PixelPositionComponent']), followee = _ref8[0], _ = _ref8[1], followeePosition = _ref8[2];
    cameraPosition.x = followeePosition.x - (Game.SCREEN_WIDTH / 2 - 32);
    return cameraPosition.y = followeePosition.y - (Game.SCREEN_HEIGHT / 2 - 16);
  };

  return CameraFollowingSystem;

})(System);

TilemapRenderingSystem = (function(_super) {
  __extends(TilemapRenderingSystem, _super);

  function TilemapRenderingSystem() {
    _ref7 = TilemapRenderingSystem.__super__.constructor.apply(this, arguments);
    return _ref7;
  }

  TilemapRenderingSystem.prototype.draw = function(delta) {
    var camera, cameraPosition, col, endCol, endRow, entities, entity, layer, layers, row, screenX, screenY, startCol, startRow, thisTile, thisTileImageX, thisTileImageY, tileIdx, tileImage, tileImageTilesHigh, tileImageTilesWide, _, _i, _j, _len, _len1, _ref8, _results;
    _ref8 = this.entityManager.getFirstEntityAndComponents(['CameraComponent', 'PixelPositionComponent']), camera = _ref8[0], _ = _ref8[1], cameraPosition = _ref8[2];
    entities = this.entityManager.getEntitiesHavingComponent('TilemapVisibleLayerComponent');
    layers = [];
    for (_i = 0, _len = entities.length; _i < _len; _i++) {
      entity = entities[_i];
      layers.push(this.entityManager.getComponent(entity, 'TilemapVisibleLayerComponent'));
    }
    layers.sort(function(a, b) {
      return a.zIndex - b.zIndex;
    });
    _results = [];
    for (_j = 0, _len1 = layers.length; _j < _len1; _j++) {
      layer = layers[_j];
      tileImage = this.assetManager.assets[layer.tileImageUrl];
      tileImageTilesWide = tileImage.width / layer.tileWidth;
      tileImageTilesHigh = tileImage.height / layer.tileHeight;
      startCol = Math.floor(cameraPosition.x / layer.tileWidth);
      startRow = Math.floor(cameraPosition.y / layer.tileHeight);
      endCol = startCol + Math.ceil(Game.SCREEN_WIDTH / layer.tileWidth);
      endRow = startRow + Math.ceil(Game.SCREEN_HEIGHT / layer.tileWidth);
      _results.push((function() {
        var _k, _results1;
        _results1 = [];
        for (row = _k = startRow; startRow <= endRow ? _k <= endRow : _k >= endRow; row = startRow <= endRow ? ++_k : --_k) {
          _results1.push((function() {
            var _l, _results2;
            _results2 = [];
            for (col = _l = startCol; startCol <= endCol ? _l <= endCol : _l >= endCol; col = startCol <= endCol ? ++_l : --_l) {
              tileIdx = row * layer.tileData.width + col;
              if (col < layer.tileData.width && col >= 0 && row < layer.tileData.height && row >= 0) {
                thisTile = layer.tileData.data[tileIdx] - 1;
                thisTileImageX = (thisTile % tileImageTilesWide) * layer.tileWidth;
                thisTileImageY = Math.floor(thisTile / tileImageTilesWide) * layer.tileHeight;
                screenX = Math.floor(col * layer.tileWidth - cameraPosition.x);
                screenY = Math.floor(row * layer.tileHeight - cameraPosition.y);
                _results2.push(this.cq.drawImage(tileImage, thisTileImageX, thisTileImageY, layer.tileWidth, layer.tileHeight, screenX, screenY, layer.tileWidth, layer.tileHeight));
              } else {
                _results2.push(void 0);
              }
            }
            return _results2;
          }).call(this));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  return TilemapRenderingSystem;

})(System);

DialogRenderingSystem = (function(_super) {
  __extends(DialogRenderingSystem, _super);

  function DialogRenderingSystem() {
    _ref8 = DialogRenderingSystem.__super__.constructor.apply(this, arguments);
    return _ref8;
  }

  DialogRenderingSystem.prototype.update = function(delta) {
    var dialogBox, dialogBoxEntity, dialogBoxText, dialogInput, dx, dy, otherDirection, otherEntity, otherGridPosition, otherInput, playerDirection, playerEntity, playerGridPosition, playerInput, talkeeInput, _, _i, _len, _ref10, _ref11, _ref12, _ref13, _ref14, _ref9, _results;
    _ref9 = this.entityManager.getFirstEntityAndComponents(['PlayerComponent', 'GridPositionComponent', 'DirectionComponent', 'ActionInputComponent']), playerEntity = _ref9[0], _ = _ref9[1], playerGridPosition = _ref9[2], playerDirection = _ref9[3], playerInput = _ref9[4];
    if (playerInput.enabled) {
      if (playerInput.action === 'hit') {
        _ref10 = this.entityManager.iterateEntitiesAndComponents(['DirectionComponent', 'GridPositionComponent']);
        _results = [];
        for (_i = 0, _len = _ref10.length; _i < _len; _i++) {
          _ref11 = _ref10[_i], otherEntity = _ref11[0], otherDirection = _ref11[1], otherGridPosition = _ref11[2];
          dx = playerDirection.direction === 'left' ? -1 : playerDirection.direction === 'right' ? 1 : 0;
          dy = playerDirection.direction === 'up' ? -1 : playerDirection.direction === 'down' ? 1 : 0;
          if (otherGridPosition.col === playerGridPosition.col + dx && otherGridPosition.row === playerGridPosition.row + dy) {
            if (playerDirection.direction === 'left') {
              otherDirection.direction = 'right';
            }
            if (playerDirection.direction === 'right') {
              otherDirection.direction = 'left';
            }
            if (playerDirection.direction === 'up') {
              otherDirection.direction = 'down';
            }
            if (playerDirection.direction === 'down') {
              otherDirection.direction = 'up';
            }
            playerInput.enabled = false;
            otherInput = this.entityManager.getComponent(otherEntity, 'ActionInputComponent');
            if (otherInput) {
              otherInput.enabled = false;
            }
            _ref12 = this.entityManager.getFirstEntityAndComponents(['DialogBoxComponent', 'ActionInputComponent']), dialogBoxEntity = _ref12[0], dialogBox = _ref12[1], dialogInput = _ref12[2];
            dialogBox.visible = true;
            dialogBox.talkee = otherEntity;
            dialogInput.enabled = true;
            this.assetManager.assets['audiotest.ogg'].play();
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    } else {
      _ref13 = this.entityManager.getFirstEntityAndComponents(['DialogBoxComponent', 'DialogBoxTextComponent', 'ActionInputComponent']), dialogBoxEntity = _ref13[0], dialogBox = _ref13[1], dialogBoxText = _ref13[2], dialogInput = _ref13[3];
      if (dialogInput.action === 'hit') {
        dialogInput.enabled = false;
        dialogBox.visible = false;
        _ref14 = this.entityManager.getFirstEntityAndComponents(['PlayerComponent', 'ActionInputComponent']), playerEntity = _ref14[0], _ = _ref14[1], playerInput = _ref14[2];
        playerInput.enabled = true;
        talkeeInput = this.entityManager.getComponent(dialogBox.talkee, 'ActionInputComponent');
        if (talkeeInput) {
          return talkeeInput.enabled = true;
        }
      }
    }
  };

  DialogRenderingSystem.prototype.draw = function(delta) {
    var dialogBox, dialogBoxText, i, image, line, _, _i, _len, _ref10, _ref9, _results;
    _ref9 = this.entityManager.getFirstEntityAndComponents(['DialogBoxComponent', 'DialogBoxTextComponent']), _ = _ref9[0], dialogBox = _ref9[1], dialogBoxText = _ref9[2];
    if (dialogBox.visible) {
      this.cq.font('16px "Press Start 2P"').textBaseline('top').fillStyle('black');
      image = this.assetManager.assets['pokemon-dialog-box.png'];
      this.cq.drawImage(image, 0, Game.SCREEN_HEIGHT - image.height);
      _ref10 = dialogBoxText.text.split('\n');
      _results = [];
      for (i = _i = 0, _len = _ref10.length; _i < _len; i = ++_i) {
        line = _ref10[i];
        _results.push(this.cq.fillText(line, 18, Game.SCREEN_HEIGHT - image.height + 22 + 20 * i));
      }
      return _results;
    }
  };

  return DialogRenderingSystem;

})(System);

AnimationDirectionSyncSystem = (function(_super) {
  __extends(AnimationDirectionSyncSystem, _super);

  function AnimationDirectionSyncSystem() {
    _ref9 = AnimationDirectionSyncSystem.__super__.constructor.apply(this, arguments);
    return _ref9;
  }

  AnimationDirectionSyncSystem.prototype.update = function(delta) {
    var animation, animationEntity, direction, _i, _len, _ref10, _ref11, _results;
    _ref10 = this.entityManager.iterateEntitiesAndComponents(['AnimationComponent', 'DirectionComponent']);
    _results = [];
    for (_i = 0, _len = _ref10.length; _i < _len; _i++) {
      _ref11 = _ref10[_i], animationEntity = _ref11[0], animation = _ref11[1], direction = _ref11[2];
      _results.push(animation.currentAction = 'walk-' + direction.direction);
    }
    return _results;
  };

  return AnimationDirectionSyncSystem;

})(System);

AnimatedSpriteSystem = (function(_super) {
  __extends(AnimatedSpriteSystem, _super);

  function AnimatedSpriteSystem() {
    _ref10 = AnimatedSpriteSystem.__super__.constructor.apply(this, arguments);
    return _ref10;
  }

  AnimatedSpriteSystem.prototype.update = function(delta) {
    var action, actions, animation, animationEntity, _i, _len, _ref11, _ref12, _results;
    _ref11 = this.entityManager.iterateEntitiesAndComponents(['AnimationComponent']);
    _results = [];
    for (_i = 0, _len = _ref11.length; _i < _len; _i++) {
      _ref12 = _ref11[_i], animationEntity = _ref12[0], animation = _ref12[1];
      actions = this.entityManager.getComponents(animationEntity, 'AnimationActionComponent');
      _results.push((function() {
        var _j, _len1, _results1;
        _results1 = [];
        for (_j = 0, _len1 = actions.length; _j < _len1; _j++) {
          action = actions[_j];
          if (action.name === animation.currentAction) {
            action.frameElapsedTime += delta;
            if (action.frameElapsedTime > action.frameLength) {
              action.frameElapsedTime = 0;
              action.currentFrame++;
              if (action.currentFrame >= action.indices.length) {
                action.currentFrame = 0;
              }
            }
            break;
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      })());
    }
    return _results;
  };

  AnimatedSpriteSystem.prototype.draw = function(delta) {
    var action, actions, animation, animationEntity, animationPosition, camera, cameraPosition, imageX, imageY, screenX, screenY, _, _i, _len, _ref11, _ref12, _ref13, _results;
    _ref11 = this.entityManager.getFirstEntityAndComponents(['CameraComponent', 'PixelPositionComponent']), camera = _ref11[0], _ = _ref11[1], cameraPosition = _ref11[2];
    _ref12 = this.entityManager.iterateEntitiesAndComponents(['AnimationComponent', 'PixelPositionComponent']);
    _results = [];
    for (_i = 0, _len = _ref12.length; _i < _len; _i++) {
      _ref13 = _ref12[_i], animationEntity = _ref13[0], animation = _ref13[1], animationPosition = _ref13[2];
      actions = this.entityManager.getComponents(animationEntity, 'AnimationActionComponent');
      _results.push((function() {
        var _j, _len1, _results1;
        _results1 = [];
        for (_j = 0, _len1 = actions.length; _j < _len1; _j++) {
          action = actions[_j];
          if (action.name === animation.currentAction) {
            imageX = action.indices[action.currentFrame] * animation.width;
            imageY = action.row * animation.height;
            screenX = Math.floor(animationPosition.x - cameraPosition.x);
            screenY = Math.floor(animationPosition.y - cameraPosition.y);
            this.cq.drawImage(this.assetManager.assets[animation.spritesheetUrl], imageX, imageY, animation.width, animation.height, screenX, screenY, animation.width, animation.height);
            break;
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  return AnimatedSpriteSystem;

})(System);

BattleTriggerSystem = (function(_super) {
  __extends(BattleTriggerSystem, _super);

  BattleTriggerSystem.BATTLE_CHANCE = 0.95;

  BattleTriggerSystem.TALL_GRASS_TILE = 17;

  function BattleTriggerSystem(cq, entityManager, eventManager, assetManager) {
    var playerEntity, _, _ref11,
      _this = this;
    this.cq = cq;
    this.entityManager = entityManager;
    this.eventManager = eventManager;
    this.assetManager = assetManager;
    BattleTriggerSystem.__super__.constructor.call(this, this.cq, this.entityManager, this.eventManager, this.assetManager);
    _ref11 = this.entityManager.getFirstEntityAndComponents(['PlayerComponent']), playerEntity = _ref11[0], _ = _ref11[1];
    this.eventManager.subscribe('movement-enter-square', playerEntity, function(entity, data) {
      var layer, mapEntities, mapEntity, screenImage, thisTile, tileIdx, _i, _len, _results;
      screenImage = _this.cq.getImageData(0, 0, Game.SCREEN_WIDTH, Game.SCREEN_HEIGHT);
      game.changeState(new BattleTransitionState(screenImage));
      console.log(game.currentState);
      return;
      mapEntities = _this.entityManager.getEntitiesHavingComponent('TilemapVisibleLayerComponent');
      _results = [];
      for (_i = 0, _len = mapEntities.length; _i < _len; _i++) {
        mapEntity = mapEntities[_i];
        layer = _this.entityManager.getComponent(mapEntity, 'TilemapVisibleLayerComponent');
        tileIdx = data.row * layer.tileData.width + data.col;
        thisTile = layer.tileData.data[tileIdx];
        console.log(thisTile);
        if (thisTile === BattleTriggerSystem.TALL_GRASS_TILE) {
          console.log('in grass');
          if (Math.random() < BattleTriggerSystem.BATTLE_CHANCE) {
            console.log('battle');
            screenImage = _this.cq.getImageData(0, 0, Game.SCREEN_WIDTH, Game.SCREEN_HEIGHT);
            _results.push(game.state = new BattleTransitionState(screenImage));
          } else {
            _results.push(console.log('nobattle'));
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
  }

  return BattleTriggerSystem;

})(System);
