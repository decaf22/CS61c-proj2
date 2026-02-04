.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    li t0 1
    blt a1 t0 mal
    blt a2 t0 mal
    blt a4 t0 mal
    blt a5 t0 mal
    bne a2 a4 mal

    # Prologue, move all the important things to s registers
    addi sp sp -36
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp) 
    sw s5 20(sp) # s5 stores the result
    sw s6 24(sp)
    sw s7 28(sp)
    sw s8 32(sp)
    mv s8 ra # we will use ra in dot, so save it here
    mv s7 a3 # a copy for mat1, because we will change the pointer of m1 later
    mv s6 a5 # because later we will use s3 as the counter
    mv s5 a6
    mv s0 a0 # s0=mat0
    mv s1 a1 # s1=row(mat0)
    mv s2 a3 # s2=mat1
    mv s3 a5 # s3=col(mat1)
    mv s4 a2 # s4=col(mat0)=row(mat1), to be used in dot calculation
    

outer_loop_start:
    beq s1 x0 outer_loop_end
    j inner_loop_start


inner_loop_start:
    beq s3 x0 inner_loop_end
    mv a0 s0 # a0=s0=mat0=&mat[0][0]
    mv a2 s4
    li a3 1
    mv a4 s6 # a0 to a4 are args defined in dot func, s6=col(mat1)
    mv a1 s2
    jal dot # after executing this one, you can use a0, and continue to next line
    sw a0 0(s5)
    addi s3 s3 -1 # s3--
    addi s2 s2 4 # move to next col
    addi s5 s5 4 # move to next place to write result
  
    j inner_loop_start


inner_loop_end:
    addi s1 s1 -1
    slli t0 s4 2 # t0=col(mat0)*4 bytes
    add s0 s0 t0 # move to next row of mat0
    mv s3 s6 # since s3 is already 0, re-assign it to be col(m1)
    mv s2 s7
    j outer_loop_start


outer_loop_end:


    # Epilogue
    mv ra s8
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp) 
    lw s5 20(sp) # s5 stores the result
    lw s6 24(sp)
    lw s7 28(sp)
    lw s8 32(sp)
    addi sp sp 36
    

    jr ra
mal:
    li a0 38
    j exit
