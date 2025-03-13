#include <sys/socket.h>
#include <sys/wait.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/un.h>
#include <fcntl.h>
#include <errno.h>

//INCLUDES for extra credit
#include <signal.h>
#include <pthread.h>
//-------------------------

#include "dshlib.h"
#include "rshlib.h"

/*
 * start_server(ifaces, port, is_threaded)
 *      ifaces:  a string in ip address format, indicating the interface
 *              where the server will bind.  In almost all cases it will
 *              be the default "0.0.0.0" which binds to all interfaces.
 *              note the constant RDSH_DEF_SVR_INTFACE in rshlib.h
 * 
 *      port:   The port the server will use.  Note the constant 
 *              RDSH_DEF_PORT which is 1234 in rshlib.h.  If you are using
 *              tux you may need to change this to your own default, or even
 *              better use the command line override -s implemented in dsh_cli.c
 *              For example ./dsh -s 0.0.0.0:5678 where 5678 is the new port  
 * 
 *      is_threded:  Used for extra credit to indicate the server should implement
 *                   per thread connections for clients  
 * 
 *      This function basically runs the server by: 
 *          1. Booting up the server
 *          2. Processing client requests until the client requests the
 *             server to stop by running the `stop-server` command
 *          3. Stopping the server. 
 * 
 *      This function is fully implemented for you and should not require
 *      any changes for basic functionality.  
 * 
 *      IF YOU IMPLEMENT THE MULTI-THREADED SERVER FOR EXTRA CREDIT YOU NEED
 *      TO DO SOMETHING WITH THE is_threaded ARGUMENT HOWEVER.  
 *      test
 */
int start_server(char *ifaces, int port, int is_threaded){
    int svr_socket;
    int rc;

    //
    //TODO:  If you are implementing the extra credit, please add logic
    //       to keep track of is_threaded to handle this feature
    //

    svr_socket = boot_server(ifaces, port);
    if (svr_socket < 0){
        int err_code = svr_socket;  //server socket will carry error code
        return err_code;
    }
    if (is_threaded == 0){
        rc = process_cli_requests(svr_socket);
    } else {
        rc = process_cli_requests_threaded(svr_socket);
    }

    stop_server(svr_socket);


    return rc;
}

/*
 * stop_server(svr_socket)
 *      svr_socket: The socket that was created in the boot_server()
 *                  function. 
 * 
 *      This function simply returns the value of close() when closing
 *      the socket.  
 */
int stop_server(int svr_socket){
    return close(svr_socket);
}

/*
 * boot_server(ifaces, port)
 *      ifaces & port:  see start_server for description.  They are passed
 *                      as is to this function.   
 * 
 *      This function "boots" the rsh server.  It is responsible for all
 *      socket operations prior to accepting client connections.  Specifically: 
 * 
 *      1. Create the server socket using the socket() function. 
 *      2. Calling bind to "bind" the server to the interface and port
 *      3. Calling listen to get the server ready to listen for connections.
 * 
 *      after creating the socket and prior to calling bind you might want to 
 *      include the following code:
 * 
 *      int enable=1;
 *      setsockopt(svr_socket, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int));
 * 
 *      when doing development you often run into issues where you hold onto
 *      the port and then need to wait for linux to detect this issue and free
 *      the port up.  The code above tells linux to force allowing this process
 *      to use the specified port making your life a lot easier.
 * 
 *  Returns:
 * 
 *      server_socket:  Sockets are just file descriptors, if this function is
 *                      successful, it returns the server socket descriptor, 
 *                      which is just an integer.
 * 
 *      ERR_RDSH_COMMUNICATION:  This error code is returned if the socket(),
 *                               bind(), or listen() call fails. 
 * 
 */
int boot_server(char *ifaces, int port){
    int listen_socket;
    int ret;
    
    struct sockaddr_in addr;

    /* Create local socket. */
    listen_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_socket == -1) {
        perror("socket");
        return ERR_RDSH_COMMUNICATION;
    }

    /*
     * NOTE this is good for development as sometimes port numbers
     * get held up, this forces the port to be bound, do not use
     * in a real application
     */
    //int enable=1;
    //setsockopt(listen_socket, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int));
    
    /* Bind socket to socket name. */
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr(ifaces);
    addr.sin_port = htons(port);

    ret = bind(listen_socket, (const struct sockaddr *) &addr,
               sizeof(struct sockaddr_in));
    if (ret == -1) {
        perror("accept");
        return ERR_RDSH_COMMUNICATION;
    }

    /*
     * Prepare for accepting connections. The backlog size is set
     * to 20. So while one request is being processed other requests
     * can be waiting.
     */
    ret = listen(listen_socket, MAX_CONNECTIONS);
    if (ret == -1) {
        perror("listen");
        return ERR_RDSH_COMMUNICATION;
    }    
    return listen_socket;
}

