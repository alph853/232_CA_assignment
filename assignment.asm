.data
   inPrompt: .asciiz "Please insert your expression: "
   ### string 
   input: .space 101
   validatedString: .space 200
   postfixExpression: .space 200
   # postfixExpression: .asciiz "-2 -2 /"

   stringLength: .word 0
   resultString: .space 100
   star: .asciiz "*"
   
   substr_res: .space 100
   d_to_s_result: .space 100
   str1: .space 100
   str2: .space 100

   .align 3
   stack: .space 400
   ### string

   prompt: .asciiz "\n>> "
   quitCommand: .asciiz "quit"
   quitPrompt: .asciiz "EXIT!"
   fact: .space 704
   constUpperFactorial: .word 70
   constNearZero: .double 1e-8
   const0: .double 0
   const1: .double 1
   const2: .double 2
   const10: .double 10
   constdouble: .double 200
   const7: .double 7
   preAns: .double 0
   newline: .asciiz "\n"
   INT_MAX: .double 2147483647

   file_descriptor: .word 0
   filename: .asciiz "log.txt"


   # error messages
   fileError: .asciiz "Error opening file!\n"
   error0: .asciiz "SYNTAX ERROR: INVALID PARENTHESES!\n"
   error1: .asciiz "SYNTAX ERROR: CONTAINING INVALID CHARACTER!\n"
   error2: .asciiz "SYNTAX ERROR NEAR '.' CHARACTER!\n"
   error3: .asciiz "SYNTAX ERROR NEAR '!' OPERATOR!\n"
   error1_0: .asciiz "MATH ERROR: NON-INTEGER EXPONENT OF NEGATIVE NUMBER!\n"
   error1_1: .asciiz "SYNTAX ERROR: INVALID OPERATION!\n"
   error1_2: .asciiz "MATH ERROR: FACTORIAL OF NON-POSITIVE NUMBER!\n"
   error1_3: .asciiz "MATH ERROR: FACTORIAL IS TOO LARGE TO CALCULATE!\n"
   error1_4: .asciiz "MATH ERROR: FACTORIAL OF NON-INTEGER NUMBER!\n"
   error1_5: .asciiz "MATH ERROR: DIVISION BY ZERO!\n"

.text
   li $v0, 13
   la $a0, filename
   li $a1, 9   # flag = append
   li $a2, 0
   syscall
   bge $v0, $0, save_file_des
      # if file error
      la $a0, fileError
      li $v0, 4
      syscall
      j exit

   save_file_des:
   la $a0, file_descriptor
   sw $v0, 0($a0)

# test:
#    li $v0, 7
#    syscall

#    mov.d $f12, $f0
#    li $a0, 16
#    jal double_to_string

#    move $a0, $v0
#    li $v0, 4
#    syscall

#    li $v0, 11
#    li $a0, '\n'
#    syscall

#    li $v0, 10
#    syscall


factorial:
   ldc1 $f0, const1  # fact[index-1]
   ldc1 $f2, const1
   ldc1 $f4, const2  # index

   la $t0, fact
   li $t1, 2
   la $t2, constUpperFactorial
   lw $t2, 0($t2)
   sdc1 $f2, 0($t0)
   sdc1 $f2, 8($t0)
   addi $t0, $t0, 16 
   factorial_loop:
      mul.d $f0, $f0, $f4
      sdc1 $f0, 0($t0)

      addi $t0, $t0, 8
      addi $t1, $t1, 1
      add.d $f4, $f4, $f2
      bne $t2, $t1, factorial_loop

