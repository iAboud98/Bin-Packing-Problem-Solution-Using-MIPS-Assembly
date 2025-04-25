#Fadi Bassous			ID: 1221005			section: 2
#Aboud Fialah			ID: 1220216			section: 3

###################################################### data #############################################################################
.data
    	#Print on screen
    	wlc_msg:   	.asciiz 		"Welcome to Aboud and Fadi's Program\n"
    	menu1_msg: 	.asciiz 		"\nA - Read input file\nQ/q - Quit\n"
    	choice_msg:	.asciiz 		"\nChoose an operation: "
    	infile_msg:	.asciiz 		"\nEnter input file path (e.g., input.txt or C:\\Users\\YourName\\Documents\\input.txt): "
    	q_msg:     	.asciiz 		"\nThank you for using our program!\n"
    	inv_msg:   	.asciiz 		"\nError opening the file. Please check if the path is correct.\n"
    	menu2_msg: 	.asciiz 		"\nF - First Fit\nB - Best Fit\nQ/q - Quit\n"
    	menu3_msg: 	.asciiz 		"\nP - Print result to output file\nQ/q - Quit\n"
   	res_msg:   	.asciiz 		"\nDone! Results saved in the output file.\n"
	wrg_msg:   	.asciiz 		"\n\n!!! Wrong input !!!\n"
	end_msg:    	.asciiz			"\nPacking Completed Successfully!\n"
	error_msg: 	.asciiz			"\nwrong input in input file\n"
	
	#Output File
	out_filename:      	.asciiz 	"output.txt"
	header_line1:      	.ascii 		"============================================\n"
	header_title:      	.ascii 		"        Bin Packing Results Report         \n"
	header_line2:      	.ascii 		"===========================================\n\n"
	algorithm_label:   	.ascii 		">> Algorithm Used for Bin Packing	: "
	FF:			.ascii 		"First Fit\n"
	BF:			.ascii 		"Best Fit \n"
	bins_label:		.ascii 		">> Minimum Number of Required Bins	: "
	bins_line:  		.ascii 		"\n____________________________________________"
	bin_prefix:        	.ascii 		"\n\n Bin ("
	bin_postfix:		.ascii 		") :\n\n-----------------"
	bin_capacity_start:	.ascii 		"\n\n-> Used Capacity : "
	line_between_bins:	.ascii 		"\n\n==============================="
	bin_capacity_end:	.ascii 		" / 1.0 ]"
	item_format_part1: 	.ascii 		"\n   | Item #"
	item_format_part2: 	.ascii 		"\n   | Size = "
	line_between_items: 	.ascii 		"\n-----------------"
	zero_point:		.ascii 		"0."
	one_point:		.ascii 		"1.00"

	
	.align 2
	bins_count:		.space 64
	bins_index:		.space 64
	ascii_item_index:	.space 64
	ascii_item_size: 	.space 64
	int_buffer: 		.space 12
	
	

	#Read from user
	file_path: 		.space 100	#100 bytes for file_path
	buffer: 		.space 1024  	#1024 for file content
	
	#Constants
	zero_float:		.float 0
	one_float: 		.float 1.0
	one_hundred: 		.float 100.0
	
	#Arrays
	.align 2
	items_list: 		.space 1024 	#array of items
	bins_size_list: 	.space 1024 	#array of bins (holds bins size)

	bins_list: 		.space 40000  	#2D array of bins (holds items indices for each bin) 
						#offset = (row * 100 + col) * 4 
						#100 x 100 x 4 bytes = 40,000 bytes
	
################################################### Code segment ########################################################################
.text
.globl main

main:
	la $a0, wlc_msg 			#load wlc_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
menu1:
	la $a0, menu1_msg 			#load menu1_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall

	la $a0, choice_msg 			#load choice_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall

	li $v0, 12				#12 --> Read Char
	syscall 
	
	
	move $t0, $v0   			#move char in $v0 to $t0
	ori $t0,$t0,0x20 			#converte to small letter(0x20 = 32)
	beq $t0,'q', quit			#compare between user input and 'q'
	beq $t0,'a', input_file  		#compare between user input and 'a'
	
	
	la $a0, wrg_msg 			#load wrg_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
	
	j menu1
	

input_file:
	
	la $a0, infile_msg 			#load infile_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall

	la $a0, file_path			#load file_path address to $a0 
	li $a1, 100				#maximum number of characters to read
	li $v0, 8				#8 --> Read String
	syscall
	
	la $t0, file_path			#load file_path address to $t0
	