/*
 * process_cli_requests(svr_socket)
 *      svr_socket:  The server socket that was obtained from boot_server()
 *   
 *  This function handles managing client connections.  It does this using
 *  the following logic
 * 
 *      1.  Starts a while(1) loop:
 *  
 *          a. Calls accept() to wait for a client connection. Recall that 
 *             the accept() function returns another socket specifically
 *             bound to a client connection. 
 *          b. Calls exec_client_requests() to handle executing commands
 *             sent by the client. It will use the socket returned from
 *             accept().
 *          c. Loops back to the top (step 2) to accept connecting another
 *             client.  
 * 
 *          note that the exec_client_requests() return code should be
 *          negative if the client requested the server to stop by sending
 *          the `stop-server` command.  If this is the case step 2b breaks
 *          out of the while(1) loop. 
 * 
 *      2.  After we exit the loop, we need to cleanup.  Dont forget to 
 *          free the buffer you allocated in step #1.  Then call stop_server()
 *          to close the server socket. 
 * 
 *  Returns:
 * 
 *      OK_EXIT:  When the client sends the `stop-server` command this function
 *                should return OK_EXIT. 
 * 
 *      ERR_RDSH_COMMUNICATION:  This error code terminates the loop and is
 *                returned from this function in the case of the accept() 
 *                function failing. 
 * 
 *      OTHERS:   See exec_client_requests() for return codes.  Note that positive
 *                values will keep the loop running to accept additional client
 *                connections, and negative values terminate the server. 
 * 
 */
int process_cli_requests(int svr_socket){
    int data_socket;
    int ret;
    while (1) {
       data_socket = accept(svr_socket, NULL, NULL);
       if (data_socket == -1) {
           perror("accept");
           close(data_socket);
           return ERR_RDSH_COMMUNICATION;
       }

       ret = exec_client_requests(data_socket);
       shutdown(data_socket, SHUT_RDWR);
       if (ret < 0) {
          break;
       }
    }
    return 0;
}
int process_cli_requests_threaded(int svr_socket){
    void* status = 0;
    int socket_list[MAX_CONNECTIONS];
    pthread_t thread_id[MAX_CONNECTIONS];
    for (int i = 0; i < MAX_CONNECTIONS; i++ ) {
        socket_list[i] = svr_socket;
    }
    for (int i = 0; i < MAX_CONNECTIONS; i++) {
       if (pthread_create(&thread_id[i], NULL, exec_client_requests_threaded, (void*)&socket_list[i]) < 0) {
           perror("could not create thread");
           return ERR_RDSH_COMMUNICATION;
       }
    }
    for (int i = 0; i < MAX_CONNECTIONS; i++) {
        pthread_join(thread_id[i], &status);
        if (status != 0) {
            for (int j = i+1; j < MAX_CONNECTIONS; j++) {
                pthread_kill(thread_id[j], 0);
            }
            break;
        }
    }
    return 0;
}
void* exec_client_requests_threaded(void* arg) {
    int sock = *((int*)arg);
    int rc;
    int cli_socket = accept(sock, NULL, NULL);
    if (cli_socket == -1) {
        perror("accept");
        pthread_exit((void*)ERR_RDSH_COMMUNICATION);
    }
    rc = exec_client_requests(cli_socket);
    close(cli_socket);
    if (rc == 0) {
        pthread_exit(0);
    } else {
        *(int*) arg = rc;
        pthread_exit(arg);
    }
}
/*
 * exec_client_requests(cli_socket)
 *      cli_socket:  The server-side socket that is connected to the client
 *   
 *  This function handles accepting remote client commands. The function will
 *  loop and continue to accept and execute client commands.  There are 2 ways
 *  that this ongoing loop accepting client commands ends:
 * 
 *      1.  When the client executes the `exit` command, this function returns
 *          to process_cli_requests() so that we can accept another client
 *          connection. 
 *      2.  When the client executes the `stop-server` command this function
 *          returns to process_cli_requests() with a return code of OK_EXIT
 *          indicating that the server should stop. 
 * 
 *  Note that this function largely follows the implementation of the
 *  exec_local_cmd_loop() function that you implemented in the last 
 *  shell program deliverable. The main difference is that the command will
 *  arrive over the recv() socket call rather than reading a string from the
 *  keyboard. 
 * 
 *  This function also must send the EOF character after a command is
 *  successfully executed to let the client know that the output from the
 *  command it sent is finished.  Use the send_message_eof() to accomplish 
 *  this. 
 * 
 *  Of final note, this function must allocate a buffer for storage to 
 *  store the data received by the client. For example:
 *     io_buff = malloc(RDSH_COMM_BUFF_SZ);
 *  And since it is allocating storage, it must also properly clean it up
 *  prior to exiting.
 * 
 *  Returns:
 * 
 *      OK:       The client sent the `exit` command.  Get ready to connect
 *                another client. 
 *      OK_EXIT:  The client sent `stop-server` command to terminate the server
 * 
 *      ERR_RDSH_COMMUNICATION:  A catch all for any socket() related send
 *                or receive errors. 
 */
