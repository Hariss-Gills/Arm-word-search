# Arm-word-search
A simple word search program that searches through a .txt file and prints the matches line, total number of lines, and the number of matches 

## To run the program
1. Go to where the file is in your directory via `cd`command
2. Make an executable with the .s file: `arm-linux-gnueabi-gcc -o word-search word-search.s`
3. run the program: `cat [filename].txt | qemu-arm -L /usr/arm-linux-gnueabi/ word-search`
