/*Kyle Frank
  701015001
  kfrank
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct listNode {  /* self-referential structure */
   char data[90];
   struct listNode *nextPtr;
};

typedef struct listNode LISTNODE;
typedef LISTNODE *LISTNODEPTR;

void insert(LISTNODEPTR *, char[90]);
char delete(LISTNODEPTR *, char[90]);
int isEmpty(LISTNODEPTR);
void printList(LISTNODEPTR, int);
void instructions(void);

int main(){

  LISTNODEPTR startPtr = NULL;

  //gets the file name
  char fileName[20];
  printf("Please type in the name of the file containing the text:\n");
  scanf("%s", &fileName);

  //big loop to get the number of characters
  int numLetters = 1;
  while (1){
    printf("Please enter the number of letters for each line(50-90):\n");
    scanf("%d", &numLetters);
    if (numLetters <=90 && numLetters >=50)
      break;
  }

  //opens the file
  FILE *fptr;
  fptr = fopen(fileName, "r");
  char buffer[90];

  //while loop is for reading in the file char by char
  while (!feof(fptr)){
    char temp = fgetc(fptr);

    //first case -> any whitespace
    //insert the current word and then clear the string
    if (temp <=32 && temp != '\n'){
      if (buffer != NULL){
	insert(&startPtr, buffer);
	clearString(buffer);
      }
    }
    
    //second case -> a new line
    //insert the current word then insert the new line seperately
    else if (temp == '\n'){
      if (buffer != NULL)	
	insert(&startPtr, buffer);
      char punc[90];
      punc[0] = temp;
      insert(&startPtr, punc);
      clearString(buffer);
    }

    //third case -> the buffer is empty
    //cpy the buffer to the temp char
    else if (buffer == NULL)
      strcpy(buffer, temp);
    
    //fourth case -> add the temp char to the buffer
    else 
      buffer[strlen(buffer)] = temp;
    temp = '\0';
  }
 
  //close the file then print out the justified text
  fclose(fptr);
  printList(startPtr, numLetters);

  return 0;
}

/* Insert a new value into the list in sorted order */
void insert(LISTNODEPTR *sPtr, char value[90])
{
   LISTNODEPTR newPtr, previousPtr, currentPtr;
   newPtr = malloc(sizeof(LISTNODE));
   
   if (newPtr != NULL) {    /* is space available */
     strcpy(newPtr->data, value);
      newPtr->nextPtr = NULL;

      previousPtr = NULL;
      currentPtr = *sPtr;

      while (currentPtr != NULL && value > currentPtr->data) {
         previousPtr = currentPtr;          /* walk to ...   */
         currentPtr = currentPtr->nextPtr;  /* ... next node */
      }

      if (previousPtr == NULL) {
         newPtr->nextPtr = *sPtr;
         *sPtr = newPtr;
      }
      else {
         previousPtr->nextPtr = newPtr;
         newPtr->nextPtr = currentPtr;
      }
   }
   else
      printf("%s not inserted. No memory available.\n", value);
}

/* Delete a list element */
char delete(LISTNODEPTR *sPtr, char value[])
{
   LISTNODEPTR previousPtr, currentPtr, tempPtr;

   if (value == (*sPtr)->data) {
      tempPtr = *sPtr;
      *sPtr = (*sPtr)->nextPtr;  /* de-thread the node */
      free(tempPtr);             /* free the de-threaded node */
      return value;
   }
   else {
      previousPtr = *sPtr;
      currentPtr = (*sPtr)->nextPtr;

      while (currentPtr != NULL && currentPtr->data != value) {
         previousPtr = currentPtr;          /* walk to ...   */
         currentPtr = currentPtr->nextPtr;  /* ... next node */
      }

      if (currentPtr != NULL) {
         tempPtr = currentPtr;
         previousPtr->nextPtr = currentPtr->nextPtr;
         free(tempPtr);
         return value;
      }                                                        
   }

   return '\0';
}

/* Return 1 if the list is empty, 0 otherwise */
int isEmpty(LISTNODEPTR sPtr)
{
   return sPtr == NULL;
}

/* Print the list */
void printList(LISTNODEPTR currentPtr, int numLetters)
{
   if (currentPtr == NULL)
     printf("List is empty.\n\n");

   char line[200];
   char temp[200];

   while (currentPtr != NULL) {
     strcpy(temp, currentPtr->data);

     //first case -> new line
     //print out the current line then add two new lines
     if (temp[0] == '\n'){
       printf("%s\n\n", line);
       clearString(line);
     }

     //second case -> the current line and the next word in the list are larger than the characters specified
     //add spaces to the current line then print it out
     else if(strlen(line) + strlen(temp) + 1 > numLetters){
       justify(numLetters, line);
       printf("%s\n", line);
       strcpy(line, temp);
     }

     //third case -> current line is not empty
     //add a space then the next word to the current line
     else if(strlen(line) != 0){
       strcat(line, " ");
       strcat(line, temp);
     }

     //fourth case -> the current line is empty
     //add the next word
     else
       strcpy(line, temp);
     currentPtr = currentPtr->nextPtr;
   }
   printf("%s\n\n", line);
}

//method to justify the current line.
//loops through the line and adds a space next to an existing 
//space until its length matches the number of characters specified  
void justify(int numLetters, char line[200]){
  int i = 0;
  while(strlen(line) != numLetters){
    if (line[i] == ' '){
      if (i >= strlen(line)) 
	i = 0;
      else{
	addSpace(line, i);
	i++;
      }
    }
    i++;
  }
}

void clearString(char buffer[90]){
  int i;
  for (i = 0; i<90; i++){
    buffer[i] = '\0';
  }
}


void addSpace(char line[200], int i){
  int j;
  for(j = strlen(line); j >= i; j--)
    line[j+1] = line[j];
}
