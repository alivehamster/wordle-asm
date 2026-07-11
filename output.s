
.section .bss 
  buffer:
    .space 40

.section .text
.globl display

display:
  xorq %rdx, %rdx # buffer index
  leaq buffer(%rip), %rsi # buffer address
  movq $5, %rcx # move right counter
  call erase
  xorq %rcx, %rcx # loop counter
  xorq %r9, %r9 # correct counter
gen_output_loop:
  cmpq $5, %rcx
  jge output

  movb (%rbx,%rcx,1), %r8b
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
  movb (%rax,%rcx,1), %r8b
  movb %r8b, (%rsi,%rdx,1)
  incq %rdx

  incq %r9
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
  movb (%rax,%rcx,1), %r8b
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
  movb (%rax,%rcx,1), %r8b
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

erase:
  call thing
  movb $'A', (%rsi,%rdx,1)
  incq %rdx
erase_loop:
  call thing
  movb $'C', (%rsi,%rdx,1)
  incq %rdx
  decq %rcx
  jnz erase_loop

  ret

output:
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
  syscall
  ret
