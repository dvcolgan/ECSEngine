/*  this is Eveline - she now replaces cq.framework property */

(function(window, undefined) {

  var MOBILE = /FFOS|Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent);

  window.requestAnimationFrame = (function() {
    return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
      window.setTimeout(callback, 1000 / 60);
    };
  })();

  eveline = function(events, context, element) {

    if (element === undefined) {
      element = window;
    } else if (typeof element === "string") {
      element = document.querySelector(element);
    }

    var tempContext = context || events;

    for (var name in events) {
      if (typeof eveline[name] === "function") eveline[name](element, events[name], tempContext);
    }

    /* apply scaling */

    tempContext.scale = 1;
    tempContext.iscale = 1;

    tempContext.preventMultitouch = tempContext.preventMultitouch || false;

    if (tempContext.autoscale) {

      window.addEventListener("resize", function() {
        eveline.fitToScreen(element, tempContext);
      });

      eveline.fitToScreen(element, tempContext);
    }

    setInterval(eveline.step, 1000 / 60);
    // requestAnimationFrame(eveline.step);

    eveline.mouse = !MOBILE;

  };

  eveline.extend = function() {
    for (var i = 1; i < arguments.length; i++) {
      for (var j in arguments[i]) {
        arguments[0][j] = arguments[i][j];
      }
    }

    return arguments[0];
  };

  eveline.gamepadButtons = {
    0: "1",
    1: "2",
    2: "3",
    3: "4",
    4: "l1",
    5: "r1",
    6: "l2",
    7: "r2",
    8: "select",
    9: "start",
    12: "up",
    13: "down",
    14: "left",
    15: "right"
  };

  eveline.keycodes = {
    37: "left",
    38: "up",
    39: "right",
    40: "down",
    45: "insert",
    46: "delete",
    8: "backspace",
    9: "tab",
    13: "enter",
    16: "shift",
    17: "ctrl",
    18: "alt",
    19: "pause",
    20: "capslock",
    27: "escape",
    32: "space",
    33: "pageup",
    34: "pagedown",
    35: "end",
    112: "f1",
    113: "f2",
    114: "f3",
    115: "f4",
    116: "f5",
    117: "f6",
    118: "f7",
    119: "f8",
    120: "f9",
    121: "f10",
    122: "f11",
    123: "f12",
    144: "numlock",
    145: "scrolllock",
    186: "semicolon",
    187: "equal",
    188: "comma",
    189: "dash",
    190: "period",
    191: "slash",
    192: "graveaccent",
    219: "openbracket",
    220: "backslash",
    221: "closebraket",
    222: "singlequote"
  };

  eveline.extend(eveline, {

    gamepadState: [],

    eventsListeners: {},

    addEventListener: function(event, callback) {
      if (!this.eventsListeners[event]) this.eventsListeners[event] = [];
      this.eventsListeners[event].push(callback);
    },

    trigger: function(event) {
      var args = [];

      for (var i = 1; i < arguments.length; i++) args.push(arguments[i]);

      var listeners = this.eventsListeners[event];

      if (!listeners) return;

      for (var i = 0; i < listeners.length; i++) {
        listeners[i].apply(this, args);
      }
    },

    distance: function(x1, y1, x2, y2) {
      return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y2));
    },

    step: function() {

      if (navigator.getGamepads || navigator.webkitGetGamepads) {

        var gamepads = navigator.getGamepads ? navigator.getGamepads() : navigator.webkitGetGamepads();

        for (var i = 0; i < gamepads.length; i++) {
          var current = gamepads[i];

          if (!current) continue;

          if (!eveline.gamepadState[i]) eveline.gamepadState[i] = current;

          var previous = eveline.gamepadState[i];

          var buttons = [];

          if (previous.axes[0] !== current.axes[0] || previous.axes[1] !== current.axes[1]) {
            eveline.trigger("gamepadmove", current.axes[0], current.axes[1], i);
          }

          buttons[0] = current.axes[1] < 0 ? 1 : 0;
          buttons[1] = current.axes[1] > 0 ? 1 : 0;
          buttons[2] = current.axes[0] < 0 ? 1 : 0;
          buttons[3] = current.axes[0] > 0 ? 1 : 0;

          buttons = current.buttons.concat(buttons);

          for (var j = 0; j < buttons.length; j++) {
            if (previous.buttons[j] === 0 && buttons[j] === 1) eveline.trigger("gamepaddown", eveline.gamepadButtons[j], i);
            if (previous.buttons[j] === 1 && buttons[j] === 0) eveline.trigger("gamepadup", eveline.gamepadButtons[j], i);
          }

          eveline.gamepadState[i] = {
            buttons: buttons,
            axes: current.axes
          };
        }

      }

      // requestAnimationFrame(eveline.step);
    },

    mousePosition: function(event, element) {
      var totalOffsetX = 0,
        totalOffsetY = 0,
        coordX = 0,
        coordY = 0,
        currentElement = element || event.target || event.srcElement,
        mouseX = 0,
        mouseY = 0;

      // Traversing the parents to get the total offset
      do {
        totalOffsetX += currentElement.offsetLeft;
        totalOffsetY += currentElement.offsetTop;
      }
      while ((currentElement = currentElement.offsetParent));
      // Set the event to first touch if using touch-input
      if (event.changedTouches && event.changedTouches[0] !== undefined) {
        event = event.changedTouches[0];
      }
      // Use pageX to get the mouse coordinates
      if (event.pageX || event.pageY) {
        mouseX = event.pageX;
        mouseY = event.pageY;
      }
      // IE8 and below doesn't support event.pageX
      else if (event.clientX || event.clientY) {
        mouseX = event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
        mouseY = event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
      }
      // Subtract the offset from the mouse coordinates
      coordX = mouseX - totalOffsetX;
      coordY = mouseY - totalOffsetY;

      return {
        x: coordX,
        y: coordY
      };
    },

    onstep: function(element, callback, context) {

      var lastTick = Date.now();

      function step() {        
        var delta = Date.now() - lastTick;
        lastTick = Date.now();
        requestAnimationFrame(step)
        callback.call(context, delta, lastTick);
      };

      requestAnimationFrame(step);
    },

    onrender: function(element, callback, context) {
 
      var lastTick = Date.now();

      function step() {        
        var delta = Date.now() - lastTick;
        lastTick = Date.now();
        requestAnimationFrame(step)
        callback.call(context, delta, lastTick);
      };

      requestAnimationFrame(step);
    },

    onmousemove: function(element, callback, context) {
      element.addEventListener("mousemove", function(e) {

        if (!eveline.mouse) return;

        var pos = eveline.mousePosition(e, element);
        callback.call(context, pos.x * context.iscale | 0, pos.y * context.iscale | 0);
      });

      return this;
    },

    onmousedown: function(element, callback, context) {

      element.addEventListener("mousedown", function(e) {

        if (!eveline.mouse) return;

        var pos = eveline.mousePosition(e, element);
        context.mouseStart = {
          x: pos.x * context.iscale | 0,
          y: pos.y * context.iscale | 0
        };
        callback.call(context, pos.x * context.iscale | 0, pos.y * context.iscale | 0, e.button);
      });

      return this;
    },

    onmouseup: function(element, callback, context) {

      element.addEventListener("mouseup", function(e) {

        if (!eveline.mouse) return;

        var pos = eveline.mousePosition(e, element);
        callback.call(context, pos.x * context.iscale | 0, pos.y * context.iscale | 0, e.button);
      });

      return this;
    },

    onmousewheel: function(element, callback, context) {

      var eventNames = 'onwheel' in document || document.documentMode >= 9 ? ['wheel'] : ['mousewheel', 'DomMouseScroll', 'MozMousePixelScroll'];

      for (var i = eventNames.length; i;) {

        element.addEventListener(eventNames[--i], function(event) {

          if (!eveline.mouse) return;

          var orgEvent = event || window.event,
            args = [].slice.call(arguments, 1),
            delta = 0,
            deltaX = 0,
            deltaY = 0,
            absDelta = 0,
            absDeltaXY = 0,
            fn;
          event.type = "mousewheel";

          // Old school scrollwheel delta
          if (orgEvent.wheelDelta) {
            delta = orgEvent.wheelDelta;
          }

          if (orgEvent.detail) {
            delta = orgEvent.detail * -1;
          }

          // New school wheel delta (wheel event)
          if (orgEvent.deltaY) {
            deltaY = orgEvent.deltaY * -1;
            delta = deltaY;
          }

          // Webkit
          if (orgEvent.wheelDeltaY !== undefined) {
            deltaY = orgEvent.wheelDeltaY;
          }

          var result = delta ? delta : deltaY;

          callback.call(context, result / Math.abs(result));

          event.preventDefault();

        }, false);
      }
    },

    ontouchmove: function(element, callback, context) {
      element.addEventListener("touchmove", function(e) {


        if (context.preventMultitouch && e.touches.length > 1) return;
        e.preventDefault();
        var pos = eveline.mousePosition(e, element);


        callback.call(context, pos.x * context.iscale | 0, pos.y * context.iscale | 0, e.touches);
      });
    },

    ontouchstart: function(element, callback, context) {

      element.addEventListener("touchstart", function(e) {

        if (context.preventMultitouch && e.touches.length > 0) return;

        var pos = eveline.mousePosition(e, element);

        context.mouseStart = {
          x: pos.x * context.iscale | 0,
          y: pos.y * context.iscale | 0
        };

        callback.call(context, pos.x * context.iscale | 0, pos.y * context.iscale | 0, e.touches);
      });


    },

    ontouchend: function(element, callback, context) {
      element.addEventListener("touchend", function(e) {
        if (context.preventMultitouch && e.touches.length > 0) return;
        var pos = eveline.mousePosition(e, element);

        callback.call(context, pos.x * context.iscale | 0, pos.y * context.iscale | 0, e.touches);
      });
    },

    onclick: function(element, callback, context) {
      this.onmouseup(element, function(x, y) {
        if (eveline.distance(x, y, context.mouseStart.x, context.mouseStart.y) < 5) {
          callback.call(context, x * context.iscale | 0, y * context.iscale | 0);
        }
      }, context);
    },

    onkeydown: function(element, callback, context) {

      document.addEventListener("keydown", function(e) {
        if (e.which >= 48 && e.which <= 90) var keyName = String.fromCharCode(e.which).toLowerCase();
        else var keyName = eveline.keycodes[e.which];
        callback.call(context, keyName);
      });
      return this;
    },

    onkeyup: function(element, callback, context) {

      document.addEventListener("keyup", function(e) {
        if (e.which >= 48 && e.which <= 90) var keyName = String.fromCharCode(e.which).toLowerCase();
        else var keyName = eveline.keycodes[e.which];
        callback.call(context, keyName);
      });
      return this;
    },

    ongamepaddown: function(element, callback, context) {

      eveline.addEventListener("gamepaddown", function(button, gamepad) {
        callback.call(context, button, gamepad);
      });

      return this;
    },

    ongamepadup: function(element, callback, context) {

      eveline.addEventListener("gamepadup", function(button, gamepad) {
        callback.call(context, button, gamepad);
      });

      return this;
    },

    ongamepadmove: function(element, callback, context) {

      eveline.addEventListener("gamepadmove", function(x, y, gamepad) {
        callback.call(context, x, y, gamepad);
      });

      return this;
    },


    onresize: function(element, callback, context) {
      window.addEventListener("resize", function() {
        callback.call(context, window.innerWidth, window.innerHeight);
      });

      // callback.call(context, window.innerWidth, window.innerHeight);

      return this;
    },

    ondropimage: function(element, callback, context) {

      document.addEventListener('drop', function(e) {
        e.stopPropagation();
        e.preventDefault();

        var file = e.dataTransfer.files[0];

        if (!(/image/i).test(file.type)) return false;
        var reader = new FileReader();

        reader.onload = function(e) {
          var image = new Image;

          image.onload = function() {
            callback.call(context, this);
          };

          image.src = e.target.result;
        };

        reader.readAsDataURL(file);

      });

      document.addEventListener("dragover", function(e) {
        e.preventDefault();
      });

      return this;
    },

    fitToScreen: function(element, context) {
      var scale = window.innerWidth / context.width;

      if (context.height * scale > window.innerHeight) {
        scale = window.innerHeight / context.height;
      }

      // scale = Math.min(1, scale);

      context.scale = scale;
      context.iscale = 1 / scale;

      var scaleCSSText = "scale(" + scale + "," + scale + ")";

      eveline.extend(element.style, {
        "-webkit-transform-origin": "top left",
        "-webkit-transform": scaleCSSText,
        "-moz-transform-origin": "top left",
        "-moz-transform": scaleCSSText,
        "-ms-transform-origin": "top left",
        "-ms-transform": scaleCSSText,
        "transformOrigin": "top left",
        "transform": scaleCSSText,
        "left": ((window.innerWidth / 2 - (context.width * context.scale) / 2) | 0) + "px",
        "top": ((window.innerHeight / 2 - (context.height * context.scale) / 2) | 0) + "px"
      });
    },

  });

  CanvasQuery.Wrapper.prototype.framework = function(args, context) {
    if (!context) context = this;

    eveline(args, context, this.canvas);

    return this;
  };

  if (typeof define === "function" && define.amd) {
    define([], function() {
      return eveline;
    });
  }


})(window);