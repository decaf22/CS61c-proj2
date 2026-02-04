.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu: # Surprise! You cannot change place of "relu" here :)!
    li t3 1
    blt a1 t3 mal
loop_start:
    li t0 0 #t0=0, the counter
    mv t1 a0
    
loop_continue:
    bge t0 a1 loop_end # if t0>=len(arr) loop_end
    lw t2 0(t1) #t2=current pointed to by t1 pointer
    mv t4 t1# t4 saves the current location of t1, because we will change t1 soon
    addi t1 t1 4 #move t1 pointer 1 place
    addi t0 t0 1# t0++
    blt t2 x0 relucode #if t2<0 then relu
    j loop_continue
    
    

loop_end:


    # Epilogue


    jr ra
mal:
    li a0 36
    j exit
relucode:
    # Prologue
    sw zero 0(t4)
    j loop_continue