int exec_client_requests(int cli_socket) {
    int return_code = 0;
    int ret;
    int pipeCount;
    char* io_buff = malloc(RDSH_COMM_BUFF_SZ);
    if (io_buff == NULL) {
        send_message_string(cli_socket, "Error Allocating Memory\n");
        return 0; //Returns 0 to close connection
    }
    command_list_t* cmdList = malloc(sizeof(command_list_t));
    if (cmdList == NULL) {
        send_message_string(cli_socket, "Error Allocating Memory\n");
        return 0;
    }
    while(1) {
        memset(io_buff, 0, RDSH_COMM_BUFF_SZ);
        int recv_size = recv(cli_socket, io_buff, RDSH_COMM_BUFF_SZ, 0);
        if (recv_size < 0) {
            return ERR_RDSH_COMMUNICATION;
        }
        if (strlen(io_buff) == 0 && io_buff[0] == '\0') {
            return_code = WARN_NO_CMDS;
            continue;
        }
        pipeCount = countPipes(io_buff);
        if (pipeCount >= CMD_MAX) {
           send_message_string(cli_socket, "Error: piping limited to 8 commands\n");
           return_code = ERR_TOO_MANY_COMMANDS;
           continue;
        }
        ret = build_cmd_list(io_buff, cmdList);
        ret = processCmdListError(ret, cli_socket, cmdList);
        if (ret == OK) {
            return_code = executeCommand(cmdList, cli_socket, return_code);
            if (return_code == 99) {
                break;
            } else if (return_code == 105) {
                printf(RCMD_MSG_SVR_STOP_REQ);
                free_cmd_list(cmdList);
                free(cmdList);
                free(io_buff);
                return -1;
            } else if (return_code != 0) {
                return_code = ERR_EXEC_CMD;
            }
        } else {
            return_code = ret;
            continue;
        }
        clear_cmd_list(cmdList);
    }
    free_cmd_list(cmdList);
    free(cmdList);
    free(io_buff);
    return 0;
}
int executeCommand(command_list_t* cList,int cli_socket, int return_code) {
    int rc;
    if (cList->num == 1) {
        Built_In_Cmds result = rsh_built_in_cmd(cList->commands[0], return_code, cli_socket);
        if (result == BI_CMD_EXIT) {
            return 99;
        } else if (result == BI_EXECUTED) {
            return OK;
        } else if (result == BI_NOT_BI) {
            rc = rsh_execute_pipeline(cli_socket, cList);
            //printErrorServer(rc, cli_socket);
            return rc;
        } else if (result == BI_CMD_STOP_SVR) {
            return 105;
        } else {
            return -1;
        }
    } else {
        rc = rsh_execute_pipeline(cli_socket, cList);
        return rc;
    }
    return OK;
}
        