main:
   li $v0, 4
   la $a0, inPrompt
   syscall
   
   # while true until user types "quit"
   while:
      li $v0, 4
      la $a0, prompt
      syscall

      # read input string
      li $v0, 8
      la $a0, input
      li $a1, 200
      syscall   

      # get length and remove newline
      la $a0, input
      jal strLen   
      la $t0, stringLength
      sw $v0, 0($t0)

      # if input empty then continue loop
      la $a0, input
      lw $t0, 0($a0)
      beqz $t0, while
      # else if input == "quit" then exit
      la $a1, quitCommand
      jal strCmp
      beq $v0, 1, exit
      # else process string
      la $a0, input
      la $a1, validatedString
      jal strcpy

      la $a0, validatedString
      jal validateString

      beq $v0, -1, convertToPostfix
      beq $v0, 0, Error0
      beq $v0, 1, Error1
      beq $v0, 2, Error2
      beq $v0, 3, Error3

      convertToPostfix:
      ##############################
      la $a0, validatedString
      li $v0, 4
      syscall

      li $v0, 11
      li $a0, '\n'
      syscall
      ##############################

      la $a0, validatedString
      jal infixToPostfix

      ##############################
      move $a0, $v0
      li $v0, 4
      syscall

      li $v0, 11
      li $a0, '\n'
      syscall
      ##############################


      la $a0, postfixExpression
      jal postfixCal

      bne $v0, -1, checkForErrors

      # valid input
      # print output
      la $a0, preAns
      sdc1 $f0, 0($a0)
      mov.d $f12, $f0
      li $a0, 16
      jal double_to_string
      move $a0, $v0
      li $v0, 4
      syscall
      
      li $a0, '\n'
      li $v0, 11
      syscall

      # store to "log.txt"
      # $a0 = file descriptor $a1 = address of output buffer $a2 = number of characters to write
      li $v0, 15
      la $a0, file_descriptor
      lw $a0, 0($a0)
      la $a1, prompt
      li $a2, 4 
      syscall

      la $a0, input
      jal strLen
      move $a2, $v0
      la $a0, file_descriptor
      lw $a0, 0($a0)
      la $a1, input
      li $v0, 15
      syscall

      li $v0, 15
      la $a0, file_descriptor
      lw $a0, 0($a0)
      la $a1, newline
      li $a2, 1
      syscall

      la $a0, d_to_s_result
      jal strLen
      move $a2, $v0
      la $a1, d_to_s_result
      li $v0, 15
      la $a0, file_descriptor
      lw $a0, 0($a0)
      syscall

      li $v0, 15
      la $a0, file_descriptor
      lw $a0, 0($a0)
      la $a1, newline
      li $a2, 1
      syscall

      j while

      checkForErrors:
      beq $v0, 1, Error1_1
      beq $v0, 2, Error1_2
      beq $v0, 3, Error1_3
      beq $v0, 4, Error1_4
      beq $v0, 5, Error1_5

      j while
      ##############################
      Error0:
         li $v0, 4
         la $a0, error0
         syscall
         j while
      Error1:
         li $v0, 4
         la $a0, error1
         syscall
         j while
      Error2:
         li $v0, 4
         la $a0, error2
         syscall
         j while
      Error3:
         li $v0, 4
         la $a0, error3
         syscall
         j while
      Error1_0:
         li $v0, 4
         la $a0, error1_0
         syscall
         j while
      Error1_1:
         li $v0, 4
         la $a0, error1_1
         syscall
         j while
      Error1_2:
         li $v0, 4
         la $a0, error1_2
         syscall
         j while
      Error1_3:
         li $v0, 4
         la $a0, error1_3
         syscall
         j while
      Error1_4:
         li $v0, 4
         la $a0, error1_4
         syscall
         j while
      Error1_5:
         li $v0, 4
         la $a0, error1_5
         syscall
         j while
   exit:
      la $a0, file_descriptor
      lw $a0, 0($a0)
      li $v0, 16
      syscall 

      li $v0, 4
      la $a0, quitPrompt
      syscall 

      li $v0, 10
      syscall


########################################
########################################
###        string functions        ###
strLen:
   # a0 is the input string, v0 is the returned length
   li $v0, 0
   li $t0, 0
   strLen_loop:
      lb $t1, 0($a0)
      beq $t1, '\n', remove_newline
      beq $t1, $0, end_strLen
      addiu $a0, $a0, 1
      addiu $v0, $v0, 1
      j strLen_loop
   remove_newline:
      sb $0, 0($a0)
   end_strLen:
      jr $ra

strCmp:
   li $v0, 1
   check_loop:
      lb $t0, 0($a0)
      lb $t1, 0($a1)

      # if either bytes is not null, then check
      bne $t0, $0, check
      bne $t1, $0, check
      # else both are null
      j end_check
   check:
      bne $t0, $t1, not_equal
      addiu $a0, $a0, 1
      addiu $a1, $a1, 1
      j check_loop

   not_equal:
      li $v0, 0
      
   end_check:
      # v0 = (equal)? 1 : 0
      jr $ra



strInsert:
   # insert a1 into a0 at index a2
   # this function assume all inputs are valid

   # a0 = string, a1 = inserted string, a2 = index
   # v0 = start address of returned string

   # later v0 = t2
   # return string = a0[0:index-1] + inserted string + a0[index:strLen-1]
   addi $sp, $sp, -4
   sw $ra, 0($sp)

   move $t2, $a0
   move $t3, $a1
   move $t4, $a2

   jal strLen
   move $t0, $v0
   # t0 is the length of a0 string

   move $a0, $t2
   move $a1, $a2
   move $a2, $t0
   addi $a2, $a2, -1
   blt $a2, $a1, append

   jal substr
   move $t5, $v0 # t5 = a0[index:strLen-1]

   move $a0, $t2
   move $a1, $t3
   add $a0, $a0, $t4 # a0 + index
   
   strInsert_loop:
      lb $t0, 0($a1)
      beq $t0, $0, append_substr
      sb $t0, 0($a0)
      addiu $a0, $a0, 1
      addiu $a1, $a1, 1
      j strInsert_loop
   append_substr:
      lb $t0, 0($t5)
      sb $t0, 0($a0)
      beq $t0, $0, end_strInsert
      addiu $a0, $a0, 1
      addiu $t5, $t5, 1
      j append_substr

   # appending to end of a0 string
   append:
      move $a0, $t2
      move $a1, $t3
      add $a0, $a0, $t0
      append_loop:
         lb $t0, 0($a1)
         sb $t0, 0($a0)
         beq $t0, $0, end_strInsert
         addiu $a0, $a0, 1
         addiu $a1, $a1, 1
         j append_loop
   end_strInsert:
      move $v0, $t2
      lw $ra, 0($sp)
      addi $sp, $sp, 4
      jr $ra


