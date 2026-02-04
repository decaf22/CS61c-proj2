.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    addi sp sp -8
    sw ra 0(sp) # save ra
    sw s0 4(sp) # s0 stores descriptor of matrix, which will often be used

    # Prologue
    # open the file----------------------------
    addi sp sp -12
    sw a1 0(sp) # add of mat
    sw a2 4(sp) # n(row)
    sw a3 8(sp) # n(col)
    
    li a1 1 # write-only
    jal ra fopen
    li t0 -1
    beq a0 t0 malopen
    mv s0 a0 # s0 now stores descriptor
    lw a1 0(sp)
    lw a2 4(sp)
    lw a3 8(sp)
    addi sp sp 12
    
    # write num of rows-------------------------
    addi sp sp -12
    sw a1 0(sp) # add of mat
    sw a2 4(sp) # n(row)
    sw a3 8(sp) # n(col)
    li a0 4
    jal ra malloc
    # write n(row) to the newly allocated address
    lw a2 4(sp)
    sw a2 0(a0)
    
    mv a1 a0 # a1 is now *void, the allocated address
    mv a0 s0 # a0 is descriptor
    li a2 1 # the number of elements
    li a3 4 # the size of each element
    jal ra fwrite
    li a2 1
    bne a0 a2 malwrite
    
    lw a1 0(sp)
    lw a2 4(sp)
    lw a3 8(sp)
    addi sp sp 12
    
    # write num of cols-------------------------
    addi sp sp -12
    sw a1 0(sp) # add of mat
    sw a2 4(sp) # n(row)
    sw a3 8(sp) # n(col)
    li a0 4
    jal ra malloc
    # write n(col) to the newly allocated address
    lw a3 8(sp)
    sw a3 0(a0) # store a3 to the newly allocated add
    
    mv a1 a0 # a1 is now *void, the allocated address
    mv a0 s0 # a0 is descriptor
    li a2 1 # the number of elements
    li a3 4 # the size of each element
    jal ra fwrite
    li a2 1
    bne a0 a2 malwrite
    
    lw a1 0(sp)
    lw a2 4(sp)
    lw a3 8(sp)
    addi sp sp 12
    # write the whole matrix-------------------------------
    addi sp sp -12
    sw a1 0(sp) # add of mat
    sw a2 4(sp) # n(row)
    sw a3 8(sp) # n(col)
    mul t1 a2 a3 # number of elements in the matrix
    mv a0 s0 # descriptor
    lw a1 0(sp)
    mv a2 t1
    li a3 4
    jal ra fwrite
    lw a2 4(sp)
    lw a3 8(sp)
    mul t1 a2 a3
    bne a0 t1 malwrite
    lw a1 0(sp)
    addi sp sp 12
    
    # close the file----------------------------------------
    mv a0 s0
    jal ra fclose
    li t1 -1
    beq a0 t1 malclose



    # Epilogue

    lw ra 0(sp)
    lw s0 4(sp)
    addi sp sp 8
    jr ra
malopen:
    li a0 27
    j exit
malwrite:
    li a0 30
    j exit
malclose:
    li a0 28
    j exit