void printErrorServer(int error, int cli_socket) {
    switch (error) {
        case E2BIG:
            send_message_string(cli_socket, "The total number of bytes in the environment and argument list is too large\n");
            break;
        case ENOMEM:
            send_message_string(cli_socket, "Lack of memory to execute program\n");
            break;
        case ENOEXEC:
            send_message_string(cli_socket, "Error in the format of the executable\n");
            break;
        case ENOENT:
            send_message_string(cli_socket, "File does not exist\n");
            break;
        case EACCES:
            send_message_string(cli_socket, "Execute permission for file is denied\n");
            break;
        case ENOTSUP:
            send_message_string(cli_socket, "Operation not supported\n");
            break;
        case EFAULT:
            send_message_string(cli_socket, "The filename points outside your addressable name space\n");
            break;
        case EINVAL:
            send_message_string(cli_socket, "The executable tried to name more than one interpreter\n");
            break;
        case EIO:
            send_message_string(cli_socket, "An I/O Error has occured\n");
            break;
        case EISDIR:
            send_message_string(cli_socket, "An ELF interpreter was a directory\n");
            break;
        case ELIBBAD:
            send_message_string(cli_socket, "An ELF interpreter was not in a recognized format\n");
            break;
        case ELOOP:
            send_message_string(cli_socket, "Too many symbolic links were encountered in resolving the executable\n");
            break;
        case EMFILE:
            send_message_string(cli_socket, "The process has the maximum number of files open\n");
            break;
        case ENAMETOOLONG:
            send_message_string(cli_socket, "The filename was too long\n");
            break;
        case ENOTDIR:
            send_message_string(cli_socket, "A component of the path prefix of the filename is not a directory\n");
            break;
        case EPERM:
            send_message_string(cli_socket, "The user is not the superuser/the filesystem is mounted nosuid\n");
            break;
    }
}
int processCmdListError(int rc, int cli_socket, command_list_t* clist) {
    int return_code;
    for (int i = 0; i < clist->num; i++) {
        if (clist->commands[i]->inputfileName != NULL || clist->commands[i]->outputfileName != NULL) {
            send_message_string(cli_socket, "File redirection not supported in server mode\n");
            return ERR_CMD_ARGS_BAD;
        }
    }

    switch (rc) {
        case ERR_MEMORY:
            send_message_string(cli_socket, "Error allocating memory\n");
            return_code = ERR_MEMORY;
            break;
        case ERR_CMD_OR_ARGS_TOO_BIG:
            send_message_string(cli_socket, "Total command length too long\n");
            return_code = ERR_CMD_OR_ARGS_TOO_BIG;
            break;
        case WARN_NO_CMDS:
            send_message_string(cli_socket, CMD_WARN_NO_CMD);
            return_code = WARN_NO_CMDS;
            break;
        case ERR_CMD_ARGS_BAD:
            send_message_string(cli_socket, "Syntax error in command\n");
            return_code = ERR_CMD_ARGS_BAD;
            break;
        default:
            return_code = OK;
            break;
    }
    return return_code;
}
/*
 * send_message_eof(cli_socket)
 *      cli_socket:  The server-side socket that is connected to the client

 *  Sends the EOF character to the client to indicate that the server is
 *  finished executing the command that it sent. 
 * 
 *  Returns:
 * 
 *      OK:  The EOF character was sent successfully. 
 * 
 *      ERR_RDSH_COMMUNICATION:  The send() socket call returned an error or if
 *           we were unable to send the EOF character. 
 */
int send_message_eof(int cli_socket){
    int bytes_sent;

    bytes_sent = send(cli_socket, &RDSH_EOF_CHAR, 1, 0);
    if (bytes_sent == 1) {
        return OK;
    }
    return ERR_RDSH_COMMUNICATION;
}

/*
 * send_message_string(cli_socket, char *buff)
 *      cli_socket:  The server-side socket that is connected to the client
 *      buff:        A C string (aka null terminated) of a message we want
 *                   to send to the client. 
 *   
 *  Sends a message to the client.  Note this command executes both a send()
 *  to send the message and a send_message_eof() to send the EOF character to
 *  the client to indicate command execution terminated. 
 * 
 *  Returns:
 * 
 *      OK:  The message in buff followed by the EOF character was 
 *           sent successfully. 
 * 
 *      ERR_RDSH_COMMUNICATION:  The send() socket call returned an error or if
 *           we were unable to send the message followed by the EOF character. 
 */
int send_message_string(int cli_socket, char *buff){
    int ret;
    int send_len = strlen(buff) + 1;
    int bytes_sent;
    bytes_sent = send(cli_socket, buff, send_len, 0);
    if (bytes_sent < 0) {
        return ERR_RDSH_COMMUNICATION;
    }
    ret = send_message_eof(cli_socket);
    return ret;
}