substr:
   # this function assume all inputs are valid
   # a0 = string, a1 = start index, a2 = end index
   # v0 = start address of substring
   add $a0, $a0, $a1
   sub $a2, $a2, $a1
   add $a2, $a2, 1
   # a2 is length of substring
   la $v0, substr_res
   substr_loop:
      beq $a2, $0, end_substr
      lb $t0, 0($a0)
      sb $t0, 0($v0)
      addi $a2, $a2, -1
      addi $a0, $a0, 1
      addi $v0, $v0, 1
      j substr_loop
   end_substr:
      sb $0, 0($v0)
      la $v0, substr_res
      jr $ra

erase:
   # this function can handle erase nothing
   # a0 = string, a1 = start index, a2 = count
   # v0 = start address of erased string
   addi $sp, $sp, -4
   sw $ra, 0($sp)

   move $t5, $a0
   add $t4, $a0, $a1
   jal strLen
   move $t3, $v0

   move $a0, $t5
   add $a1, $a1, $a2
   addi $a2, $t3, -1    
   jal substr

   move $a0, $v0
   move $a1, $t4
   jal strcpy
   
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   move $v0, $t5
   jr $ra

strcpy:
   # a0 = address of string, a1 = address to save the string
   # a1 will points to the strLen
   save_loop:
      lb $t0, 0($a0)
      sb $t0, 0($a1)
      beq $t0, $0, end_save
      addiu $a0, $a0, 1
      addiu $a1, $a1, 1
      j save_loop
   end_save:
      jr $ra


strAppend:
   # a0 = string, a1 = string to append to string a0
   # v0 = start address of returned string
   addi $sp, $sp, -4
   sw $ra, 0($sp)

   jal strLen
   # a0 = address of '\0' now
   move $t0, $a1
   move $a1, $a0
   move $a0, $t0

   jal strcpy

   move $v0, $t0
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   jr $ra

########################################
########################################
###      expression functions      ###
validOps:
   # a0 = character
   # v0 = (valid)? 1 : 0
   li $v0, 1
   beq $a0, '+', validOps_end
   beq $a0, '-', validOps_end
   beq $a0, '*', validOps_end
   beq $a0, '/', validOps_end
   beq $a0, '!', validOps_end
   beq $a0, '^', validOps_end
   li $v0, 0
   validOps_end:
      jr $ra

precedence:
   # a0 = operator (char)
   # v0 = precedence
   li $v0, 1
   beq $a0, '+', precedence_end
   beq $a0, '-', precedence_end
   addi $v0, $v0, 1
   beq $a0, '*', precedence_end
   beq $a0, '/', precedence_end
   addi $v0, $v0, 1
   beq $a0, '_', precedence_end
   addi $v0, $v0, 1
   beq $a0, '^', precedence_end
   addi $v0, $v0, 1
   beq $a0, '!', precedence_end
   li $v0, 0
   precedence_end:
      jr $ra


