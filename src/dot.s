.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    li t0 1
    blt a2 t0 mal1
    blt a3 t0 mal2
    blt a4 t0 mal2
    li t6 0 # t6 temporarily records dot product
    slli t3 a3 2 # t3=4*a3
    slli t4 a4 2 # t4=4*a4
    # Prologue
    

loop_start:
    beq a2 zero loop_end
    lw t0 0(a0) # t0 is the multiplier in arr0
    lw t1 0(a1) # t1 is the multiplier in arr1
    mul t5 t0 t1 # t5=t0*t1
    add t6 t6 t5 # t6+=t5
    j loop_continue

loop_continue:
    add a0 a0 t3 # move a0 to next element
    add a1 a1 t4
    addi a2 a2 -1 # a2--
    j loop_start

loop_end:
    

    # Epilogue
    mv a0 t6

    jr ra
mal1:
    li a0 36
    j exit
mal2:
    li a0 37
    j exit
