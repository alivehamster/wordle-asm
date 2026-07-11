.globl _start


.section .data
  idk:
    .ascii "\033[32mHello World\n\033[0m"
  idk_len = . - idk

.section .text
_start:
  mov $1, %rax          # sys call for write
  mov $1, %rdi          # set fd which is 1 for stdout
  leaq idk(%rip), %rsi    # set buffer address
  mov $idk_len, %rdx         # set msg size
  syscall


  # exit program with successfull status code
  mov $60, %rax         # exit
  mov $0, %rdi          # exit status
  syscall
