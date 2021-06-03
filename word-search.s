@@@@@@@@@@@@@@@@@ Running Commands Start @@@@@@@@@@@@@@@@@@@@@@
@arm-linux-gnueabi-gcc -o word-search word-search.s
@cat [filename].txt | qemu-arm -L /usr/arm-linux-gnueabi/ word-search
@@@@@@@@@@@@@@@@@ Running Commands End @@@@@@@@@@@@@@@@@@@@@@

@@@@@@@@@@@@@@@@@ Reading Function Start @@@@@@@@@@@@@@@@@@@@@@

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@ Read a string from the terminal .
@ (only the first 1000000 characters are read)
@
@ arguments : r1 - address of string used to
@ store result
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
read_str:
push {r0-r7 , lr}
@ read a string from the terminal
mov r0 , #0 @ 0 = std input ( terminal )
ldr r2 , =#1000000 @ max num of bytes to read
mov r7 , #3 @ 3 = " read " system call
svc #0 @ make the system call
pop {r0-r7 , lr}
bx lr

@@@@@@@@@@@@@@@@@ Reading Function End @@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@@@@ Printing Functions Start @@@@@@@@@@@@@@@@@@@@@@

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@ Print the first n characters of a string
@
@ arguments : r1 - string address
@             r2 - num of characters
@ returns : ( nothing )
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
print_str_n:
push {r0-r7 , lr}
mov r0 , #1 @ r0 = output device = std output
@ r1 = string address
@ r2 = num of bytes
mov r7 , #4 @ r7 = sys call code (4 = "write ")
svc #0 @ print!
pop {r0-r7 , lr}
bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@ Print a zero terminated string
@
@ arguments : r1 - string address
@ returns : ( nothing )
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
print_str:
push {r0-r2 , lr}
bl str_length
mov r2 , r0
bl print_str_n
pop {r0-r2 , lr}
bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@ Print a newline character
@
@ arguments : ( nothing )
@ returns : ( nothing )
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
print_newline:
push {r1 , lr}
ldr r1 , =newline
bl print_str
pop {r1 , lr}
bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@ Print an integer on the screen, followed
@ by a newline character (uses C library function)
@
@ arguments : r1 - integer to be printed
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.global printf
print_num:
push {r0-r3 , lr }
ldr r0 , =fmt
bl printf
pop {r0-r3 , lr }
bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@ Print the string from the location r1 to the
@ end of the line
@
@ arguments : r1 - string address
@ returns : ( nothing )
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
print_line:
push {r0-r8, lr}
bl str_length_nc @ find the length store in r2
mov r2 , r0
bl print_str_n @ print string with r2 containing number of characters
pop {r0-r8 , lr}
bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ 
@ Print the final output
@
@ arguments : r1 - string address
@ returns : ( nothing )
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
print_output:
push {r0-r10, lr}
mov r1, r9 
bl print_num @ print current line tracker 
mov r1, r8
bl print_line @ print start of line till new charcter or end of string  
bl print_newline
pop {r0 - r10, lr}
bx lr

@@@@@@@@@@@@@@@@@ Printing Functions End @@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@@@@ Length Functions Start @@@@@@@@@@@@@@@@@@@@@@

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@ Compute the length of
@ a zero terminated string
@
@ arguments : r1 - string address
@ returns : r0 - length of string
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
str_length:
push {r1 , r2 , lr}
mov r0 , #0
str_length_loop:
ldrb r2 , [ r1 ] , #1
cmp r2 , #0
beq str_length_end
add r0 , #1
b str_length_loop
str_length_end:
pop {r1 , r2 , lr}
bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ 
@ Compute the length of a zero terminated 
@ until new character string.
@ if no new character reached print until
@ terminating character
@
@ arguments : r1 - string address
@ results : r0 - length of string until new chacter
@@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
str_length_nc:
push {r1 , r2 , lr}
mov r0 , #0 @ length counter
str_length_nc_loop :
ldrb r2 , [ r1 ] , #1
cmp r2 , #10
beq str_length_nc_end @if new character reached end loop
cmp r2 , #0
beq str_length_end @ @if end of string reached end loop
add r0 , #1 @ else increment length
b str_length_nc_loop @keep on looping until new character or end of string is reached
str_length_nc_end:
pop {r1 , r2 , lr}
bx lr