get_newline_index:				#label to get the index of '/n'
	lb $t1, 0($t0)				#load the char placed in address $t0 (first index of filename) 
	beq $t1, 0xA remove_newline		#compare the value of $t1 with '/n'
	add $t0, $t0, 1				#increase $t0 by 1 (move to the next character)
	j get_newline_index			#loop until '/n' is found

remove_newline:
	sb $zero, 0($t0)			#replace '/n' with '/0'
	
	#file_path address already in $a0
	li $a1, 0               		#read-only mode
    	li $v0, 13              		#13-> open file
    	syscall

    	bltz $v0, error_file    		#if file descriptor < 0, go to error handling

    	move $s3, $v0           		#save file descriptor to $s3

    	#read file

    	move $a0, $s3           		#file descriptor
    	la $a1, buffer          		#buffer to read into
    	li $a2, 1024            		#$a2 -> max number of characters to read
    	li $v0, 14              		#14 -> read from file
    	syscall

    	#close file after reading
    	move $a0, $s3           		#file descriptor
    	li $v0, 16              		#16 -> close file
    	syscall
	
	la $t0, buffer				#load address to $t0
	la $t8, items_list			#load address to $t8
repeat:	
	li $t2, 0    				#$t2 -> number after the decimal
	li $t3, 48				#$t3 -> '0' in ASCII
	li $t4, 0				#$t4 -> number counter
	
	
	lb $t1, 0($t0) 				#load the first byte (number) in ASCII
	li $t9,48				#$t9 -> 48
	bne $t1,$t9, error_input		#check if the values in input file greater then 0.99


	addi $t0, $t0, 2			#skip '.'
	
	
convert_to_int:
	lb $t6, 0($t0) 				#$t6 holds numbers in ASCII form
	beq $t6, 0xA, convert_to_float		#compare with '/n'
	beq $t6, 0, convert_to_float		#compare with '/0'
	
	sub $t6, $t6, $t3			#convert from ASCII to real integer
	mulu $t2, $t2,10			#multiply $t2 by 10
	add  $t2, $t6, $t2			#accomulate the number in $t2
	addi $t0, $t0, 1			#move to the next digit
	addi $t4, $t4, 1			#accomulate counter (digit counter)
	j convert_to_int			#repeat loop
	
convert_to_float:
	li $t7, 1       			#initialize power accumulator (10^t4)
power:
    	beqz $t4, continue_to_float 		#if exponent is 0, move to float conversion
    	mulu $t7, $t7, 10  			#multiply $t7 by 10
    	sub $t4, $t4, 1  			#decrease by 1
    	j power           			#repeat loop

continue_to_float:
    	mtc1 $t2, $f0     			#move integer value in $t2 to floating-point register $f0
    	cvt.s.w $f0, $f0  			#convert integer to float

    	mtc1 $t7, $f2				#move 10^t4 value to floating-point register $f2
    	cvt.s.w $f2, $f2  			#convert integer to float

    	div.s $f0, $f0, $f2 			#xy/10^2 (for example) =0.xy 

	swc1 $f0,0($t8)				#store float number from $f1 to memory (items_list) 
    	addi $t8, $t8, 4			#increment the address by 4 (next index) 
	lb $t6, 0($t0)				#load the character from memory (buffer) to $t6
	beq $t6, 0 , menu2			#check if we reached end of file ('/0')
	addi $t0, $t0, 1			#increment the address by 1 (next character)
	j repeat				#repeat loop


menu2:						#menu to choose algorithms
	la $a0, menu2_msg 			#load menu2_msg address to $a0
	li $v0, 4				#4 --> Print String
	syscall				

	la $a0, choice_msg 			#load choice_msg address to $a0 
	li $v0, 4				#4 --> Print String
	syscall

	li $v0,12				#12 --> Read Char
	syscall
	
	move $t0, $v0				#move char in $v0 to $t0
	ori $t0, $t0, 0x20			#converte to small letter(0x20 = 32)
	beq $t0, 'f', first_fit			#compare between user input and 'f'
	beq $t0, 'b', best_fit			#compare between user input and 'b'
	beq $t0, 'q', quit			#compare between user input and 'q'
	
	la $a0, wrg_msg 			#load wrg_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
	
	j menu2 

