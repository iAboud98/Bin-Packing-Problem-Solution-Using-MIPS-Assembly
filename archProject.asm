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

	#Read from user
	file_path: .space 100
	
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
	
	move $t0, $v0   		#move char in $v0 to $t0	
	ori $t0,$t0,0x20 		#converte to small letter(0x20 = 32)
	beq $t0,'q' quit		#compare between user input and 'q'
	beq $t0,'a' input_file  # compare between user input and 'a'
	b error
	
quit:	 
	la $a0, q_msg 			#load q_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
	
	li	$v0, 10				#Exit program
	syscall

input_file:
	la $a0, infile_msg 		#load infile_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall

	la $a0, file_path		#load file_path address to $a0 
	li $a1, 100				#maximum number of characters to read
	li $v0, 8				#8 --> Read String
	syscall
	
	
error:
	la $a0, wrg_msg 		#load wrg_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
	b menu1