/*
 * rsh_execute_pipeline(int cli_sock, command_list_t *clist)
 *      cli_sock:    The server-side socket that is connected to the client
 *      clist:       The command_list_t structure that we implemented in
 *                   the last shell. 
 *   
 *  This function executes the command pipeline.  It should basically be a
 *  replica of the execute_pipeline() function from the last deliverable. 
 *  The only thing different is that you will be using the cli_sock as the
 *  main file descriptor on the first executable in the pipeline for STDIN,
 *  and the cli_sock for the file descriptor for STDOUT, and STDERR for the
 *  last executable in the pipeline.  See picture below:  
 * 
 *      
 *┌───────────┐                                                    ┌───────────┐
 *│ cli_sock  │                                                    │ cli_sock  │
 *└─────┬─────┘                                                    └────▲──▲───┘
 *      │   ┌──────────────┐     ┌──────────────┐     ┌──────────────┐  │  │    
 *      │   │   Process 1  │     │   Process 2  │     │   Process N  │  │  │    
 *      │   │              │     │              │     │              │  │  │    
 *      └───▶stdin   stdout├─┬──▶│stdin   stdout├─┬──▶│stdin   stdout├──┘  │    
 *          │              │ │   │              │ │   │              │     │    
 *          │        stderr├─┘   │        stderr├─┘   │        stderr├─────┘    
 *          └──────────────┘     └──────────────┘     └──────────────┘   
 *                                                      WEXITSTATUS()
 *                                                      of this last
 *                                                      process to get
 *                                                      the return code
 *                                                      for this function       
 * 
 *  Returns:
 * 
 *      EXIT_CODE:  This function returns the exit code of the last command
 *                  executed in the pipeline.  If only one command is executed
 *                  that value is returned.  Remember, use the WEXITSTATUS()
 *                  macro that we discussed during our fork/exec lecture to
 *                  get this value. 
 */
int rsh_execute_pipeline(int cli_sock, command_list_t *clist) {
    int result;
    //mode_t mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP;
    int pipes[clist->num - 1][2];  // Array of pipes
    pid_t pids[clist->num];        // Array to store process IDs

    // Create all necessary pipes
    for (int i = 0; i < clist->num - 1; i++) {
        if (pipe(pipes[i]) == -1) {
            perror("pipe");
            exit(EXIT_FAILURE);
        }
    }

    // Create processes for each command
    for (int i = 0; i < clist->num ; i++) {
        pids[i] = fork();
        if (pids[i] == -1) {
            perror("fork");
            exit(EXIT_FAILURE);
        }
        if (pids[i] == 0) {  // Child process
            // Set up input pipe for all except first process
            if (i == 0) {
                dup2(cli_sock, STDIN_FILENO);
            } else if (i > 0) {
                dup2(pipes[i-1][0], STDIN_FILENO);
            }

            // Set up output pipe for all except last process
            if (i < clist->num - 1) {
                dup2(pipes[i][1], STDOUT_FILENO);
            } else if (i == clist->num - 1) {
                dup2(cli_sock, STDOUT_FILENO);
                dup2(cli_sock, STDERR_FILENO);
            }

            // Close all pipe ends in child
            for (int j = 0; j < clist->num - 1; j++) {
                close(pipes[j][0]);
                close(pipes[j][1]);
            }

            Built_In_Cmds result = exec_built_in_cmd(clist->commands[i]);
            if (result == BI_CMD_EXIT) {
                exit(99);
            } else if (result == BI_CMD_STOP_SVR) {
                exit(105);
            } else if (result == BI_NOT_BI){
                execvp(clist->commands[i]->argv[0], clist->commands[i]->argv);
                exit(errno);
            } else if (result != BI_EXECUTED) {
                exit(ERR_EXEC_CMD);
            } else {
                exit(OK);
            }
            // Execute command
             /*
            execvp(clist->commands[i].argv[0], clist->commands[i].argv);
            perror("execvp");
            exit(EXIT_FAILURE);
            */
        }
    }

    // Parent process: close all pipe ends
    for (int i = 0; i < clist->num - 1; i++) {
        close(pipes[i][0]);
        close(pipes[i][1]);
    }

    // Wait for all children
    for (int i = 0; i < clist->num; i++) {
        waitpid(pids[i], &result, 0);
    }
    if (WEXITSTATUS(result) != 0) {
        printErrorServer(WEXITSTATUS(result), cli_sock);
    } else {
        send_message_eof(cli_sock);
    }
    return WEXITSTATUS(result);
}

/**************   OPTIONAL STUFF  ***************/
/****
 **** NOTE THAT THE FUNCTIONS BELOW ALIGN TO HOW WE CRAFTED THE SOLUTION
 **** TO SEE IF A COMMAND WAS BUILT IN OR NOT.  YOU CAN USE A DIFFERENT
 **** STRATEGY IF YOU WANT.  IF YOU CHOOSE TO DO SO PLEASE REMOVE THESE
 **** FUNCTIONS AND THE PROTOTYPES FROM rshlib.h
 **** 
 */