menu3:
	la $a0,menu3_msg 			#load menu3_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall

	la $a0,choice_msg 			#load choice_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall

	li $v0, 12				#12 --> Read Char
	syscall 
	
	move $t0, $v0   			#move char in $v0 to $t0	
	ori $t0,$t0,0x20 			#converte to small letter(0x20 = 32)
	beq $t0,'q', quit			#compare between user input and 'q'
	beq $t0,'p', write_on_file  		#compare between user input and 'p'
	
	la $a0, wrg_msg 			#load wrg_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
	
	j menu3	

######################################################### FIRST FIT ###########################################################################

first_fit:
	jal reset_bins         			#at first we rest bins info in case of iterative usage
	
	la $s5, FF				#flag to print the type of algorithm on output file

	la $t0, items_list			#$t0 --> items_list pointer
	la $t1, bins_size_list			#$t1 --> bins_size_list pointer
	li $s4, 1                 		#$t3 --> bins counter
	li $t4, 1				#$t4 --> current index of items
	li $t5, 0				#$t5 --> current index of bins
	
	move $s0, $t0				#$s0 --> address of first item index
	move $s1, $t1				#$s1 --> address of first bin index
	la $s2, bins_list			#$s2 --> bins_list pointer
	
	l.s $f6, one_float    			#This loads 1.0 into $f0
    	swc1 $f6, 0($t1)      			#Store $f6 into memory at address in $t1
    					

check_bin:
	
	lw $t8, 0($t0)				#Check end of file
	beq $t8, 0, menu3			#branch to MENU3
	
    	lwc1 $f0, 0($t0)			#load item size into $f0
    	lwc1 $f2, 0($t1)			#load bin size into $f2
		
		c.eq.s $f2, $f0              # compare to zero
		bc1t skip_bin_ff             # if exactly 0.0, skip

    	c.le.s $f0, $f2     			#Compare if $f0 <= $f2 and make flag cc to 0
    	bc1t add_item      	 		#If true (cc = 0), branch to add_item
    
    	addi $t1, $t1, 4			#move to the next bin
    	lw $t7, 0($t1)				
    	beq $t7, 0, create_bin			#create new bin if $t7 == '/0'
    	j check_bin
skip_bin_ff:
  addi $t1, $t1, 4
  j check_bin  


add_item:
	
	lwc1 $f2, 0($t1)             # Reload correct bin capacity
	sub.s $f2, $f2, $f0
	swc1 $f2, 0($t1)
	sub $t4, $t0, $s0			#$t4 --> index of current item (multiple by 4)
	divu $t4, $t4, 4			#divide $t4 by 4 to get the real index
	addi $t4, $t4, 1			#to make the index of item starts at 1 not 0
	
	
	sub $t5, $t1, $s1
	divu $t5, $t5, 4			#divide $t5 by 4 to get the real index


	jal add_item_to_bin_list		#add to bins_list (2D Array)
	
	addi $t0, $t0, 4			#move to the next item 
	
	move $t1, $s1				#reset to the first bin
	
	
	j check_bin

create_bin:
	
	l.s $f6, one_float    			#This loads 1.0 into $f0
    	swc1 $f6, 0($t1)      			#Store $f0 into memory at address in $t1 (the new bin)

	addi $s4, $s4, 1			#increament bins counter by 1
	
	j check_bin

add_item_to_bin_list:
	mul $t7, $t5, 100			
	mul $t7, $t7, 4  
	add $t2, $s2, $t7

find_index:
	lb $t9, 0($t2)				
	beq $t9, 0, found_index			#check if index is empty
	add $t2, $t2, 4				#if not empty move to next index

	j find_index

found_index:
	sb $t4, 0($t2)				#store the index of item in bin_list
 	jr $ra 					#return

########################################################### BEST FIT ###########################################################################


best_fit:
	jal reset_bins				#at first we rest bins info in case of iterative usage
	la $s5, BF				#flag to print the type of algorithm on output file

	la $t0, items_list			#$t0 --> items_list pointer
	la $t1, bins_size_list			#$t1 --> bins_size_list pointer
	li $s4, 1                 		#$t3 --> bins counter
	li $t4, 1				#$t4 --> current index of items
	li $t5, 0				#$t5 --> current index of bins

	l.s $f4, one_float			#min compare
	move $t3, $t1				#$t3 --> min item index of bins
	
	move $s0, $t0				#$s0 --> address of first item index
	move $s1, $t1				#$s1 --> address of first bin index
	la $s2, bins_list			#$s2 --> bins_list pointer
	
	l.s $f6, one_float    			#This loads 1.0 into $f0
    	swc1 $f6, 0($t1)      			#Store $f6 into memory at address in $t1
    					