@@@@@@@@@@@@@@@@@ Length Functions End @@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@@@@ Computational Functions Start @@@@@@@@@@@@@@@@@@@@@@

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ 
@ This function returns the number of matches
@ of r1 in r2 and a tracker r9 which contains
@ the line number of matched line in r2
@
@ arguments : r1 - search string address
@             r2 - searched string address
@ returns : r3 - number of matches
@           r9 - line number of matched line
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
count_matches_perline:
push {r0 - r2, r4 - r7, lr}
bl str_length
mov r5, r0 @ find length of search string and store it in r5
sub r5, #1 @ find length - 1
mov r3, #0 @ match counter
mov r9, #1 @ current line tracker
mov r8, r2 @ Start of line Address Tracker 
loop_count_matches_perline :
bl starts_with @ Call to find if 4 characters match
cmp r0, #1  @ if match found go to match_found branch
beq match_found
match_not_found: @ else go to match_not_found branch
ldrb r4, [r2]
cmp r4, #10 @ if we r2 has not reached the end of a line 
subne r2, r5 @ we decrement r2 by length - 1 so we can see if next 4 characters (excluding the first) match 
addeq r2, #1 @ else go to next line and update Address Tracker 
moveq r8, r2 @ and increment current line tracker 
addeq r9, #1
cmp r4, #0 
beq count_matches_perline_end @ if we reached the end of the string end the loop
b loop_count_matches_perline @ else keep repeating
match_found:
add r3, r0 @ increment match counter
bl print_output @ print until new character of what's in address of r8
push {r1} @ save value of r1 in order to call find_eol
mov r1, r2 
bl find_eol 
pop {r1} @ retrieve r1
mov r2, r0 
add r2, #1 @ r2 has now reached eol so increment to go to next line 
mov r8, r2 @ update Address Tracker 
add r9, #1 @ increment current line tracker 
ldrb r4, [r2]
cmp r4, #0
beq count_matches_perline_end @ if we reached the end of the string end the loop
b loop_count_matches_perline @ else keep repeating
count_matches_perline_end :
pop {r0 - r2, r4 - r7, lr}
bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ 
@ Return the number of lines in string from the location r1
@
@ arguments : r1 - string address
@ returns : r0 - number of lines in r1
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
count_lines:
push {r1-r7 , lr}
mov r0, #1 @ Has at least one line            
loop_count_lines:
ldrb r2 , [ r1 ] , #1
cmp r2, #10 @ if new charcter reached increment
addeq r0, #1
cmp r2, #0 @ if end of string reached end the loop
beq count_lines_end
b loop_count_lines @ keep on looping till end of string is reached
count_lines_end:
pop {r1-r7 , lr}
bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@ This function returns 1 if the string in r1
@ is a prefix of the string in r29
@
@ arguments : r1 - prefix string address
@             r2 - string address
@ returns : r0 - 1 if r1 is a prefix of r2
@                0 otherwise
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
starts_with:
push {r1 ,r3 - r7, lr}
bl str_length
mov r3, r0 @ find length of search_string to find how many times to loop
mov r0, #1 @ Auto set to true
loop_starts_with :
sub r3, #1 @ decrement since iteration starts
ldrb r4, [r2], #1
ldrb r5, [r1], #1
cmp r4, r5
movne r0, #0 @ if not equal change the value to false
cmp r4, #10  @if r2 points to new character (fixes situation when a line has less characters than the search_string)
subeq r2, #1 @ we make r2 point to it
beq starts_with_end @ and end the loop
cmp r3, #0 @ end once we've loop through the length else continue looping
bne loop_starts_with
beq starts_with_end
starts_with_end :
pop {r1 ,r3 - r7, lr}
bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@ Return the address of the end
@ of the currentline, or of the end of
@ the text
@
@ arguments : r1 - address of current 
@                  location in string
@ returns : r0 - address of the next 
@                newline character, or
@                of the end of the string
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
find_eol:
push {r1 - r7, lr}
loop_find_eol :
ldrb r2, [r1], #1
cmp r2, #10 @ if r1 points to new character
subeq r1, #1 @ we make r2 point to it
moveq r0, r1 @ move the address to r0
beq find_eol_end @ end the function
cmp r2, #0 @ if r1 points to end of string
subeq r1, #1 @ we make r2 point to it
moveq r0, r1 @ move the address to r0
beq find_eol_end @ end the function
bne loop_find_eol @ keep on looping until r1 Address points to a new character or end of string
find_eol_end :
pop {r1 - r7, lr}
bx lr

@@@@@@@@@@@@@@@@@ Computational Functions End @@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@@@@ Main Function @@@@@@@@@@@@@@@@@@@@@@
.global main
main:
ldr r1 , =txt
bl read_str @ read the text from the terminal and store it in the txt string

execute_to_output:

@ count matches and print the lines
ldr r1 , =search_string
ldr r2 , =txt
bl count_matches_perline
mov r7, r3 @ r7 = num of lines that match
@ count matches and print the lines

@ print total num of lines 
ldr r1, =txt
bl count_lines
mov r6, r0 @r6 = total num of lines in file
ldr r1, =num_of_lines_str
bl print_str
mov r1, r6 
bl print_num
@ print total num of lines 

@ print matches
ldr r1, =num_of_matches_str
bl print_str
mov r1, r7
bl print_num
@ print matches

mov r7 , #1
svc #0
@@@@@@@@@@@@@@@@@ Data Directive @@@@@@@@@@@@@@@@@@@@
.data
search_string: .asciz "[search string]"
newline: .asciz "\n"
num_of_lines_str: .asciz " total num of lines : "
num_of_matches_str: .asciz "num of matches : "
fmt: .asciz "%d\n"
txt: .space 1000000 @ input text as a single string
.end
