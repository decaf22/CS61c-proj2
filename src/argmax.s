.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    li t0 1
    mv t3 a1 # t3=len(arr)
    blt a1 t0 mal
    lw t0 0(a0) # t0=a0[0], we will continue using t0 to record the largest number
    li t1 0 # t1=index of largest number

loop_start:
    beq zero a1 loop_end # if a1==0 end
    lw t2 0(a0)
    bge t0 t2 loop_continue # if t0>=t2 then continue
    mv t0 t2# if t0<t2, t0=t2
    sub t1 t3 a1# t1=t3-a1

loop_continue:
    addi a0 a0 4
    addi a1 a1 -1 #a1--
    j loop_start

loop_end:
    # Epilogue
    mv a0 t1
    jr ra
mal:
    li a0 36
    j exit
