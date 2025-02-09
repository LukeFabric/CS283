1. In this assignment I suggested you use `fgets()` to get user input in the main while loop. Why is `fgets()` a good choice for this application?

    > **Answer**: fgets is a good choice to use the main loop as it will go character by character over a certain stream
    and read them until it reaches the end of the file. This works great for getting input from stdin as we can get
    each line of input from the user and then store and act on them.

2. You needed to use `malloc()` to allocte memory for `cmd_buff` in `dsh_cli.c`. Can you explain why you needed to do that, instead of allocating a fixed-size array?

    > **Answer**: We used malloc because we might need to resize the cmd_buff if the inputted command overruns the space
    allocated for the buffer, and dynamically allocating it allows us to make `cmd_buff` bigger and store all the input
    the user gave us.


3. In `dshlib.c`, the function `build_cmd_list()` must trim leading and trailing spaces from each command before storing it. Why is this necessary? If we didn't trim spaces, what kind of issues might arise when executing commands in our shell?

    > **Answer**: We must trim whitespace to assure that we know which command is which and it allows us to clearly
    seperate commands. For example, if we give a command and put an extra space at the end, one might expect that args
    would follow, and that would cause the command to be stored improperly. Removing that whitespace removes ambiguity
    and makes it clear that there are no arguments associated with that command. 

4. For this question you need to do some research on STDIN, STDOUT, and STDERR in Linux. We've learned this week that shells are "robust brokers of input and output". Google _"linux shell stdin stdout stderr explained"_ to get started.

- One topic you should have found information on is "redirection". Please provide at least 3 redirection examples that we should implement in our custom shell, and explain what challenges we might have implementing them.

    > **Answer**: Example 1: cmd1 < test.txt 2 stdin redirect
    > Example 2: cmd1 >  test.txt stdout redirection
	> Example 3: cmd1 >> test.txt stdout append instead of clobber
    >
    > In example one, we need to verify that the file we are reading from exists, and that we can properly parse it
    going line by line. In example 2, we have to be concerned if we have permissions to write to the specified output
    file and then properly capturing the output to write to the file. In example 3, not only do we have to ensure we can
    write to the file, but we also have to find the end of the file and start writing from there.

- You should have also learned about "pipes". Redirection and piping both involve controlling input and output in the shell, but they serve different purposes. Explain the key differences between redirection and piping.

    > **Answer**: A pipe takes the output of one program and puts into stdin of another to then be used by that second
    program, whereas redirection either reads or writes to a seperate file that is just storing the contents, not using
    them in program execution.

- STDERR is often used for error messages, while STDOUT is for regular output. Why is it important to keep these separate in a shell?

    > **Answer**: Keeping STDOUT and STRERR seperate makes it easier to distiguish between things that are just meant to
    be normal output displayed to the user, and issues that need to be addressed. Seperating these streams also allows
    them to be stored seperately, as one could redirect the output of STDERR to a log file or something similar to keep
    track of errors, and stdout can just be put to the screen and not retained. Not having these be seperate would
    waster space as we would just capture and store all output, instead of just the errors that have occured.

- How should our custom shell handle errors from commands that fail? Consider cases where a command outputs both STDOUT and STDERR. Should we provide a way to merge them, and if so, how?

    > **Answer**:  We should provide a way to merge both, as the user should be informed about what errors have occured.
    For example, in bash you can put `2>&1` to signal the fact that you want to redirect stderr back to stdout and merge
    the two outputs. We can then use something similar in our shell to merge the two outputs and put the errors in both
    STDOUT and STDERR.