validateString:
   # a0 = validate string, also the global variable 
   # v0 = -1: no errors

   addi $sp, $sp, -4
   move $fp, $sp
   sw $ra, 0($sp)

   # s0 = index, s1 = length, s4 = balance
   li $s0, 0
   li $s4, 0
   validatedString_loop:
      la $a0, validatedString
      jal strLen
      beq $s0, $v0, validatedString_loop_end
      move $s1, $v0

      la $a0, validatedString
      # s3 = expr[i]
      add $t2, $a0, $s0
      lb $s3, 0($t2)

      bne $s3, 'M', elseif_space
      # if (expr[i] == 'M')
         beq $s0, $0, if_if2
         # if (i > 0) 
            addi $t0, $s0, -1
            add $t2, $a0, $t0
            lb $a0, 0($t2)
            jal isDigit
            beq $v0, 1, insert_multiplication
            beq $a0, ')', insert_multiplication
            j if_if2
            insert_multiplication:
               la $a0, validatedString
               la $a1, star
               move $a2, $s0
               jal strInsert
               move $a0, $v0
               addi $s0, $s0, 1

            if_if2:
            la $a0, validatedString
            jal strLen
            move $s1, $v0
            addi $t0, $s0, 1
            beq $t0, $s1, validated_increment
            # if (i + 1 < expr.length())
            la $a0, validatedString
            add $a0, $a0, $t0
            lb $a0, 0($a0)
            jal isDigit
            beq $v0, 0, validated_increment
               # insert *
               addi $s0, $s0, 1
               la $a0, validatedString
               la $a1, star
               move $a2, $s0
               jal strInsert
               move $a0, $v0
            j validated_increment

      elseif_space:
      bne $s3, ' ', elseif_dot
      # else if (expr[i] == ' ')
         # la $a0, validatedString
         move $a1, $s0
         li $a2, 1
         jal erase
         j validated_increment

      elseif_dot:
      bne $s3, '.', elseif_open
      # else if (expr[i] == '.')
         beq $s0, $0, return2
         addi $t0, $s0, 1
         beq $t0, $s1, return2
         # la $a0, validatedString
         add $a0, $a0, $t0
         lb $a0, 0($a0)
         jal isdigit
         beq $v0, 0, return2

         la $a0, validatedString
         addi $t0, $s0, -1
         add $t1, $a0, $t0
         lb $a0, 0($t1)
         jal isdigit
         beq $v0, 0, return2
         j validated_increment
         return2:
            li $v0, 2
            move $sp, $fp
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra

      elseif_open:
      bne $s3, '(', elseif_close
      # else if (expr[i] == '(')
         beq $s0, $0, increBalance
         addi $t0, $s0, -1
         # la $a0, validatedString
         add $t1, $a0, $t0
         lb $a0, 0($t1)
         beq $a0, ')', insert_multiplication2
         beq $a0, '!', insert_multiplication2
         jal isDigit
         beq $v0, 1, insert_multiplication2
         j increBalance
         insert_multiplication2:
            la $a0, validatedString
            la $a1, star
            move $a2, $s0
            jal strInsert
            addi $s0, $s0, 1
         increBalance:
            addi $s4, $s4, 1
            j validated_increment

      elseif_close:
      bne $s3, ')', elseif_minus
      # else if (expr[i] == ')')
         addi $t0, $s0, 1
         beq $t0, $s1, checkBalance
         # la $a0, validatedString
         add $a0, $a0, $t0
         lb $a0, 0($a0)
         jal isDigit
         beq $v0, 0, checkBalance

         addi $s0, $s0, 1
         la $a0, validatedString
         la $a1, star
         move $a2, $s0
         jal strInsert

         checkBalance:
            beq $s4, $0, return0
         decBalance:
            addi $s4, $s4, -1
            j validated_increment
         return0:
            li $v0, 0
            move $sp, $fp
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra

      elseif_minus:
      bne $s3, '-', elseif_plus
      # else if (expr[i] == '-')
         li $s5, 1            # minus = true
         whileSimplify:
            la $a0, validatedString
            jal strLen
            addi $t0, $s0, 1
            beq $t0, $v0, substitute_minus
            la $a0, validatedString
            add $t1, $t0, $a0
            lb $t1, 0($t1)    # t1 = expr[i + 1]
            bne $t1, '+', check_minus
               move $a1, $t0
               li $a2, 1
               jal erase
               j whileSimplify
            check_minus:
            bne $t1, '-', substitute_minus
               move $a1, $t0
               li $a2, 1
               jal erase
               xori $s5, $s5, 1  # minus = !minus
               j whileSimplify
         substitute_minus:
            la $a0, validatedString
            add $a0, $a0, $s0

            beq $s5, 0, setPlus
            li $t0, '-'
            sb $t0, 0($a0)
            j validated_increment
         setPlus:
            li $t0, '+'
            sb $t0, 0($a0)
            j validated_increment

      elseif_plus:
      bne $s3, '+', elseif_exclaim
      # else if (expr[i] == '+')
         addi $t0, $s0, 1
         beq $t0, $s1, validated_increment
         # la $a0, validatedString
         add $t1, $a0, $t0
         lb $t2, 0($t1)
         beq $t2, '+', erase_plus
         beq $t2, '-', erase_plus
         j validated_increment
         erase_plus:
            # la $a0, validatedString
            move $a1, $s0
            li $a2, 1
            jal erase
            addi $s0, $s0, -1
            j validated_increment

      elseif_exclaim:
      bne $s3, '!', elseif_check
      # else if (expr[i] == '!')
         addi $t0, $s0, 1
         beq $t0, $s1, validated_increment
         # la $a0, validatedString
         add $t1, $a0, $t0
         lb $a0, 0($t1)
         beq $a0, '!', return3
         jal isDigit
         beq $v0, 1, return3
         j validated_increment
         # la $a0, validatedString
         return3:
            li $v0, 3
            move $sp, $fp
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra

      elseif_check:  
         move $a0, $s3
         jal validOps
         beq $v0, 1, validated_increment
         jal isDigit
         beq $v0, 1, validated_increment
         return1:
            li $v0, 1
            move $sp, $fp
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra
      
      validated_increment:
         addi $s0, $s0, 1
         j validatedString_loop

   validatedString_loop_end:
      la $a0, validatedString
      lb $t0, 1($a0)
      bne $t0, '-', check_balance
         lb $t1, 0($a0)
         bne $t1, '+', if_elseif_minus
            li $a1, 0
            li $a2, 1
            jal erase 
            j check_balance
         if_elseif_minus:
            li $a1, 0
            li $a2, 2
            jal erase

      check_balance:
      beq $s4, $0, return
      j return0

   return:
      li $v0, -1
      move $sp, $fp
      lw $ra, 0($sp)
      addi $sp, $sp, 4
      jr $ra


