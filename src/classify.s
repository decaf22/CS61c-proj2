.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    addi sp sp -52
    sw ra 0(sp) 
    sw s0 4(sp) # m0
    sw s1 8(sp) # m1
    sw s2 12(sp) # input need space to store 3 matrices
    sw s3 16(sp) # m0 row
    sw s4 20(sp) # m0 col
    sw s5 24(sp) # m1 row
    sw s6 28(sp) # m1 col
    sw s7 32(sp) # input row
    sw s8 36(sp) # input col
    sw s9 40(sp) # h matrix
    sw s10 44(sp) # o matrix
    sw s11 48(sp) # a2
    mv s11 a2
    # need space to store the dimensions of each matrix
    li t0 5
    bne a0 t0 malnum
    # Read pretrained m0-------------------------------
    addi sp sp -12
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    lw a0 4(a1) #m0, a1[1] = *(a1 + 4)
    # find memories for a1, a2
    addi sp sp -8
    mv a1 sp 
    addi a2 sp 4
    jal ra read_matrix # returns the *matrix in a0
    lw s3 0(sp)
    lw s4 4(sp) # save n(row) and n(col)
    addi sp sp 8
    mv s0 a0 #s0 stores the address of m0
    lw a0 0(sp)
    lw a1 4(sp)
    lw a2 8(sp)
    addi sp sp 12

    # Read pretrained m1-----------------------------
    addi sp sp -12
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    lw a0 8(a1) #m1, a1[2] = *(a1 + 8)
    # find memories for a1, a2
    addi sp sp -8
    mv a1 sp 
    addi a2 sp 4
    jal ra read_matrix # returns the *matrix in a0
    lw s5 0(sp)
    lw s6 4(sp) # save n(row) and n(col)
    addi sp sp 8
    mv s1 a0 #s1 stores the address of m1
    lw a0 0(sp)
    lw a1 4(sp)
    lw a2 8(sp)
    addi sp sp 12

    # Read input matrix-------------------------------
    addi sp sp -12
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    lw a0 12(a1) #input, a1[3] = *(a1 + 12)
    # find memories for a1, a2
    addi sp sp -8
    mv a1 sp 
    addi a2 sp 4
    jal ra read_matrix # returns the *matrix in a0
    lw s7 0(sp)
    lw s8 4(sp) # save n(row) and n(col)
    addi sp sp 8
    mv s2 a0 #s2 stores the address of input matrix
    lw a0 0(sp)
    lw a1 4(sp)
    lw a2 8(sp)
    addi sp sp 12

    # Compute h = matmul(m0, input)--------------------
    addi sp sp -12
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    #m0 is s3*s4, input is s7*s8, h is s3*s8
    mul t0 s3 s8
    mv a0 t0
    slli a0 a0 2
    jal ra malloc # a0 is the allocated memory, to save h
    beq a0 x0 malmalloc
    mv a6 a0 # a6 is the address of h, just malloced
    mv s9 a6 # h also atored in s9
    mv a0 s0 # a0 is m0
    mv a1 s3
    mv a2 s4
    mv a3 s2
    mv a4 s7
    mv a5 s8
    jal ra matmul
    lw a0 0(sp)
    lw a1 4(sp)
    lw a2 8(sp)
    addi sp sp 12
    

    # Compute h = relu(h)---------------------------
    addi sp sp -12
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    
    mv a0 s9 # the address of h matrix
    mul t0 s3 s8
    mv a1 t0
    jal ra relu # now h is relu-ed
    

    lw a0 0(sp)
    lw a1 4(sp)
    lw a2 8(sp)
    addi sp sp 12
    
    # Compute o = matmul(m1, h)-----------------------------
    addi sp sp -12
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    # we first do the matmul, m1 is s5*s6, h is s3*s8, o is s5*s8
    mul t0 s5 s8
    mv a0 t0
    slli a0 a0 2
    jal ra malloc # a0 is the allocated memory, to save o
    beq a0 x0 malmalloc
    
    mv a6 a0 # a6 is the address of h, just malloced
    mv s10 a6
    mv a0 s1 # a0 is m1
    mv a1 s5
    mv a2 s6
    mv a3 s9
    mv a4 s3
    mv a5 s8
    jal ra matmul # now o is in a6
    
  
    # Write output matrix o-------------
    lw a1 4(sp)
    lw a0 16(a1) #output file location, a1[4] = *(a1 + 16)
    mv a1 s10
    mv a2 s5
    mv a3 s8
    jal ra write_matrix
    
    lw a0 0(sp)
    lw a1 4(sp)
    lw a2 8(sp)
    addi sp sp 12
    
    # Compute and return argmax(o)-----------------------------
    addi sp sp -12
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    
    mv a0 s10 # o matrix
    mul t0 s5 s8
    mv a1 t0
    jal ra argmax # returns a0, index of the largest element
    mv s3 a0 # maybe don't need original s3 from now on
    
    
    bne s11 x0 cont # if a2!=0 skip the printing section
    # if a2==0:
    # If enabled, print argmax(o) and newline--------------------
    jal ra print_int # a0 already stores the largest element index
    li a0 '\n'
    jal ra print_char # print newline char
    
    

cont:
    # free space malloced----------------
    mv a0 s9
    jal ra free
    mv a0 s10
    jal ra free
    
    lw a0 0(sp)
    lw a1 4(sp)
    lw a2 8(sp)
    addi sp sp 12
    
    mv a0 s3 # a0 stores argmax(o)
    
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp) # m0 row
    lw s4 20(sp) # m0 col
    lw s5 24(sp) # m1 row
    lw s6 28(sp) # m1 col
    lw s7 32(sp) # input row
    lw s8 36(sp) # input col
    lw s9 40(sp)
    lw s10 44(sp)
    lw s11 48(sp)
    addi sp sp 52
    jr ra
malnum:
    li a0 31
    j exit
malmalloc:
    li a0 26
    j exit