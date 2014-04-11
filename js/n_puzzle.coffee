smart.ready {
  puzzle:"images/puzzle.png"
},(S,images)->
  n = 4
  initial_position = [0..n*n].sort(->Math.random()-.5)

  c1to2 = (i)->[i%n, Math.floor(i/n)]
  c2to1 = (i,j)->i*n+j

  stage = new S.Stage("n_puzzle")
  s_width  = stage.width
  s_height = stage.height

  p_width  = images.puzzle.width
  p_height = images.puzzle.height

  pieces = []
  for i in [0..n]
    pieces.push []
    for j in [0..n]
      piece = new S.Canvas(s_width/n,s_height/n)
      piece.x = i * s_width/n
      piece.y = j * s_height/n
      [p,q] = c1to2 initial_position[c2to1(i,j)]
      piece.draw(images.puzzle,p*p_width/n,q*p_height/n,p_width/n,p_height/n)

      pieces[i].push piece
      stage.addChild piece