check_bin_bf:
	
	lw $t8, 0($t0)				#Check end of file
	beq $t8, 0, menu3			#branch to MENU3
	
    	lwc1 $f0, 0($t0)			#load item size into $f0
    	lwc1 $f2, 0($t1)			#load bin size into $f2
		c.eq.s $f2, $f0              # compare to 0.0
	bc1t move_to_next_bin        # skip full bins

	c.lt.s $f0,$f2				#check if it fits in this bin (f0 < f2)
	bc1f move_to_next_bin			#if not -> move to the next bin
    	sub.s $f1,$f2,$f0			#if it fits -> we check if its the best match 
	c.lt.s $f1, $f4				#check if less than min
	bc1f move_to_next_bin			#if not -> move to the next bin
	mov.s $f4,$f1				#if yes -> make it the new min
	move $t3,$t1
	
move_to_next_bin:
    	addi $t1, $t1, 4			#move to the next bin
		

		sub $t7, $t1, $s1           # how far we've moved from start
	li $t6, 400                 # 100 bins * 4 bytes each
	bge $t7, $t6, check_min     # if out of bounds, jump to check_min

	lw $t7, 0($t1)	
    	beq $t7, 0, check_min			#check min if $t7 == '/0'
	j check_bin_bf

check_min:
	lwc1 $f3,one_float			#$f3 -> 1.0

	c.eq.s  $f4, $f3			#if the min was 1.0 (which means the item doesn't fit in any bin)
	bc1t create_bin_bf			#-> we create new bin

 	j add_item_bf
 
    	
add_item_bf:
	
	lwc1 $f2, 0($t3)
	sub.s $f2, $f2, $f0
	swc1 $f2, 0($t3)
	
	sub $t4, $t0, $s0			#$t4 --> index of current item (multiple by 4)
	divu $t4, $t4, 4			#divide $t4 by 4 to get the real index
	addi $t4, $t4,1
	
	
	sub $t5, $t3, $s1
	divu $t5, $t5, 4			#divide $t5 by 4 to get the real index
	
	jal add_item_to_bin_list_bf		#add to bins_list
	
	addi $t0, $t0, 4			#move to the next item 
	
	move $t1, $s1				#reset to the first bin
	l.s $f4, one_float			#min compare
	move $t3, $t1				#$t3 --> min item index of bins
	
	j check_bin_bf

create_bin_bf:
	
	l.s $f6, one_float    			#This loads 1.0 into $f0
    	swc1 $f6, 0($t1)      			#Store $f0 into memory at address in $t1 (the new bin)

	addi $s4, $s4, 1			#increament bins counter by 1
	
	j check_bin_bf

add_item_to_bin_list_bf:

	mul $t7, $t5, 100			
	mul $t7, $t7, 4  
	add $t2, $s2, $t7

find_index_bf:
	lb $t9, 0($t2)				
	beq $t9, 0, found_index_bf		#check if index is empty
	add $t2, $t2, 4				#if not empty move to next index
	j find_index_bf

found_index_bf:
	sb $t4, 0($t2)				#store the index of item in bin_list
 	jr $ra 					#return
	
	j menu3

################################################################## WRITE ON FILE ##################################################################################
write_on_file:

#first we clear the output file

	la $a0, out_filename   
	li $a1, 9              			#write-only
	li $v0, 13             			#13-> open file
	syscall

	bltz $v0, error_file   			

	move $a0, $v0          			#$a0 -> file descriptor
	li $v0, 16             			#16 -> close file
	syscall
	
	la $a0, out_filename
	la $a1, 1
	li $v0, 13				#13 -> open file
	syscall
	
	bltz $v0, error_file			#branch to error_file if $v0 is negative
	move $s3, $v0				#$s3 -> file descriptor

	move $a0, $s3				#print header_line1 on file
	la $a1, header_line1			#load header_line1 address onto $a1
	li $a2, 46				#$a2 --> size of header_line1
	li $v0, 15					
	syscall

	move $a0, $s3				#print header_title on file
	la $a1, header_title			#load header_title address onto $a1
	li $a2, 45				#$a2 --> size of header_title
	li $v0, 15				
	syscall

	move $a0, $s3				#print header_line2 on file
	la $a1, header_line2			#load header_line2 address onto $a1
	li $a2, 45				#$a2 --> size of header_line2
	li $v0, 15				#write on file
	syscall

	move $a0, $s3				#print algorithm_label on file
	la $a1, algorithm_label			#load algorithm_label address onto $a1
	li $a2, 36				#$a2 --> size of algorithm_label
	li $v0, 15					
	syscall

	move $a0, $s3				#print algorithm name (BF OR FF) on file
	la $a1, 0($s5)				#load address saved in $s5 (BF OR FF)
	li $a2, 10				#$a2 --> size of algorithm name
	li $v0, 15					
	syscall

	move $a0, $s3				#print bins_label on file
	la $a1, bins_label			#load bins_label address onto $a1
	li $a2, 37				#$a2 --> size of bins_label
	li $v0, 15					
	syscall
	
	move $a0,$s4				#$s4 -> bins counter
	move $t1,$s4
	jal  int_to_string     			#call the function	
	

	move $a0, $s3				#print bins_count on file
	la $a1, 0($v0)				#load bins_count address onto $a1
	li $a2, 2				#$a2 --> size of bins_count
	li $v0, 15				#write on file
	syscall
	
	move $a0, $s3				#print bins_line on file
	la $a1, bins_line			#load bins_line address onto $a1
	li $a2, 45				#$a2 --> size of bins_line
	li $v0, 15				#write on file
	syscall

################################################################# Print Bins & Items ###############################################################################
	
	li $t2, 0				#$t2 is a bin index initialized to  $t2 -> 0 (ASCII)
	la $t5, bins_list			#$t5 is bins pointer in 2D Array

	
bins_loop:

	
	l.s $f20, zero_float
	move $t4, $t5				#$t4 is items pointer in 2D Array


	move $a0, $s3				#print bin_prefix on file
	la $a1, bin_prefix			#load bin_prefix address onto $a1
	li $a2, 8				#$a2 --> size of bin_prefix
	li $v0, 15					
	syscall
	
		
	move $a0, $t2
	jal  int_to_string     			#call the function	

	move $a0, $s3				#print bins_index on file
	la $a1, 0($v0)				#load bins_index address onto $a1
	li $a2, 1				#$a2 --> size of bins_index
	li $v0, 15					
	syscall
	
	move $a0, $s3				#print bin_postfix on file
	la $a1, bin_postfix			
	li $a2, 22				
	li $v0, 15					
	syscall
	

items_loop:
	
	li $s7, 0				#$s7 -> flag to distinguish between writing item size and bin capacity
			
	move $a0, $s3				#print item_format_part1 on file
	la $a1, item_format_part1		
	li $a2, 12				
	li $v0, 15					
	syscall
	
						
	lw $t6, 0($t4)				#$t6 address of item in bins_list 
	move $a0, $t6
	jal  int_to_string     			#call the function	

	move $a0, $s3				#print ascii_item_index on file
	la $a1, 0($v0)				#load ascii_item_index address onto $a1
	li $a2, 2				#$a2 --> size of ascii_item_index
	li $v0, 15					
	syscall

	move $a0, $s3				#print item_format_part2 on file
	la $a1,	item_format_part2		
	li $a2, 13				
	li $v0, 15					
	syscall
	
	move $a0, $s3				#print zero_point on file
	la $a1, zero_point
	li $a2, 2
	li $v0, 15
	syscall
	
	la $t9, items_list			#$t9 -> address of item_list
	subi $t6, $t6, 1			#$t6 -> holds the current item number (decrease by one because we increased it before !)
	mul $t6, $t6, 4				
	add $t9, $t9, $t6
	l.s $f8, 0($t9)				#$f8 -> item size

	add.s $f20, $f20, $f8			#$f20 -> accumulate bin size

	j float_to_string

print_item_size:
	#print ascii_item_size on file

	move $a0, $s3				#$s3 contains the address of output file (where to write)
	la $a1, 0($v0)				#load ascii_item_size address onto $a1
	li $a2, 64				#$a2 --> size of ascii_item_index
	li $v0, 15					
	syscall
	
	move $a0, $s3				#print line_between_items on file
	la $a1,	line_between_items		
	li $a2, 18				
	li $v0, 15					
	syscall
	
	addi $t4, $t4, 4			#move to the next item in same bin
	lw $t6, 0($t4)				#$t6 --> address of current item
	bne $t6, 0, items_loop			#if we didn't reach the end, repeat
	
	move $a0, $s3				#print bin_capacity_start on file
	la $a1, bin_capacity_start		
	li $a2, 21				
	li $v0, 15					
	syscall
	
	cvt.w.s $f30, $f20    			#$f30 holds either 0 or 1
	mfc1 $s6, $f30				#$f30 -> $s6
	
	bnez $s6, print_one			#if the capacity is full ( 1.0 )
	
	move $a0, $s3				#print zero_point on file
	la $a1, zero_point
	li $a2, 2
	li $v0, 15
	syscall
	
	li $s7, 1				#$s7 -> flag to distinguish item size of capacity of bin
	mov.s $f8, $f20
	j float_to_string

	
