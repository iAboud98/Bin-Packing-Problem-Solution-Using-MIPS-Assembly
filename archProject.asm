#Fadi Bassous 1221005
#Abedalrheem Fialah 1220216

###################################################### data #############################################################################
.data
    # Print on screen
    wlc_msg:   .asciiz "Welcome to Aboud and Fadi's Program\n"
    menu1_msg: .asciiz "\nA - Read input file\nQ/q - Quit\n"
    choice_msg:.asciiz "\nChoose an operation: "
    infile_msg:.asciiz "\nEnter input file path (e.g., input.txt or C:\\Users\\YourName\\Documents\\input.txt): "
    q_msg:     .asciiz "\nThank you for using our program!\n"
    inv_msg:   .asciiz "\nError opening the file. Please check if the path is correct.\n"
    menu2_msg: .asciiz "\nF - First Fit\nB - Best Fit\nQ/q - Quit\n"
    menu3_msg: .asciiz "\nP - Print result to output file\nQ/q - Quit\n"
    res_msg:   .asciiz "\nDone! Results saved in the output file.\n"
	wrg_msg:   .asciiz "\nwrong input!"
	first_msg: .asciiz "\nWelcome to first fit algorithms"
	best_msg: .asciiz "\nWelcome to best fit algorithms"

	#Read from user
	file_path: .space 100		#100 bytes for file_path
	buffer: .space 1024  		#1024 for file content
	
	#Array
	.align 2
	items_list: .space 1024 	#array of items

	
################################################### Code segment ########################################################################
.text
.globl main

main:
	la $a0,wlc_msg 			#load wlc_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
menu1:
	la $a0,menu1_msg 		#load menu1_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall

	la $a0,choice_msg 		#load choice_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall

	li $v0, 12				#12 --> Read Char
	syscall 
	
	move $t0, $v0   			#move char in $v0 to $t0	
	ori $t0,$t0,0x20 			#converte to small letter(0x20 = 32)
	beq $t0,'q' quit			#compare between user input and 'q'
	beq $t0,'a' input_file  	# compare between user input and 'a'
	j invalid_choice			#jump to invalid choice label
	
quit:	 
	la $a0, q_msg 			#load q_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
	
	li $v0, 10				#Exit program
	syscall

input_file:
	la $a0, infile_msg 		#load infile_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall

	la $a0, file_path		#load file_path address to $a0 
	li $a1, 100				#maximum number of characters to read
	li $v0, 8				#8 --> Read String
	syscall
	
	la $t0, file_path				#load file_path address to $t0
get_newline_index:					#label to get the index of '/n'
	lb $t1, 0($t0)					#load the char placed in address $t0 (first index of it) 
	beq $t1, 0xA remove_newline		#compare the value of $t1 with '/n'
	add $t0, $t0, 1					#increase $t0 by 1 (move to the next character)
	j get_newline_index				#loop until '/n' is found

remove_newline:
	sb $zero, 0($t0)				#replace '/n' with '/0'
	
	#file_path address already in $a0
	li $a1, 0					#0 --> read-only flag
	li $v0, 13					#13 --> open file
	syscall
	
	bltz $v0, error_file		#branch to error_file if $v0 is negative
	
	move $a0, $v0 				#move file descriptor from $v0 to $a0
	
	la $a1, buffer				#load buffer address to $a1
	li $a2, 1024				#load maximum number of characters to read to $a2
	li $v0, 14					#14 --> Read File
	syscall
	la $t0, buffer				#load address to $t0
	la $t8, items_list			#load address to $t8
repeat:	
	li $t2, 0    		#number after the decimal
	li $t3, 48			#'0' in ASCII
	li $t4, 0			#number counter
	
	
	lb $t1, 0($t0) 		#load the first byte (number) in ASCII
	#handle error (possible!!!)
	addi $t0, $t0, 2			#skip '.'
	
	
convert_to_int:
	lb $t6, 0($t0) 		#$t6 holds numbers in ASCII form
	beq $t6, 0xA, convert_to_float		#compare with '/n'
	beq $t6, 0, convert_to_float		#compare with '/0'
	
	sub $t6, $t6, $t3					#convert from ASCII to real integer
	mulu $t2, $t2,10						#multiply $t2 by 10
	add  $t2, $t6, $t2					#accomulate the number in $t2
	addi $t0, $t0, 1					#move to the next digit
	addi $t4, $t4, 1					#accomulate counter (digit counter)
	j convert_to_int					#repeat loop
	
	#982
convert_to_float:
    li $t7, 1        #initialize power accumulator (10^t4)
power:
    beqz $t4, continue_to_float 	#if exponent is 0, move to float conversion
    mulu $t7, $t7, 10  				#multiply $t7 by 10
    sub $t4, $t4, 1  				#decrease by 1
    j power           				#repeat loop

continue_to_float:
    mtc1 $t2, $f1     		#move integer value in $t2 to floating-point register $f0
    cvt.s.w $f1, $f1  		#convert integer to float

    mtc1 $t7, $f3			#move 10^t4 value to floating-point register $f2
    cvt.s.w $f3, $f3  		#convert integer to float

    div.s $f1, $f1, $f3 	#xy/10^2 (for example) =0.xy 
	
	 
	swc1 $f1,0($t8)			#store float number from $f1 to memory (items_list) 
    addi $t8, $t8, 4		#increment the address by 4 (next index) 
	lb $t6, 0($t0)			#load the character from memory (buffer) to $t6
	beq $t6, 0 , quit		#check if we reached the new line ('\n')
	addi $t0, $t0, 1		#increment the address by 1 (next character)
	j repeat				#repeat loop
    j quit


menu2:							#menu to choose algorithms
	la $a0, menu2_msg 			#load menu2_msg address to $a0
	li $v0, 4					#4 --> Print String
	syscall				

	la $a0, choice_msg 			#load choice_msg address to $a0 
	li $v0, 4					#4 --> Print String
	syscall

	li $v0,12					#12 --> Read Char
	syscall
	
	move $t0, $v0				#move char in $v0 to $t0
	ori $t0, $t0, 0x20			#converte to small letter(0x20 = 32)
	beq $t0, 'f', first_fit		#compare between user input and 'f'
	beq $t0, 'b', best_fit		#compare between user input and 'b'
	beq $t0, 'q', quit			#compare between user input and 'q'
	j invalid_choice			#jump to invalid choice label 
	
	
error_file:   	#error opening file
	la $a0, inv_msg			#load inv_msg address to $a0
	li $v0, 4				#4 --> Print String
	syscall
	j menu1					#branch back to menu1

invalid_choice:			#invalid character choice
	la $a0, wrg_msg 		#load wrg_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
	j menu1
	
q:				#by fadi
	la $a0, wlc_msg
	li $v0, 4
	syscall

first_fit:
	la $a0, first_msg
	li $v0, 4
	syscall
	j quit
best_fit:
	la $a0, best_msg
	li $v0, 4
	syscall
	j quit