infixToPostfix:
   # a0 = validated infix expression, v0 = postfix expression
   addi $sp, $sp, -4
   move $fp, $sp
   sw $ra, 0($sp)

   li $s0, 0      # int i = 0
   li $s1, 0      # isNum = false
   la $s2, postfixExpression      # keep track of the end of postfix
   la $s3, stack  # stack<char> 
   sb $0, 0($s3)  # stack empty if top is null

   sb $0, 0($s2)  # postfix = ""
   jal strLen
   move $s4, $v0 # expr.length()


   infixToPostfix_loop:
      beq $s0, $s4, infixToPostfix_loop_end
      la $a0, validatedString
      add $t0, $a0, $s0
      lb $s5, 0($t0) # expr[i]
      
      beq $s5, '-', check_unary
      beq $s5, '+', check_unary
      j elseif_dot1
      check_unary:
      # if (expr[i] == '-' || expr[i] == '+')
         li $t0, 0   # bool unary = false
         beq $s0, $0, unary_true
         addi $t1, $s0, -1
         add $a0, $a0, $t1
         lb $a0, 0($a0)
         jal isDigit
         beq $v0, 1, ifDigit
         beq $a0, ')', ifDigit
         beq $a0, '!', ifDigit
         unary_true:
            bne $s5, '-', just_increment_s0
            addi $s3, $s3, 1
            li $t0, '_'
            sb $t0, 0($s3)
            just_increment_s0:
            addi $s0, $s0, 1
         j ifDigit
      elseif_dot1:
      bne $s5, '.', ifDigit
      # if (expr[i] == '.')
         la $a0, str1
         sb $s5, 0($a0)
         move $a1, $s2
         jal strcpy
         addi $s2, $s2, 1
         addi $s0, $s0, 1

      ifDigit:
      la $a0, validatedString
      add $a0, $a0, $s0
      lb $s5, 0($a0)
      
      lb $a0, 0($a0)
      jal isDigit
      bne $v0, 1, elseif_open1
      # if (isdigit(expr[i]))
         la $a0, str1
         sb $s5, 0($a0)
         move $a1, $s2
         jal strcpy
         li $s1, 1
         addi $s2, $s2, 1
         j infixToPostfix_increment
      
      elseif_open1:
      bne $s5, '(', elseif_close1
      # else if (expr[i] == '(')
         addi $s3, $s3, 1
         sb $s5, 0($s3)
         j infixToPostfix_increment

      elseif_close1:
      bne $s5, ')', elseif_validOps1
      # else if (expr[i] == ')')
         beq $s1, $0, while_notOpen
            la $a0, str1
            li $t0, ' '
            sb $t0, 0($a0)
            move $a1, $s2
            jal strcpy
            addi $s2, $s2, 1
            li $s1, 0
         while_notOpen:
            lb $t0, 0($s3)
            beq $t0, $0, just_pop
            beq $t0, '(', just_pop
            la $a0, str1
            sb $t0, 0($a0)
            li $t0, ' ' 
            sb $t0, 1($a0)
            move $a1, $s2
            jal strcpy
            addi $s2, $s2, 2
            addi $s3, $s3, -1
            j while_notOpen
         just_pop:
            addi $s3, $s3, -1
         j infixToPostfix_increment

      elseif_validOps1:
      move $a0, $s5
      jal validOps
      beq $v0, 0, infixToPostfix_increment
      # else if(validOps(expr[i]))
         beq $s1, $0, while_precedence
            la $a0, str1
            li $t0, ' '
            sb $t0, 0($a0)
            move $a1, $s2
            jal strcpy
            addi $s2, $s2, 1
            li $s1, 0
         while_precedence:
            lb $t0, 0($s3)
            beq $t0, $0, just_push
            move $a0, $t0
            jal precedence
            move $t1, $v0     # t1 = precedence(stack.top())
            move $a0, $s5
            jal precedence
            move $t2, $v0     # t2 = precedence(expr[i])
            blt $t1, $t2, just_push
               la $a0, str1
               sb $t0, 0($a0)
               li $t0, ' '
               sb $t0, 1($a0)
               move $a1, $s2
               jal strcpy
               addi $s2, $s2, 2
               addi $s3, $s3, -1
               j while_precedence
         just_push:
            addi $s3, $s3, 1
            sb $s5, 0($s3)
         j infixToPostfix_increment

      infixToPostfix_increment:
         addi $s0, $s0, 1
         j infixToPostfix_loop

   infixToPostfix_loop_end:
      while_appendRemaining:
         lb $t0, 0($s3)
         beq $t0, $0, return_postfix
         la $a0, str1
         li $t1, ' '
         sb $t1, 0($a0)
         sb $t0, 1($a0)
         move $a1, $s2  
         jal strcpy
         addi $s2, $s2, 2
         addi $s3, $s3, -1
         j while_appendRemaining

   return_postfix:
      sb $0, 0($s2)
      la $v0, postfixExpression
      move $sp, $fp
      lw $ra, 0($sp)
      addi $sp, $sp, 4
      jr $ra


