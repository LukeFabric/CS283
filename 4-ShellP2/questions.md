1. Can you think of why we use `fork/execvp` instead of just calling `execvp` directly? What value do you think the `fork` provides?

    > **Answer**:  We use fork/execvp instead of directly calling execvp because if we did not call fork, our shell would be overwritten with the contents of the program that we are calling, and that would cause us to lose our shell. By forking, we are able to create a copy that can be overwritten, as it will return to the parent process and allow for continued execution of shell commands. 

2. What happens if the fork() system call fails? How does your implementation handle this scenario?

    > **Answer**:  If the fork system call fails, it will the return value less than zero, and in my implementation, I check that value and set the return_code variable to indicate an error and display a message, as no fork was created and thus whatever command the user was trying to run never executed.

3. How does execvp() find the command to execute? What system environment variable plays a role in this process?

    > **Answer**:  execvp searches the PATH environment of a system to look for binaries to execute, and the contents of
    this environment are contained in the PATH environment variable.

4. What is the purpose of calling wait() in the parent process after forking? What would happen if we didn’t call it?

    > **Answer**:  The reason that we need to call wait is to suspend the parent process and wait to continue execution until the child process has finished running. Wait will also return the exit status of the child process, allowing the parent to deal with any errors that may have arisen. If we did not call wait, the parent could finish executing before the child, seperating the two and creating a zombie process that will linger until it is terminated.

5. In the referenced demo code we used WEXITSTATUS(). What information does this provide, and why is it important?

    > **Answer**:  WEXITSTATUS() gives us the exit status after the child process after it has executed. This is important as it allows us to ensure that the child executed properly and it allows the parent process to handle any errors that could have occured in the child.

6. Describe how your implementation of build_cmd_buff() handles quoted arguments. Why is this necessary?

    > **Answer**:  For my implementation, when the program first comes across quotes, it sets a flag and does not stop to point to a new argument if it comes across whitespace, only pointing to a new argument after the other pair of quotes are found. This is necessary as shells use whitespace to deliminate arguments, and so making sure that we don't accidentally split the string into different args and keeps it all together as one argument.

7. What changes did you make to your parsing logic compared to the previous assignment? Were there any unexpected challenges in refactoring your old code?

    > **Answer**:  For my parsing logic, I first got rid of the leading and trailing whitespace, like I did previously, and then I look if any arguments exist, and then I go over the string, character by character, looking for whitespace and quotes to deliniate arguments and building the argv array. 

8. For this quesiton, you need to do some research on Linux signals. You can use [this google search](https://www.google.com/search?q=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&oq=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBBzc2MGowajeoAgCwAgA&sourceid=chrome&ie=UTF-8) to get started.

- What is the purpose of signals in a Linux system, and how do they differ from other forms of interprocess communication (IPC)?

    > **Answer**:  The purpose of a linux signal is to allow processes to signal asynchronous events with each other. This enables them to communicate without disrupting execution of other programs on the system. They are different from other forms of IPC in that they aren't between on program finishing and another program ending, like pipes, and tools that manage access to resources between processes running simultaneously, like message queues and semaphores, and shared memory where processes share virtual address space. 

- Find and describe three commonly used signals (e.g., SIGKILL, SIGTERM, SIGINT). What are their typical use cases?

    > **Answer**:  SIGKILL - Terminates a process immediantly. Used to kill process that won't die from a Ctrl+C signal or when some sort of hardware exception occurs. SIGTERM - Tells a program that it is about to be terminated. The typical use case is when you want to kill a program gracefully and allow it to clean up. SIGINT is used for when a keyboard interrupt is detected from the user saying to kill the process. This is used to kill programs when the user requests it, such as with key combinations like Ctrl+C or CRTL+Z.

- What happens when a process receives SIGSTOP? Can it be caught or ignored like SIGINT? Why or why not?

    > **Answer**:  When a process receives SIGSTOP, the process is immediantly stopped. It can't be caught or ignored like SIGINT, as it is an order to terminate now, as it is an absolute command from the operating system to end execution, and that it can't do anything like clean up, it must stop executing now.

