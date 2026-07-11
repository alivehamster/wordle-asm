.globl _start

.section .rodata    # .rodata is "Read-Only Data"
.global embedded_file_start
.global embedded_file_end

embedded_file_start:
  .incbin "../WORDS.txt"       # The assembler dumps the entire file's bytes right here
embedded_file_end:

.equ file_size, (embedded_file_end - embedded_file_start)
.equ word_count, (embedded_file_end - embedded_file_start) / 6

.section .text
_start:

  mov $word_count, %rax

  call random_number

  imulq $6, %rax, %rax
  leaq embedded_file_start(%rax), %rsi    # set buffer address
  mov $1, %rax          # sys call for write
  mov $1, %rdi          # set fd which is 1 for stdout
  mov $6, %rdx         # set msg size
  syscall    


  # exit program with successfull status code
  movq $60, %rax         # exit
  movq $0, %rdi          # exit status
  syscall