postfixCal:
   # a0 = postfix expression, f0 = result, v0 = output invalid

   addi $sp, $sp, -4
   move $fp, $sp
   sw $ra, 0($sp)

   jal strLen
   
   li $s0, 0         # int i = 0
   li $s1, 0         # isNegative = false
   # move $s2, $a1     # &invalid
   la $s3, stack     # stack<double>
   move $s4, $s3     # if s4 == s3 then stack empty
   move $s5, $v0     # length of postfix string
   
   postfixCal_loop:
      beq $s0, $s5, postfixCal_loop_end
      la $a0, postfixExpression
      add $t0, $a0, $s0
      lb $s6, 0($t0) # postfix[i]
      
      beq $s6, ' ', postfixCal_increment

      bne $s6, '-', ifDigit2
      addi $t0, $s0, 1
      add $t0, $a0, $t0
      lb $a0, 0($t0)
      jal isDigit
      beq $v0, 0, ifDigit2
      # if (postfix[i] == '-' && isdigit(str[i + 1])
         li $s1, 1
         addi $s0, $s0, 1
      
      ifDigit2:
      la $a0, postfixExpression
      add $a0, $a0, $s0
      lb $s6, 0($a0)
      move $a0, $s6
      jal isdigit
      bne $v0, 1, else_if_M
      # if (isdigit(postfix[i])) 
         ldc1 $f20, const0    # val = 0.0
         ldc1 $f24, const0    # fraction = 0.0
         while_conversion:
         beq $s0, $s5, end_conversion
         la $t0, postfixExpression
         add $t0, $t0, $s0
         lb $a0, 0($t0)
         jal isdigit
         beq $v0, 0, end_conversion

            ldc1 $f14, const10
            mul.d $f20, $f20, $f14
            addi $a0, $a0, -48
            mtc1 $a0, $f14
            cvt.d.w $f14, $f14
            add.d $f20, $f20, $f14
            addi $s0, $s0, 1
            j while_conversion
         end_conversion:

         la $a0, postfixExpression
         add $a0, $a0, $s0 
         lb $a0, 0($a0)
         bne $a0, '.', end_fraction

         addi $s0, $s0, 1
         ldc1 $f22, const10
         while_fraction:
         beq $s0, $s5, end_fraction
         la $t0, postfixExpression
         add $t0, $t0, $s0
         lb $a0, 0($t0)
         jal isdigit
         beq $v0, 0, end_fraction
            addi $a0, $a0, -48
            mtc1 $a0, $f14
            cvt.d.w $f14, $f14
            div.d $f14, $f14, $f22
            add.d $f24, $f24, $f14
            ldc1 $f14, const10
            mul.d $f22, $f22, $f14
            addi $s0, $s0, 1
            j while_fraction
         end_fraction:
            addi $s0, $s0, -1
            add.d $f20, $f20, $f24
            beq $s1, $0, stack_push
            neg.d $f20, $f20
            li $s1, 0
         stack_push:
            addi $s3, $s3, 8
            sdc1 $f20, 0($s3)
         j postfixCal_increment
      
      else_if_M:
      bne $s6, 'M', else_evaluate
      beq $s1, 0, push_ans
         li $s1, 0
         addi $s3, $s3, 8
         ldc1 $f14, preAns
         neg.d $f14, $f14
         sdc1 $f14, 0($s3)
         j postfixCal_increment
         push_ans:
            addi $s3, $s3, 8
            ldc1 $f14, preAns
            sdc1 $f14, 0($s3)
         j postfixCal_increment

      else_evaluate:
         beq $s4, $s3, return1_1

         ldc1 $f20, 0($s3) # val1
         addi $s3, $s3, -8

         bne $s6, '!', check_unary_
         ldc1 $f14, const0
         c.lt.d $f20, $f14
         bc1t return1_2

         la $a0, constUpperFactorial
         lw $a0, 0($a0)
         mtc1 $a0, $f14
         cvt.d.w $f14, $f14
         c.le.d $f20, $f14 
         bc1f return1_3

         cvt.w.d $f12, $f20
         cvt.d.w $f12, $f12
         c.eq.d $f20, $f12
         bc1f return1_4

         cvt.w.d $f14, $f20
         mfc1 $a0, $f14

         sll $a0, $a0, 3
         la $a1, fact
         add $a0, $a0, $a1
         ldc1 $f16, 0($a0)

         addi $s3, $s3, 8
         sdc1 $f16, 0($s3)
         j postfixCal_increment
      
      check_unary_:
         bne $s6, '_', continue_evaluate
            neg.d $f20, $f20
            addi $s3, $s3, 8
            sdc1 $f20, 0($s3)
            j postfixCal_increment

      continue_evaluate:
         beq $s3, $s4, return1_1

         ldc1 $f24, 0($s3) # val2
         addi $s3, $s3, -8

         bne $s6, '+', go_minus
            add.d $f20, $f20, $f24
            addi $s3, $s3, 8
            sdc1 $f20, 0($s3)
            j postfixCal_increment

         go_minus:
         bne $s6, '-', go_multiply
            sub.d $f20, $f24, $f20
            addi $s3, $s3, 8
            sdc1 $f20, 0($s3)
            j postfixCal_increment

         go_multiply:
         bne $s6, '*', go_divide
            mul.d $f20, $f20, $f24
            addi $s3, $s3, 8
            sdc1 $f20, 0($s3)
            j postfixCal_increment

         go_divide:
         bne $s6, '/', go_power
            ldc1 $f14, const0
            c.eq.d $f20, $f14
            bc1t return1_5

            div.d $f20, $f24, $f20
            addi $s3, $s3, 8
            sdc1 $f20, 0($s3)
            j postfixCal_increment

         go_power:
            # check if val2 < 0 && val1 is non-integer then return1_0
            ### 
            mov.d $f12, $f24
            trunc.w.d $f14, $f20
            mfc1 $a0, $f14
            jal pow
            mov.d $f20, $f0
            addi $s3, $s3, 8
            sdc1 $f20, 0($s3)
            j postfixCal_increment
      postfixCal_increment:
         addi $s0, $s0, 1
         j postfixCal_loop

   postfixCal_loop_end:
      sub $t0, $s3, $s4
      beq $t0, 8, return_smooth
   return1_0:
      li $v0, 0
      j errorReturn
   return1_1:
      li $v0, 1
      j errorReturn
   return1_2:
      li $v0, 2
      j errorReturn
   return1_3:  
      li $v0, 3
      j errorReturn
   return1_4:
      li $v0, 4
      j errorReturn
   return1_5:
      li $v0, 5
      j errorReturn
   
   errorReturn:
      move $sp, $fp
      lw $ra, 0($sp)
      addi $sp, $sp, 4
      jr $ra

   return_smooth:
      ldc1 $f0, 0($s3)
      li $v0, -1

      move $sp, $fp
      lw $ra, 0($sp)
      addi $sp, $sp, 4
      jr $ra


