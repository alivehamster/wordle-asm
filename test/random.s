.globl _start


.section .text
_start:


  rdrand  %rax                # Try to get a hardware random number into %rax

  # 2. Define our range parameters
  # Range = MAX (50) - MIN (10) + 1 = 41
  movq    $41, %rcx           # %rcx = range size (divisor)

  # 3. Clear %rdx before unsigned division (divq divides %rdx:%rax by the operand)
  xorq    %rdx, %rdx          
  divq    %rcx                # %rax = quotient, %rdx = remainder (0 to 40)


  # 5. Move the result to %rax to return it
  movq    %rdx, %rdi


  # exit program with successfull status code
  mov $60, %rax         # exit
  # mov $0, %rdi          # exit status
  syscall