/*
 * rsh_match_command(const char *input)
 *      cli_socket:  The string command for a built-in command, e.g., dragon,
 *                   cd, exit-server
 *   
 *  This optional function accepts a command string as input and returns
 *  one of the enumerated values from the BuiltInCmds enum as output. For
 *  example:
 * 
 *      Input             Output
 *      exit              BI_CMD_EXIT
 *      dragon            BI_CMD_DRAGON
 * 
 *  This function is entirely optional to implement if you want to handle
 *  processing built-in commands differently in your implementation. 
 * 
 *  Returns:
 * 
 *      BI_CMD_*:   If the command is built-in returns one of the enumeration
 *                  options, for example "cd" returns BI_CMD_CD
 * 
 *      BI_NOT_BI:  If the command is not "built-in" the BI_NOT_BI value is
 *                  returned. 
 */
Built_In_Cmds rsh_match_command(const char *input)
{
    printf("%s\n", input);
    return BI_NOT_IMPLEMENTED;
}

/*
 * rsh_built_in_cmd(cmd_buff_t *cmd)
 *      cmd:  The cmd_buff_t of the command, remember, this is the 
 *            parsed version fo the command
 *   
 *  This optional function accepts a parsed cmd and then checks to see if
 *  the cmd is built in or not.  It calls rsh_match_command to see if the 
 *  cmd is built in or not.  Note that rsh_match_command returns BI_NOT_BI
 *  if the command is not built in. If the command is built in this function
 *  uses a switch statement to handle execution if appropriate.   
 * 
 *  Again, using this function is entirely optional if you are using a different
 *  strategy to handle built-in commands.  
 * 
 *  Returns:
 * 
 *      BI_NOT_BI:   Indicates that the cmd provided as input is not built
 *                   in so it should be sent to your fork/exec logic
 *      BI_EXECUTED: Indicates that this function handled the direct execution
 *                   of the command and there is nothing else to do, consider
 *                   it executed.  For example the cmd of "cd" gets the value of
 *                   BI_CMD_CD from rsh_match_command().  It then makes the libc
 *                   call to chdir(cmd->argv[1]); and finally returns BI_EXECUTED
 *      BI_CMD_*     Indicates that a built-in command was matched and the caller
 *                   is responsible for executing it.  For example if this function
 *                   returns BI_CMD_STOP_SVR the caller of this function is
 *                   responsible for stopping the server.  If BI_CMD_EXIT is returned
 *                   the caller is responsible for closing the client connection.
 * 
 *   AGAIN - THIS IS TOTALLY OPTIONAL IF YOU HAVE OR WANT TO HANDLE BUILT-IN
 *   COMMANDS DIFFERENTLY. 
 */
Built_In_Cmds rsh_built_in_cmd(cmd_buff_t *cmd, int return_code, int cli_socket)
{
    Built_In_Cmds rc = match_command(cmd->argv[0]);
    int retVal;
    switch (rc) {
        case BI_CMD_CD:
            retVal = changeDirectoryServer(cmd, cli_socket);
            if (retVal != 0){
                return BI_CMD_CD;
            }
            break;
        case BI_CMD_EXIT:
            return BI_CMD_EXIT;
            break;
        case BI_NOT_BI:
            return BI_NOT_BI;
            break;
        case BI_CMD_STOP_SVR:
            return BI_CMD_STOP_SVR;
            break;
        default:
            break;
    } 
    int f_result, c_result;
    f_result = fork();
    if (f_result < 0) {
        return errno;
    }
    if (f_result == 0) {
        dup2(cli_socket, STDOUT_FILENO);
        close(cli_socket);
        if (rc == BI_CMD_DRAGON) {
            print_dragon();
        } else if (rc == BI_RC){
            printf("%d\n", return_code);
        }
        exit(0);
    } else {
        wait(&c_result);
        send_message_eof(cli_socket);
        return BI_EXECUTED;
    }
    return BI_EXECUTED;
}
int changeDirectoryServer(cmd_buff_t* cmd, int cli_socket){
    if (cmd->argc == 1) { //No arguments
        return OK;
    } else if (cmd->argc == 2){
        if (chdir(cmd->argv[1]) != 0) {
            send_message_string(cli_socket, "Change Dir failed\n");
           return -1;
        } else {
            return 0;
        }
    } else {
        send_message_string(cli_socket, "cd(): Too many arguments\n");
        return -1;
    }
}
