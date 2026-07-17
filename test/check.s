.globl _start

.section .data
  word:
    .ascii "laugh\n"
  word_len = . - word

  tmp:
    .ascii "hello\n"
  tmp_len = . - tmp

.section .bss
  # 5 bytes held status ex vowed, wafer = ynngn
  buffer:
    .space 6

.section .text
_start:

  leaq buffer(%rip), %rsi # set buffer address
  xorq %rcx, %rcx
  leaq word(%rip), %rax
  leaq tmp(%rip), %rbx
match_loop:
  cmpq $5, %rcx
  jge next

  movb (%rax,%rcx,1), %dl
  movb (%rbx,%rcx,1), %r11b
  cmpb %r11b, %dl
  je  match
  movb $'n', (%rsi,%rcx,1)
  incq %rcx
  jmp match_loop
  
match:
  movb $'g', (%rsi,%rcx,1)
  incq %rcx
  jmp match_loop

next:
  xorq %rcx, %rcx
next_loop:
  cmpq $5, %rcx
  jge end

  cmpb $'g', (%rsi,%rcx,1)
  je continue

  xorq %r8, %r8
  movb (%rbx,%rcx,1), %r11b
  jmp word_loop

continue:
  incq %rcx
  jmp next_loop

word_loop:
  cmpq $5, %r8
  jge continue

  movb (%rax,%r8,1), %dl

  incq %r8

  cmpb %r11b, %dl
  jne word_loop

  movb $'y', (%rsi,%rcx,1)
  jmp continue

end:
  movb $'\n', 5(%rsi)

  mov $1, %rax          # sys call for write
  mov $1, %rdi          # set fd which is 1 for stdout
  leaq buffer(%rip), %rsi    # set buffer address
  mov $6, %rdx         # set msg size
  syscall


  # exit program with successfull status code
  mov $60, %rax         # exit
  mov $0, %rdi          # exit status
  syscall
