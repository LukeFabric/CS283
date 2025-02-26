1. Your shell forks multiple child processes when executing piped commands. How does your implementation ensure that all child processes complete before the shell continues accepting user input? What would happen if you forgot to call waitpid() on all child processes?

My shell uses a for loop to wait for all children to exit through waitpid, and once all the children have exited it
returns to the supervisor which can then terminate itself. If I did not call waitpid, the parent could finish before the
children, leaving zombie processes.

2. The dup2() function is used to redirect input and output file descriptors. Explain why it is necessary to close unused pipe ends after calling dup2(). What could go wrong if you leave pipes open?

You have to close the opposite ends so that only one other process tries to read from the pipe, but more importantly, if
they were not closed, we would have a file descriptor leak, and that would eventually lead to us running out of file
descriptors, causing the program to crash.

3. Your shell recognizes built-in commands (cd, exit, dragon). Unlike external commands, built-in commands do not require execvp(). Why is cd implemented as a built-in rather than an external command? What challenges would arise if cd were implemented as an external process?

cd is a built-in command because if we used the external program, it would fork and change the directory of that
process, but that change of directory doesn't affect the parent process, so the child will move but when it exits the
parent will still be where it was before.

4. Currently, your shell supports a fixed number of piped commands (CMD_MAX). How would you modify your implementation to allow an arbitrary number of piped commands while still handling memory allocation efficiently? What trade-offs would you need to consider?

I would need to dynamically allocate the number of commands in the structure, as well as the original cmd_buff to allow
inputs of any size. I would probably set it to some number initially, and then if a command goes over that limit, double
the number of commands to reduce future resizing. I would need to consider the amount of memory that I'm taking up
versus how many times I want to spend more cycles reallocating memory, so performance versus storage space.
