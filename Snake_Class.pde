class Snake {
  boolean[][] Board;
  ArrayList<PVector> TailPositions; /* List of positions of the snake that aren't the head
  PVector FoodPos; /* Position of the food */
  int HeadPosX;
  int HeadPosY;
  int Length; /* Used for fitness */
  int Spacing; /* Spacing of each square on the board */
  boolean Dead; /* Is the snake dead or not */

  int TimeAlive; /* Used for fitness */
  NeuralNetwork Brain; /* Brain of the snake */

  Snake() {
    Reset();

    Brain = new NeuralNetwork(8, 128, 64, 4);
  }

  void Show() { /* Shows the snake on the board */

    for (PVector Position : TailPositions) {
      fill(255);
      rect(Position.x*Spacing, Position.y*Spacing, Spacing, Spacing);
    }
    rect(HeadPosX*Spacing, HeadPosY*Spacing, Spacing, Spacing);
    fill(255, 0, 0);
    rect(FoodPos.x*Spacing, FoodPos.y*Spacing, Spacing, Spacing);
  }

  void Move() { /* Calculate next position of the snake */
    TimeAlive++;
    
    if (TimeAlive > 250) { /* Kill the snake if it hasnt eaten in a long time - stops snake going in circles */
      Dead = true;
    }
    
    TailPositions.add(new PVector(HeadPosX, HeadPosY));

    int[] Inputs = new int[8]; /* Set inputs for the neural networks */
    if (HeadPosX - 1 < 0) {
      Inputs[0] = 0;
    } else {
      if (Board[HeadPosX-1][HeadPosY]) {
        Inputs[0] = 0;
      } else {
        Inputs[0] = 1;
      }
    }

    if (HeadPosY - 1 < 0) {
      Inputs[1] = 0;
    } else {
      if (Board[HeadPosX][HeadPosY-1]) {
        Inputs[1] = 0;
      } else {
        Inputs[1] = 1;
      }

      if (HeadPosX + 1 >= Rows) {
        Inputs[2] = 0;
      } else {
        if (Board[HeadPosX+1][HeadPosY]) {
          Inputs[2] = 0;
        } else {
          Inputs[2] = 1;
        }
      }
    }

    if (HeadPosY + 1 >= Rows) {
      Inputs[3] = 0;
    } else {
      if (Board[HeadPosX][HeadPosY+1]) {
        Inputs[3] = 0;
      } else {
        Inputs[3] = 1;
      }
    }

    if (FoodPos.x < HeadPosX) {
      Inputs[4] = 1;
    } else {
      Inputs[4] = 0;
    }

    if (FoodPos.x > HeadPosX) {
      Inputs[5] = 1;
    } else {
      Inputs[5] = 0;
    }

    if (FoodPos.y < HeadPosY) {
      Inputs[6] = 1;
    } else {
      Inputs[6] = 0;
    }

    if (FoodPos.y > HeadPosY) {
      Inputs[7] = 1;
    } else {
      Inputs[7] = 0;
    }

    Matrix Input = Matrix.Array(Inputs);
    Matrix Result = Brain.ForwardPropogation(Input);
    int Direction = Result.ShowMax();
    if (Direction == 0) { /* Move the snake, dependent on result */
      HeadPosY++;
    } else if (Direction == 1) {
      HeadPosX++;
    } else if (Direction == 2) {
      HeadPosY--;
    } else if (Direction == 3) {
      HeadPosX--;
    }
    
    boolean Grow = false;
    if (HeadPosX == FoodPos.x && HeadPosY == FoodPos.y) {
      Grow = true;
      Length++;
      GenerateFood();
      TimeAlive = 0; /* Eaten, reset timeAlive */
    }

    if (HeadPosX >= Rows || HeadPosY >= Rows || HeadPosX < 0 || HeadPosY < 0) {
      Dead = true;
    } else {
      if (Board[HeadPosX][HeadPosY]) {
        Dead = true;
      } else {
        Board[HeadPosX][HeadPosY] = true;
        if (!Grow) {
          Board[floor(TailPositions.get(0).x)][floor(TailPositions.get(0).y)] = false;
          TailPositions.remove(0);
        }
      }
    }
  }


  int GetFitness() { /* Returns the fitness of the snake, length is prioritised over TimeAlive */
    return (Length*1000 + TimeAlive); /* max(TimeAlive) = 250 */
  }

  void Mutate(Snake ToMutate) { /* Mutate each matrix within the snakes brain TODO - add function into Neural Network class that does this secretly */
    Brain.Weights1 = Matrix.Mutate(ToMutate.Brain.Weights1);
    Brain.Weights2 = Matrix.Mutate(ToMutate.Brain.Weights2);
    Brain.Weights3 = Matrix.Mutate(ToMutate.Brain.Weights3);

    Brain.HiddenOneBias = Matrix.Mutate(ToMutate.Brain.HiddenOneBias);
    Brain.HiddenTwoBias = Matrix.Mutate(ToMutate.Brain.HiddenTwoBias);
    Brain.OutputBias = Matrix.Mutate(ToMutate.Brain.OutputBias);

    Reset();
  }

  void GenerateFood() { /* Finds new food position */
    for (;; ) {
      FoodPos = new PVector(floor(random(Rows)), floor(random(Rows)));
      if (!Board[floor(FoodPos.x)][floor(FoodPos.y)]) {
        break;
      }
    }
  }

  void Reset() { /* Resets board */
    Board = new boolean[Rows][Rows];
    Spacing = width/Rows;
    HeadPosX = floor(Rows/2);
    HeadPosY = floor(Rows/2);
    Dead = false;
    Length = 4;
    Board[HeadPosX][HeadPosY] = true;
    Board[HeadPosX-1][HeadPosY] = true;
    Board[HeadPosX-2][HeadPosY] = true;
    Board[HeadPosX-3][HeadPosY] = true;
  
    TimeAlive = 0;
    TailPositions = new ArrayList<PVector>();
    TailPositions.add(new PVector(HeadPosX-3, HeadPosY));
    TailPositions.add(new PVector(HeadPosX-2, HeadPosY));
    TailPositions.add(new PVector(HeadPosX-1, HeadPosY));
    GenerateFood();
  }
}
