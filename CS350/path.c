/* Kyle Frank
   701015001
   kfrank
 */

#include <stdio.h>

int rows, columns;
int entranceR, entranceC;

int walkMaze(char maze[rows][columns],int i, int j, char direction);

main()
{

  /* finds the dimensions of the maze */
  printf("Type in the number of rows\n");
  scanf("%d", &rows);
  printf("Type in the number of columns\n");
  scanf("%d", &columns);

  char array[rows][columns];
  FILE *fptr;
  char c;
  char file_name[20];
  int i,j;
  
  printf("Type in the name of the file containing the Field\n");
  scanf("%s",file_name);
  fptr=fopen(file_name,"r");
  for (i=0; i<rows; i++)
   for (j=0; j<columns; j++){
     c=fgetc(fptr); 
     while ( !((c == '1')||(c =='0')) ) c=fgetc(fptr);
     array[i][j]=c;
   }
  fclose(fptr);

  /* prints the unfinished maze */
  for (i=0; i<rows; i++)
   for (j=0; j<columns; j++)  {
    if (j == 0) printf("\n");                
    printf("%c  ",array[i][j]);
   }
  printf("\n");

  /* Solves the maze. The variable found is a 0 if there is no path to the exit
     or a 1 if there is one. 
  */
  int found = pathFinder(array);

  /* prints out the finished maze */
  for (i=0; i<rows; i++)
   for (j=0; j<columns; j++)  {
    if (j == 0) printf("\n");                
    printf("%c  ",array[i][j]);
   }
  printf("\n");
  
  /* Prints out if the exit was reached or not */
  if (found)
    printf("Path was found!\n");
  else
    printf("No path found\n");

}

/* Solves a maze of 1's and 0's. First finds the entrance then
   uses the recursive function walkMaze() to solve it.
   @param maze[][] -> the maze represented as a 2d array of chars
   @returns -> a 1 if the exit was found. 0 if not.
 */
int pathFinder(char maze[rows][columns]){
  
  int i = 0;
  int j = 0;
  char dir = 'S';

  /* Big loop to walk around the border and find the entrance, 
     assumes there is one */
  while (1){
    if (maze[i][j] == '0')
      break;
    if (j < columns-1 && i == 0)
      j++;
    else if (j == columns-1 && i < rows-1)
      i++;
    else if (i == rows-1 && j > 0 )
      j--;
    else
      i--;
  }
  
  maze[i][j] = 'X';
  entranceR = i;
  entranceC = j;

  /* Moves the starting coordinates off the border since the base case
     of walkMaze() is when a border is reached. Also sets the direction*/
  if (i == 0){
    dir = 'E';
    i++;
  }
  else if (j==0)
    j++;
  else if (i == rows-1){
    dir = 'N';
    i--;
  }
  else{
    dir = 'W';
    j--;
  }
  
  /* Walks through the maze until a border is reached */
  return walkMaze(maze, i, j, dir);
}
     
/* Recursive function to find a border in a maze. A border could be
   the entrance or the exit. 
   @param maze[][] -> the maze represented by a 2d array
   @param i -> the current row position
   @param j -> the current column position
   @param direction -> the direction of the last move. Prevents infinite
                       looping when backtracking.
   @returns -> 1 if the exit was found, 0 if not.
 */
int walkMaze(char maze[rows][columns], int i, int j, char direction){

  /* Sets the current position as already walked */
  maze[i][j] = 'X';
  
  /* Base case; once a border is found exit the method */
  if (i == 0 || j == 0 || i == rows-1 || j == columns-1){
    if (i == entranceR && j == entranceC){
      return 0;
    }
    else
      return 1;
  }
  
  /* Walk case; find a neighbor that is a 0 */
  if (maze[i-1][j] == '0')
    return walkMaze(maze, i-1, j, 'S');
  else if (maze[i][j-1] == '0')
    return walkMaze(maze, i, j-1, 'E');
  else if (maze[i+1][j] == '0')
    return walkMaze(maze, i+1, j, 'N');
  else if (maze[i][j+1] == '0')
    return walkMaze(maze, i, j+1, 'W');

  /* Backtrack case; no 0's are neighbors so retrace til one is. */
  if (maze[i-1][j] == 'X' && direction != 'S')
    return walkMaze(maze, i-1, j, 'N');
  else if (maze[i][j-1] == 'X' && direction != 'E')
    return walkMaze(maze, i, j-1, 'W');
  else if (maze[i+1][j] == 'X' && direction != 'N')
    return walkMaze(maze, i+1, j, 'S');
  else if (maze[i][j+1] == 'X' && direction != 'W')
    return walkMaze(maze, i, j+1, 'E');
}
