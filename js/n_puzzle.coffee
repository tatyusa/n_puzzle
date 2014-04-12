allocate = (obj, configs...) ->
  for config in configs
    for key, value of config
      obj[key] = value

game =
  isFinished: false
  init: (size)->
    this.size = size
    this.board = _.shuffle [0...this.size*this.size]
    this.hole = _.last this.board
  c1to2: (i)-> [i%this.size, Math.floor(i/this.size)]
  c2to1: (x,y)-> x+y*this.size
  boardSwitch: (i,j) -> [this.board[i], this.board[j]] = [this.board[j], this.board[i]]
  showBoard: ->
    console.log "--------"
    for y in [0...this.size]
      temp = ""
      for x in [0...this.size]
        temp += this.board[this.c2to1(x,y)] + ", "
      console.log temp
  active: (value)->
    if this.isFinished then return 0
    index = _.indexOf this.board,value

    #0: none, 1: up, 2: right, 3: down, 4: left
    direction = 0
    if (this.size<=index) and (this.board[index-this.size] is this.hole)
      direction = 1
    if (index+1<this.size*this.size) and ((index+1)%this.size isnt 0) and (this.board[index+1] is this.hole)
      direction = 2
    if (index<this.size*(this.size-1)) and (this.board[index+this.size] is this.hole)
      direction = 3
    if (0<index) and (index%this.size isnt 0) and (this.board[index-1] is this.hole)
      direction = 4

    switch direction
      when 1 then this.boardSwitch(index, index-this.size)
      when 2 then this.boardSwitch(index, index+1)
      when 3 then this.boardSwitch(index, index+this.size)
      when 4 then this.boardSwitch(index, index-1)

    return direction
  check: ->
    if _.isEqual this.board, [0...this.size*this.size]
      this.clear(this.hole)
  clear: -> return #virtual

smart.ready puzzle:"images/puzzle.png", (S,images)->
  game.init(3)

  stage = new S.Stage("n_puzzle")

  s_width  = stage.width
  s_height = stage.height

  p_width  = images.puzzle.width
  p_height = images.puzzle.height

  for y in [0...game.size]
    for x in [0...game.size]
      if (x+1 is game.size) and (y+1 is game.size) then break

      piece = new S.Canvas(s_width/game.size,s_height/game.size)
      allocate piece, 
        x: x * s_width/game.size
        y: y * s_height/game.size
      
      # order in original image
      piece.index = game.board[game.c2to1(x,y)]
      [p,q] = game.c1to2 piece.index

      piece.draw images.puzzle, p*p_width/game.size, q*p_height/game.size, p_width/game.size, p_height/game.size

      stage.addChild piece

      piece.bind "click", ->
        params = switch game.active this.index
          when 1 then {y:this.y-s_height/game.size}
          when 2 then {x:this.x+s_width/game.size}
          when 3 then {y:this.y+s_height/game.size}
          when 4 then {x:this.x-s_width/game.size}
        if params then S.tween.start this,params, "easeOutQuad", 0.1, 0, game.check.bind(game)

  game.clear = (index)->
    game.isFinished = true
    [x, y] = game.c1to2 index
    piece = new S.Canvas(s_width/game.size,s_height/game.size)
    allocate piece,
      x: x * s_width/game.size
      y: y * s_height/game.size
      alpha: 0

    piece.draw images.puzzle, x*p_width/game.size, y*p_height/game.size, p_width/game.size, p_height/game.size
    stage.addChild piece
    S.tween.start piece, alpha:1 ,"easeOutQuad",1,0, ->
      panel = new S.Canvas(s_width,s_height)
      panel.bg.color = "#FFF"
      panel.alpha = 0.6
      
      text = new S.Text("Clear!")
      allocate text,
        x: 40
        y: 140
        size: 64
        bold: true
        underline: true
        color: "yellow"
        rotation: -20

      stage.addChild panel
      stage.addChild text