########################################
########################################

pow:
   # f0 = f12 ^ a0
   ldc1 $f0, const1
   li $t0, 0     # isNegative = false
   bgt $a0, 0, pow_loop
   li $t0, 1     # isNegative = true
   neg $a0, $a0
   pow_loop:
      beq $a0, 0, pow_check_neg
      mul.d $f0, $f0, $f12
      addiu $a0, $a0, -1
      j pow_loop
   pow_check_neg:
      beq $t0, 0, pow_end
      ldc1 $f2, const1
      div.d $f0, $f2, $f0
   pow_end:
      jr $ra

isdigit:
   # a0 = character
   # v0 = (isdigit)? 1 : 0
   li $v0, 1
   li $t0, '0'
   li $t1, '9'
   bge $a0, $t0, isdigit_else
   li $v0, 0
   j isdigit_end
   isdigit_else:
      ble $a0, $t1, isdigit_end
      li $v0, 0
   isdigit_end:
      jr $ra

isDigit:
   # a0 = character
   # v0 = (isDigit)? 1 : 0
   li $v0, 1
   beq $a0, 'M', isdigit_end2

   li $t0, '0'
   li $t1, '9'
   bge $a0, $t0, isdigit_else2
   li $v0, 0
   j isdigit_end
   isdigit_else2:
      ble $a0, $t1, isdigit_end2
      li $v0, 0
   isdigit_end2:
      jr $ra


double_to_string:

   # ARGUMENT: f12 = double, a0 = number of decimal places
   # RETURN  : v0 = start address of returned string
   # integer part stored in a0
   move $t5, $a0
   addi $sp, $sp, -4
   sw $ra, 0($sp)


   # negate if negative and set isNegative
   li $t4, 0      # isNegative = false
   ldc1 $f16, const0
   c.lt.d $f12, $f16
   bc1f check_maxInt
      li $t4, 1
      neg.d $f12, $f12

   check_maxInt:
   mov.d $f20, $f12
   # if f12 does not exceed INT_MAX then convert to int and print normally
   # else convert to int and print the integer part with scientific notation
   li $t6, 0      # isExceedInt = false
   ldc1 $f16, INT_MAX
   c.lt.d $f12, $f16
   bc1t goto_integerpart
      li $t6, 1   # isExceedInt = true
      ldc1 $f18, const10
      li $t7, 0    # exponent (1et7)
      division_loop:
         div.d $f20, $f20, $f18
         addi $t7, $t7, 1
         c.lt.d $f20, $f18
         bc1t goto_integerpart
      j division_loop

   goto_integerpart:
   # integer part
   cvt.w.d $f0, $f20
   mov.s $f18, $f0
   mfc1 $a0, $f0
   jal int_to_string

   move $a0, $v0
   la $a1, d_to_s_result
   # store the unary sign 
   beq $t4, 0, copy_to_a1
      li $t0, '-'
      sb $t0, 0($a1)
      addi $a1, $a1, 1
   copy_to_a1:
   jal strcpy

   # if the double is just integer then dont have to print the fraction part
   cvt.w.d $f0, $f20
   cvt.d.w $f0, $f0
   sub.d $f0, $f20, $f0
   ldc1 $f16, constNearZero
   c.lt.d $f0, $f16
   bc1t done_convert

   # else continue to check fraction part
   # a1 is now at '\0' so store as '.'
   li $t0, '.'
   sb $t0, 0($a1)
   addi $a1, $a1, 1

   ldc1 $f0, const10
   # fraction part multipliedf by 10^decimal places
   cvt.w.d $f2, $f20
   cvt.d.w $f2, $f2
   sub.d $f2, $f20, $f2

   li $t2, 0     # if t2 == 1 && $f2 < 1 then stop
   # f2 is 0.xxxxx so multiply by 10 and get the integer part
   decimal_loop:
      beq $t5, $0, end_decimal_loop
      # str[a1] = int(f2*10)
      mul.d $f2, $f2, $f0

      cvt.w.d $f14, $f2
      mfc1 $t0, $f14
      addi $t0, $t0, '0'
      sb $t0, 0($a1)

      cvt.d.w $f14, $f14
      sub.d $f2, $f2, $f14
      addi $a1, $a1, 1
      addi $t5, $t5, -1
      j decimal_loop
   end_decimal_loop:
   sb $0, 0($a1)  # end of string

   done_convert:
   beq $t6, 0, just_round
      # add E^t7
      li $t0, 'E'
      sb $t0, 0($a1)
      addi $a1, $a1, 1
      move $a0, $t7
      jal int_to_string
      move $a0, $v0
      jal strcpy
      j return_done

   just_round:
      ### test
      la $a0, d_to_s_result
      li $v0, 4
      syscall

      li $a0, '\n'
      li $v0, 11
      syscall
      ### test

      la $a0, d_to_s_result
      jal rounding
   
   return_done:
   la $v0, d_to_s_result
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   jr $ra


