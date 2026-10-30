.section .bss
  buffer:
    .space 6
.section .data
  invalid_txt:
    .ascii "Invalid input, please enter a 5 letter word\n"
  invalid_len = . - invalid_txt
# .section .data
#   tmp:
#     .ascii "laugh\n"

.section .text
.global check
.global word_select
.global lengthcheck

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

lengthcheck:
  # input is 7 bytes read; %rsi still points at it, %rax is bytes read
  cmpq $6, %rax
  jne invalid_length
  cmpb $'\n', 5(%rsi)
  je valid_length

invalid_length:
  # drain only if the line's newline has not been consumed yet
  testq %rax, %rax
  jle report_invalid
  cmpb $'\n', -1(%rsi,%rax,1)
  je report_invalid
  call clearstdin

report_invalid:
  mov $1, %rax          # sys call for write
  mov $1, %rdi          # stdout
  leaq invalid_txt(%rip), %rsi
  mov $invalid_len, %rdx         # set msg size
  syscall
valid_length:
  ret

clearstdin:
  # read one byte at a time until newline or EOF
  mov $0, %rax          # sys call for read
  mov $0, %rdi          # stdin
  leaq buffer(%rip), %rsi      # set buffer address
  mov $1, %rdx          # one byte
  syscall
  cmpq $1, %rax
  jne drained
  cmpb $'\n', buffer(%rip)
  jne clearstdin
drained:
  ret
