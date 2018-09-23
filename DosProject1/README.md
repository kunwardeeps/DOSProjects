# DosProject 1

**Group info**
  #1. Kunwardeep Singh (UFID - 2421 3955)
  #2. Gayatri Behera (UFID - 3258 9909)

**Instructions**
  Run the project by giving the commands:
  'mix run proj1.exs [arg1] [arg2]' - for regular output
  'time mix run proj1.exs [arg1] [arg2]' - to display time & regular output

**Size of the work unit**
  The work unit has been decided after trying out with different values and optimizing it. 
  Following logic is being used to find work unit based on input:

  Taking log to the base 10 of the input size (n). This integer number is then halved
  & the work-unit is considered as -

  work-unit = 10^(number)

  eg. if n = 1,000,000

  so, log(10^6) to base 10 => 6

  work-unit = 10^(6/2) = 10^3.

  So, in this case we've taken size of work-unit as 1,000 for an input(n) of 1,000,000

**The result of running your program for mix run proj1.exs 1000000 4**

real time = 1.430s
CPU time = 3.208s + 0.104s = 3.284s
CPU time /real time = 2.316

**The largest problem you managed to solve.**
mix run proj1.exs 1000000000 4
