#Fadi Bassous 1221005
#Abedalrheem Fialah 1220216

.data
    # Print on screen
    wlc_msg:   .asciiz "Welcome to Aboud and Fadi's Program\n"
    menu1_msg: .asciiz "A - Read input file\nQ/q - Quit\n"
    choice_msg:.asciiz "Choose an operation: "
    infile_msg:.asciiz "Enter input file path (e.g., input.txt or C:\\Users\\YourName\\Documents\\input.txt):\n"
    q_msg:     .asciiz "Thank you for using our program!\n"
    inv_msg:   .asciiz "Error opening the file. Please check if the path is correct.\n"
    menu2_msg: .asciiz "F - First Fit\nB - Best Fit\nQ/q - Quit\n"
    menu3_msg: .asciiz "P - Print result to output file\nQ/q - Quit\n"
    res_msg:   .asciiz "Done! Results saved in the output file.\n"