print_bin_capacity:

	move $a0, $s3				#print capacity of bin
	la $a1, 0($v0)				
	li $a2, 64					
	li $v0, 15					
	syscall
	
after_one:

	move $a0, $s3				#print line_between_bins on file
	la $a1, line_between_bins		
	li $a2, 33				
	li $v0, 15					
	syscall

	subi $t1, $t1, 1			#decrease bin counter to break the loop
	addi $t2, $t2, 1			#bin index counter
	addi $t5, $t5, 400			#move to the next bin
	

	bnez $t1, bins_loop			#repeat until counter reaches 0

################################################################ END OF BINS & ITEMS #############################################################################

	move $a0, $s3				#print bins_line on file
	la $a1, bins_line			
	li $a2, 48				
	li $v0, 15
	syscall

	la $a0, end_msg				#print end_msg on I/O window
	li $v0, 4
	syscall
	
	
	move $a0, $s3        			#file descriptor (output file)
    	li $v0, 16           			#16 -> close file
    	syscall


    	j menu1					#loop again
##################################################################### END OF SEQUENCE ###########################################################################


####################################################################### FUNCTIONS ###############################################################################

int_to_string:
    	li     $t0, 10                 		#divisor = 10
    	la     $v0, int_buffer         		#$v0 = start of buffer
    	addiu  $v1, $v0, 11           		#$v1 = end of buffer
    	sb     $zero, 0($v1)           		#place null terminator

    	move   $t8, $a0                		#move the input number to $t2

itoa_loop:
    	divu   $t8, $t0                		#divide $t2 / 10
    	mflo   $t8                     		#quotient -> $t2
   	mfhi   $t7                    		#remainder (digit)
    	addiu  $t7, $t7, 48            		#convert digit to ASCII
    	addiu  $v1, $v1, -1            		#move pointer back
    	sb     $t7, 0($v1)             		#store character
    	bnez   $t8, itoa_loop          		#loop if not zero

    	move $v0, $v1                  		#return pointer to start of string
    	jr   $ra

float_to_string:
	lwc1 $f12, one_hundred      		#$f12 = 100.0
	mul.s $f8, $f8, $f12        		#$f8 = 0.788123 * 100 = 78.8123
	cvt.w.s $f8, $f8            		#$f8 = truncate(78.8123) = 78
	mfc1 $a0, $f8               		#$t5 = 78
	jal int_to_string
	beqz $s7, print_item_size
	j print_bin_capacity

reset_bins:					#Clear bins_size_list
	la $t0, bins_size_list
	li $t1, 0

clear_bins_sizes:
	li $t2, 0
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	li $t3, 100
	blt $t1, $t3, clear_bins_sizes

	# Clear bins_list (2D)
	la $t0, bins_list
	li $t1, 0

clear_bins_2d:
	li $t2, 0
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	li $t3, 10000          			#100x100 = 10,000 entries
	blt $t1, $t3, clear_bins_2d

	# Reset bin counter
	li $s4, 1              			#bin count starts at 1 (1st bin exists)

	jr $ra

print_one:					#to print (1.0 capacity)

	move $a0, $s3
	la $a1, one_point
	li $a2, 4
	li $v0, 15
	syscall
	
	j after_one

error_input:
	la $a0, error_msg			#load error_msg address to $a0
	li $v0, 4				#4 --> Print String
	syscall
	j quit					#branch back to menu1

error_file:   					#error opening file
	la $a0, inv_msg				#load inv_msg address to $a0
	li $v0, 4				#4 --> Print String
	syscall
	j menu1					#branch back to menu1
	
quit:	 
	la $a0, q_msg 				#load q_msg address to $a0 
	li $v0, 4 				#4 --> Print String
	syscall
	
	li $v0, 10				#Exit program
	syscall
