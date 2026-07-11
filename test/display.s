.globl _start

.section .bss 
  buffer:
    .space 31

.section .data
  word:
    .ascii "vowed"

  status:
    .ascii "ynngn"

.section .text
_start:
  leaq status(%rip), %rax
  leaq word(%rip), %r12

  xorq %rdx, %rdx
  xorq %rcx, %rcx
  leaq buffer(%rip), %rsi
gen_output_loop:
  cmpq $5, %rcx
  jge end

  movb (%rax,%rcx,1), %r8b
  cmpb $'g', %r8b
  je  g
  cmpb $'y', %r8b
  je  y
  cmpb $'n', %r8b
  je  n

g:
  call thing

  movb $'3', (%rsi,%rdx,1)
  incq %rdx
  movb $'2', (%rsi,%rdx,1)
  incq %rdx
  movb $'m', (%rsi,%rdx,1)
  incq %rdx
  movb (%r12,%rcx,1), %r8b
  movb %r8b, (%rsi,%rdx,1)
  incq %rdx

  incq %rcx
  jmp gen_output_loop
y:
  call thing

  movb $'3', (%rsi,%rdx,1)
  incq %rdx
  movb $'3', (%rsi,%rdx,1)
  incq %rdx
  movb $'m', (%rsi,%rdx,1)
  incq %rdx
  movb (%r12,%rcx,1), %r8b
  movb %r8b, (%rsi,%rdx,1)
  incq %rdx

  incq %rcx
  jmp gen_output_loop
n:
  call thing

  movb $'0', (%rsi,%rdx,1)
  incq %rdx
  movb $'m', (%rsi,%rdx,1)
  incq %rdx
  movb (%r12,%rcx,1), %r8b
  movb %r8b, (%rsi,%rdx,1)
  incq %rdx

  incq %rcx
  jmp gen_output_loop

thing:
  movb $27, (%rsi,%rdx,1) # same as \033
  incq %rdx
  movb $'[', (%rsi,%rdx,1)
  incq %rdx
  ret

end:
  call thing

  movb $'0', (%rsi,%rdx,1)
  incq %rdx
  movb $'m', (%rsi,%rdx,1)
  incq %rdx
  movb $'\n', (%rsi,%rdx,1)
  incq %rdx

  mov $1, %rax          # sys call for write
  mov $1, %rdi          # set fd which is 1 for stdout
  leaq buffer(%rip), %rsi    # set buffer address
#  mov $idk_len, %rdx         # set msg size
  syscall


  # exit program with successfull status code
  mov $60, %rax         # exit
  mov $0, %rdi          # exit status
  syscall
