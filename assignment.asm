.data
   inPrompt: .asciiz "Please insert your expression: "
   ### string 
   input: .space 101
   validatedString: .space 200
   stringLength: .word 0
   resultString: .space 100
   star: .asciiz "*"
   
   substr_res: .space 100
   f_to_s_result: .space 100
   str1: .space 100
   str2: .space 100
   ### string

   prompt: .asciiz "\n>> "
   quitCommand: .asciiz "quit"
   quitPrompt: .asciiz "EXIT!"
   fact: .float 0:35
   const0: .float 0.0
   const1: .float 1.0
   const10: .float 10.0
   constFloat: .float 145234.5432
   preAns: .float 0.0
   to_string_preAns: .space 100

   # error messages
   error0: .asciiz "SYNTAX ERROR: INVALID PARENTHESES!\n"
   error1: .asciiz "SYNTAX ERROR: CONTAINING INVALID CHARACTER!\n"
   error2: .asciiz "SYNTAX ERROR: INVALID '.' CHARACTER!\n"
   error3: .asciiz "SYNTAX ERROR: INVALID '!' OPERATOR!\n"
   error4: .asciiz "SYNTAX ERROR NEAR 'M' CHARACTER!\n"
   error1_1: .asciiz "SYNTAX ERROR: INVALID OPERATION!\n"
   error1_2: .asciiz "MATH ERROR: FACTORIAL OF NON-POSITIVE NUMBER!\n"
   error1_3: .asciiz "MATH ERROR: FACTORIAL IS TOO LARGE TO CALCULATE!\n"
   error1_4: .asciiz "MATH ERROR: FACTORIAL OF NON-INTEGER NUMBER!\n"
   error1_5: .asciiz "MATH ERROR: DIVISION BY ZERO!\n"

.text
# factorial:
#    lwc1 $f0, const1  # fact[index]
#    li $t1, 0                # index
#    la $t2, fact
#    factorial_loop:
#       bgt $t1, 1, fact_else
#       swc1 $f0, 0($t2)
#       j fact_increment
#    fact_else:
#    	mtc1 $t1, $f2  
#       cvt.s.w $f2, $f2
#       mul.s $f0, $f0, $f2
#       swc1 $f0, 0($t2)
#    fact_increment:
#       addi $t1, $t1, 1
#       addi $t2, $t2, 4
#       beq $t1, 35, main
#       j factorial_loop

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
      lwc1 $f12, preAns
      li $a0, 6
      jal float_to_string
      move $a0, $v0
      la $a1, to_string_preAns
      jal strcpy

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
      beq $v0, 4, Error4

      convertToPostfix:
      la $a0, validatedString
      li $v0, 4
      syscall

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
      Error4:
         li $v0, 4
         la $a0, error4
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
      lb $t0, 0($a0)
      sb $t0, 0($v0)
      addi $a2, $a2, -1
      beq $a2, $0, end_substr
      addi $a0, $a0, 1
      addi $v0, $v0, 1
      j substr_loop
   end_substr:
      sb $0, 1($v0)
      la $v0, substr_res
      jr $ra

erase:
   # this function assume all inputs are valid
   # a0 = string, a1 = start index, a2 = count
   # v0 = start address of erased string
   move $t1, $a0

   # a0 = address of a0[start]
   add $a0, $a0, $a1
   # a1 = address of a0[start+count]
   add $a1, $a0, $a2
   erase_loop:
      lb $t0, 0($a1)
      sb $t0, 0($a0)
      beq $a2, $0, end_erase
      beq $t0, $0, end_erase
      addi $a1, $a1, 1
      addi $a0, $a0, 1
      addi $a2, $a2, -1
      j erase_loop
   end_erase:
      move $v0, $t1
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


