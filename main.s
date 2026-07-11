.globl _start

.section .rodata
.global embedded_file_start
.global embedded_file_end

embedded_file_start:
  .incbin "WORDS.txt" # Load wordlist into binary
embedded_file_end:

.equ file_size, (embedded_file_end - embedded_file_start)
.equ word_count, file_size / 6

.section .data
  welcome:
    .ascii "5 tries to guess the word 5 letter word\n"
  welcome_len = . - welcome

  count:
    .ascii " /5: "

  fail_txt:
    .ascii "You failed to guess the word      \n"
  fail_len = . - fail_txt

.section .bss
  input:
    .space 6

.section .text
_start:
  mov $1, %rax          # sys call for write
  mov $1, %rdi          # stdout
  leaq welcome(%rip), %rsi
  mov $welcome_len, %rdx         # set msg size
  syscall

  mov $word_count, %rax
  # accept num of words in rax return in rax
  call word_select
  mov %rax, %r12

  #### Testing ####
  mov $1, %rax          # sys call for write
  mov $1, %rdi          # set fd which is 1 for stdout
  mov %r12, %rsi    # set buffer address
  mov $6, %rdx         # set msg size
  syscall
  #### End Testing ####

  movq $5, %r13 # loop 5 times
answer_loop:

  leaq count(%rip), %rsi
  movq $54, %rax
  subq %r13, %rax
  movb %al, (%rsi)

  mov $1, %rax          # sys call for write
  mov $1, %rdi          # set fd which is 1 for stdout
  mov $5, %rdx         # set msg size
  syscall

  mov $0, %rax          # sys call for read
  mov $0, %rdi          # stdin
  leaq input(%rip), %rsi      # set buffer address
  mov $6, %rdx          # set msg size
  syscall

  leaq input(%rip), %rax
  call check

  call display

  cmpq $5, %r9
  je correct

  decq %r13
  jnz answer_loop

  leaq fail_txt(%rip), %rsi    # set buffer address
  leaq 29(%rsi), %rbx
  xorq %rcx, %rcx
fail:
  cmpq $5, %rcx
  jge end_fail

  movb (%r12,%rcx,1), %al
  movb %al, (%rbx,%rcx,1)
  incq %rcx
  jmp fail

end_fail:
  mov $1, %rax          # sys call for write
  mov $1, %rdi          # stdout
  mov $fail_len, %rdx         # set msg size
  syscall
  mov $60, %rax         # exit
  mov $0, %rdi          # exit status
  syscall

correct:
  mov $60, %rax         # exit
  mov $0, %rdi          # exit status
  syscall
