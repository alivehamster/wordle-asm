.section .bss
  buffer:
    .space 6

# .section .data
#   tmp:
#     .ascii "laugh\n"

.section .text
.global check
.global word_select

check:
  leaq buffer(%rip), %rsi # set buffer address
  xorq %rcx, %rcx
match_loop:
  cmpq $5, %rcx
  jge next

  movb (%r12,%rcx,1), %dl
  movb (%rax,%rcx,1), %r11b
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
  movb (%rax,%rcx,1), %r11b
  jmp word_loop

continue:
  incq %rcx
  jmp next_loop

word_loop:
  cmpq $5, %r8
  jge continue
  movb (%r12,%r8,1), %dl

  incq %r8

  cmpb %r11b, %dl
  jne word_loop

  movb $'y', (%rsi,%rcx,1)
  jmp continue

end:
  mov %rsi, %rbx
  ret


word_select:
  call random_number

  imulq $6, %rax, %rax
  leaq embedded_file_start(%rip), %r10
  addq %r10, %rax

  # leaq tmp(%rip), %rax # Debug: Overwrite random word with tmp word

  ret
  

random_number:
  # rax holds max

  movq %rax, %rcx
  addq $1, %rcx              # range = max - min + 1

  rdrand  %rax                # Try to get a hardware random number into %rax


  # 3. Clear %rdx before unsigned division (divq divides %rdx:%rax by the operand)
  xorq    %rdx, %rdx          
  divq    %rcx                # %rax = quotient, %rdx = remainder (0 to 40)

  # 5. Move the result to %rax to return it
  movq    %rdx, %rax
  ret
