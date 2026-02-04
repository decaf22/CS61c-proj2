.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    # open
    addi sp sp -4
    sw ra 0(sp)
    
    addi sp sp -8
    sw a1 0(sp)
    sw a2 4(sp) # a1 a2 are given, store them, they are pointers
    li a1 0
    jal ra fopen # a0 is descriptor of the file
    li t0 -1
    beq a0 t0 malopen
    lw a1 0(sp)
    lw a2 4(sp) 
    addi sp sp 8
    
    
    # read the first 2 integers. We can read 2 times, 1st time row, 2nd time col
    addi sp sp -12
    sw a0 0(sp) # descriptor
    sw a1 4(sp) # row address
    sw a2 8(sp) # col address
    
    
    li a2 4
    jal ra fread # a1 points to the read bytes in malloc
    li t0 4
    bne a0 t0 malread # row number written to 0(a1)
    # 2nd read
    li a2 4
    lw a0 0(sp)
    lw a1 4(sp) # first pull this value out
    lw a3 0(a1) #store n(row) to a3
    addi sp sp -4
    sw a3 0(sp) # now stack: 0 n(row), 4 descriptor, 8 row add, 12 col add
    lw a1 12(sp) # a1 is col num address
    jal ra fread
    li t0 4
    bne a0 t0 malread # col number written to 0(a1)
    
    lw a1 12(sp)
    lw a2 0(a1) # a2 is n(col)
    lw a3 0(sp)
    addi sp sp 4 # now stack: 0 descriptor, 4 row add, 8 col add
    mv a1 a3 # a1 is n(row)
    lw a0 0(sp) # a0 is descriptor
    addi sp sp 12
    
    
    addi sp sp -4
    sw a0 0(sp) # store descriptor
    mul a0 a1 a2
    slli a0 a0 2 # space need to be allocated: row*col*4 bytes
    addi sp sp -4
    sw a0 0(sp) # stores the matrix size
    jal ra malloc
    beq a0 x0 malmalloc # a0 is the memory address
    
    # call fread again to read the whole matrix
    mv a1 a0 # a1 stores the heap address, and this is also what we will return
    addi sp sp -4
    sw a1 0(sp) # stack: 0 mat address 4 matrix size 8 descriptor
    lw a2 4(sp) # a2 is the mat size
    lw a0 8(sp) # a0 is descriptor
    
    jal ra fread
    lw a2 4(sp)
    
    bne a0 a2 malread
    
    #close the file
    
    lw a0 8(sp) # descriptor
    lw a1 0(sp)
    addi sp sp 12
    addi sp sp -4
    sw a1 0(sp)
    
    jal ra fclose
    bne a0 x0 malclose
    lw a0 0(sp) #returns the mat address
    
    addi sp sp 4

    # Epilogue
    
    lw ra 0(sp)
    addi sp sp 4
    jr ra
    
    
malopen:
    li a0 27
    j exit
malmalloc:
    li a0 26
    j exit
malread:
    li a0 29
    j exit
malclose:
    li a0 28
    j exit