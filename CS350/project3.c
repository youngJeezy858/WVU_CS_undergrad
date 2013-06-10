/* Kyle Frank
   701015001
   kfrank
*/

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int sequence[800];

int main() {

  	//gets the file name and reads from it
 	printf("please enter the name of your file: ");
 	char fileName[20];
 	scanf("%s", &fileName);
 	FILE *fptr;
 	fptr = fopen(fileName, "r");
  
 	int i = 0, j = 0, k = 0;
  	for (i = 0; i < 800; i++)
  		fscanf(fptr, "%d", &sequence[i]);

	pid_t child1_pid, child2_pid, child3_pid;
	int fd[2];
	
	if (pipe(fd) == -1){
		perror("failure");
		return 1;
	}
	
	//creates 2nd tier (2 children)
	child1_pid = 0;
	for (i = 0; i < 2; i++){
		if ((child1_pid = fork()) <= 0)
			break;
	}
	//1st tier (occurs once)
	if (child1_pid > 0){
		printf("Current process PID: %ld Parent proccess PID: %ld\n", (long)getpid(), (long)getppid());
		write (fd[1], sequence, sizeof(int)*800);
		printf ("%ld: 800 numbers recieved\n", (long)getpid()); 
		printf ("%ld: creating child processes\n\n", (long)getpid());
		fflush(stdin);
		//sleep until child processes have finished
		sleep(3);
		//merge sort arrays of 400
		int arr1[400], arr2[400];
		printf("%ld: merging...\n", (long)getpid());
		read(fd[0], arr1, sizeof(int)*400);
		read(fd[0], arr2, sizeof(int)*400);
		mergeSort(arr1, arr2, sequence, 400);
		write(fd[1], sequence, sizeof(int)*800);
		//write sorted array to "out.dat"
		FILE *fptr;
		fptr = fopen("out.dat", "w");
		int x;
		for (x = 0; x < 800; x++)
			fprintf(fptr, "%d\n", sequence[x]);
		fclose(fptr);
	}
	//creates third tier (4 children)
	else {
		for (j = 0; j < 2; j++){
			if ((child2_pid = fork()) <= 0)
				break;
		}
	}
	//2nd tier (occurs twice)
	if (child2_pid >0 && child1_pid == 0){
		printf("Current process PID: %ld Parent proccess PID: %ld\n", (long)getpid(), (long)getppid());
		printf ("%ld: 400 numbers recieved\n", (long)getpid()); 
		printf ("%ld: creating child processes\n\n", (long)getpid());
		fflush(stdin);
		//sleep until child processes have finished
		sleep(2);
		//merge sort arrays of 200
		int arr1[200], arr2[200];
		printf("%ld: merging...\n", (long)getpid());
		read(fd[0], arr1, sizeof(int)*200);
		read(fd[0], arr2, sizeof(int)*200);
		mergeSort(arr1, arr2, sequence, 200);
		write(fd[1], sequence, sizeof(int)*400);
	}
	//creates fourth tier (8 children)
	else {
		for (k = 0; k < 2; k++){
			if ((child3_pid = fork()) <= 0)
				break;
		}
	}
	//third tier (occurs 4 times)
	if (child3_pid > 0 && child1_pid == 0 && child2_pid == 0){
		printf("Current process PID: %ld Parent proccess PID: %ld\n", (long)getpid(), (long)getppid());
		printf ("%ld: 200 numbers recieved\n", (long)getpid()); 
		printf ("%ld: creating child processes\n\n", (long)getpid());
		fflush(stdin);
		//sleep until child processes have finished
		sleep(1);
		//merge sort arrays of 100
		int arr1[100], arr2[100];
		printf("%ld: merging...\n", (long)getpid());
		read(fd[0], arr1, sizeof(int)*100);
		read(fd[0], arr2, sizeof(int)*100);
		mergeSort(arr1, arr2, sequence, 100);
		write(fd[1], sequence, sizeof(int)*200);
	}
	//fourth tier (occurs 8 times)
	else if (child1_pid == 0 && child2_pid == 0 && child3_pid == 0){
		printf("Current process PID: %ld Parent proccess PID: %ld\n", (long)getpid(), (long)getppid());
		//get array of 100 from the pipe
		read (fd[0], sequence, sizeof(int)*100);
		printf ("%ld: 100 numbers recieved\n", (long)getpid()); 
		printf ("%ld: sorting...\n", (long)getpid());
		//quick sort it then write the sorted array to the pipe
		quickSort(sequence, 0, 99);
		write (fd[1], sequence, sizeof(int)*100);
	}
	fflush(stdin);
}

/*Uses divide and conquer method to sort an array of integers
	param arr[] -> array to be sorted
	param left -> position of left most int
	param right -> position of right most int
*/
void quickSort(int arr[], int left, int right){
	int i = left, j = right;
	int tmp;
	int pivot = arr[(left + right) / 2];

	// partitions the array (greater values go on left, lesser on right)
	while (i <= j){
		while (arr[i] > pivot)
			i++;
		while (arr[j] < pivot)
			j--;
		if (i <= j){
			tmp = arr[i];
			arr[i] = arr[j];
			arr[j] = tmp;
			i++;
			j--;
		}
	}

	// divide the array and recurse until solved
	if (left < j)
		quickSort(arr, left, j);
	if (i < right)
		quickSort(arr, i, right);

}

/*sorts two arrays of the same length and returns an array with the sorted values
	param arr1[] -> first array to be sorted
	param arr2[] -> second array to be sorted
	param n -> length of arrays 
*/
void mergeSort(int arr1[], int arr2[], int result[], int n){
	int i = 0, j = 0;
	
	//merge sorts both arrays
	while (i < n && j < n){
		if (arr1[i] > arr2[j]){
			result[i+j] = arr1[i];
			i++;
		}
		else {
			result[i+j] = arr2[j];
			j++;
		}
	}
	
	//appends the remaining array onto result[]
	for (i; i < n; i++)
		result[i+j] = arr1[i];
	for (j; j < n; j++)
		result[i+j] = arr2[j];

}