float_to_string:
   # this function only handles postive fp numbers
   # ARGUMENT: f12 = float, a0 = number of decimal places
   # RETURN  : v0 = start address of returned string
   # integer part stored in a0
   addi $sp, $sp, -4
   sw $ra, 0($sp)

   lwc1 $f14, const1
   lwc1 $f0, const10
   decimal_loop:
      beq $a0, $0, end_decimal_loop
      mul.s $f14, $f14, $f0
      addi $a0, $a0, -1
      j decimal_loop
   end_decimal_loop:

   # integer part
   trunc.w.s $f0, $f12
   mfc1 $a0, $f0
   jal int_to_string
   # save the integer part to f_to_s_result
   move $a0, $v0
   la $a1, f_to_s_result
   jal strcpy

   # a0 is now at '\0' so rewrite as '.'
   li $t0, '.'
   sb $t0, 0($a1)
   addi $a1, $a1, 1

   # fraction part multiplied by 10^decimal places
   trunc.w.s $f1, $f12
   cvt.s.w $f1, $f1
   sub.s $f1, $f12, $f1
   mul.s $f0, $f1, $f14
   trunc.w.s $f0, $f0
   mfc1 $a0, $f0
   jal int_to_string
   # save the fraction part to after the '.' of f_to_s_result
   move $a0, $v0  # a1 is at the start of fraction part
   jal strcpy
   sb $0, 0($a1)  # end of string

   la $v0, f_to_s_result
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

########################################
########################################
###      expression functions      ###
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
   li $v0, 2
   beq $a0, '*', precedence_end
   beq $a0, '/', precedence_end
   li $v0, 3
   beq $a0, '^', precedence_end
   li $v0, 4
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
         beq $s0, $0, if_elseif
         # if (i > 0) 
            addi $t0, $s0, -1
            add $t2, $a0, $t0
            lb $a0, 0($t2)
            jal isdigit
            beq $v0, 1, insert_multiplication
            beq $a0, ')', insert_multiplication
            j if_elseif
            insert_multiplication:
               la $a0, validatedString
               la $a1, star
               move $a2, $s0
               jal strInsert
               move $a0, $v0
               addi $s0, $s0, 1
               j substitute_ans
         if_elseif:
            la $a0, validatedString
            jal strLen
            addi $t0, $s0, 1
            beq $t0, $v0, substitute_ans
            la $a0, validatedString
            add $t1, $t0, $a0
            lb $a0, 0($t1)
            jal isdigit
            beq $v0, 0, substitute_ans
            return4:
               li $v0, 4
               move $sp, $fp
               lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra
         substitute_ans:
            la $a0, validatedString
            move $a1, $s0
            li $a2, 1
            jal erase
            la $a0, validatedString
            la $a1, to_string_preAns
            move $a2, $s0
            jal strInsert
            la $a0, to_string_preAns
            jal strLen
            add $s0, $s0, $v0
            addi $s0, $s0, -1
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
         jal isdigit
         beq $v0, 1, insert_multiplication2
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
         jal isdigit
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
            addi $t0, $s0, 1
            la $a0, validatedString
            jal strLen
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
         jal isdigit
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
         jal validOps
         beq $v0, 1, validated_increment
         jal isdigit
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
      lb $t1, 0($a0)
      bne $t1, '+', return
      li $a1, 0
      li $a2, 1
      jal erase
   return:
      li $v0, -1
      move $sp, $fp
      lw $ra, 0($sp)
      addi $sp, $sp, 4
      jr $ra


infixToPostfix:
   jr $ra



########################################
########################################

pow:
   # f0 = f12 ^ a0
   lwc1 $f0, const1
   li $t0, 0     # isNegative = false
   bgt $a0, 0, pow_loop
   li $t0, 1     # isNegative = true
   neg $a0, $a0
   pow_loop:
      beq $a0, 0, pow_check_neg
      mul.s $f0, $f0, $f12
      addiu $a0, $a0, -1
      j pow_loop
   pow_check_neg:
      beq $t0, 0, pow_end
      lwc1 $f1, const1
      div.s $f0, $f1, $f0
   pow_end:
      jr $ra