int_to_string: 
   # this function only handles postive integers
   # ARGUMENT: a0 = integer
   # RETURN  : v0 = start address of returned string
   li $t0, 10
   move $t1, $a0

   # start of the returned string
   move $t2, $sp
   addi $sp, $sp, -1
   sb $0, 0($sp)
   addi $sp, $sp, -1
   int_to_string_loop:
      div $t1, $t0
      mflo $t1
      mfhi $t3
      addi $t3, $t3, '0'
      sb $t3, 0($sp)
      beq $t1, $0, end_int_to_string_loop
      addi $sp, $sp, -1
      j int_to_string_loop
   end_int_to_string_loop:
      move $v0, $sp
      move $sp, $t2
      jr $ra


isInteger:
   # f12 = double, v0 = (f12 isInteger)? 1 : 0
   # this function only works for number in integer range
   li $v0, 1

      li $v0, 0

   isInteger_end:
      jr $ra


rounding:
   # a0 = address of double_to_string result
   goto_fraction:
      lb $t0, 0($a0)
      beq $t0, '.', fraction_end
      addi $a0, $a0, 1
      j goto_fraction
   fraction_end:
   addi $a0, $a0, 1

   # t0 = str[i]
   # t1 counts number of 0s or 9s. if t1 == 4 then break and incre/decre str[t3]
   # t2 holds the current value (0 or 9)
   # t3 holds the address before encountering 0s or 9s

   # if (t1 == 0) {
   #    if (t0 == '0' || t0 == '9') {
   #       t1++;
   #       t2 = t0;
   #       t3 = a0 - 1;
   #    }
   # }
   # else {
   #    if (t0 == t2) {
   #       t1++;
   #       if (t1 == 6) j end_rounding
   #    }
   #    else if (t0 == '0' || t0 == '9') {
   #       t1 = 0...
   #    }
   #    else { 
   #     t3 = a0 - 1;
   #     t1 = 0;
   #    }
   # }

   li $t1, 0
   rounding_loop:
      addi $a0, $a0, 1
      lb $t0, 0($a0)
      beq $t0, $0, end_rounding_loop
      
      bne $t1, $0, t1_not_0
      beq $t0, '0', check_t0
      beq $t0, '9', check_t0
      j rounding_loop
      check_t0:
         addi $t1, $t1, 1
         move $t2, $t0
         subi $t3, $a0, 1
         j rounding_loop

      t1_not_0:   
         bne $t0, $t2, t0_not_t2
            addi $t1, $t1, 1
            beq $t1, 6, end_rounding_loop
         j rounding_loop
         t0_not_t2:
         beq $t0, '0', check_t0_1
         beq $t0, '9', check_t0_1
         j t0_not_t2_2
         check_t0_1:
            li $t1, 0
            j check_t0
         t0_not_t2_2:
            move $t3, $a0
            addi $t3, $t3, -1
            li $t1, 0
      j rounding_loop

   end_rounding_loop:
   # if t1 == 6 then incre/decre str[t3]
   bne $t1, 6, return_rounding
      bne $t2, '0', t2_is_9
         sb $0, 1($t3)
         j return_rounding

      t2_is_9:
         lb $t0, 0($t3)
         addi $t0, $t0, 1
         sb $t0, 0($t3)
         sb $0, 1($t3)
   
   return_rounding:
      jr $ra