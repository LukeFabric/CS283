#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <errno.h>
#include "dshlib.h"

/*
 * Implement your exec_local_cmd_loop function by building a loop that prompts the 
 * user for input.  Use the SH_PROMPT constant from dshlib.h and then
 * use fgets to accept user input.
 * 
 *      while(1){
 *        printf("%s", SH_PROMPT);
 *        if (fgets(cmd_buff, ARG_MAX, stdin) == NULL){
 *           printf("\n");
 *           break;
 *        }
 *        //remove the trailing \n from cmd_buff
 *        cmd_buff[strcspn(cmd_buff,"\n")] = '\0';
 * 
 *        //IMPLEMENT THE REST OF THE REQUIREMENTS
 *      }
 * 
 *   Also, use the constants in the dshlib.h in this code.  
 *      SH_CMD_MAX              maximum buffer size for user input
 *      EXIT_CMD                constant that terminates the dsh program
 *      SH_PROMPT               the shell prompt
 *      OK                      the command was parsed properly
 *      WARN_NO_CMDS            the user command was empty
 *      ERR_TOO_MANY_COMMANDS   too many pipes used
 *      ERR_MEMORY              dynamic memory management failure
 * 
 *   errors returned
 *      OK                     No error
 *      ERR_MEMORY             Dynamic memory management failure
 *      WARN_NO_CMDS           No commands parsed
 *      ERR_TOO_MANY_COMMANDS  too many pipes used
 *   
 *   console messages
 *      CMD_WARN_NO_CMD        print on WARN_NO_CMDS
 *      CMD_ERR_PIPE_LIMIT     print on ERR_TOO_MANY_COMMANDS
 *      CMD_ERR_EXECUTE        print on execution failure of external command
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 1+)
 *      malloc(), free(), strlen(), fgets(), strcspn(), printf()
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 2+)
 *      fork(), execvp(), exit(), chdir()
 */
int exec_local_cmd_loop()
{
    char *cmd_buff = (char *)malloc(SH_CMD_MAX * sizeof(char));
    int rc = 0;
    cmd_buff_t* cmd = (cmd_buff_t*)malloc(sizeof(cmd_buff_t));
    int return_code = 0;

    if(cmd_buff == NULL){
        printf("Error allocating memory for command buffer\n");
        return ERR_MEMORY;
    }
    if(cmd == NULL){
        printf("Error allocating memory for cmd struct\n");
        return ERR_MEMORY;
    }
    while (1)
    {
        printf("%s", SH_PROMPT);
        if (fgets(cmd_buff, SH_CMD_MAX, stdin) == NULL)
        {
            printf("\n");
            break;
        }
        // remove the trailing \n from cmd_buff
        cmd_buff[strcspn(cmd_buff, "\n")] = '\0';
        
        if (!cmd_buff[0]) {
            printf(CMD_WARN_NO_CMD);
            return_code = WARN_NO_CMDS;
            continue;
        }
        int pipeCount = countPipes(cmd_buff);

        if (pipeCount >= CMD_MAX) {
            printf(CMD_ERR_PIPE_LIMIT, CMD_MAX);
            return_code = ERR_TOO_MANY_COMMANDS;
            continue;
        }
        rc = build_cmd_buff(cmd_buff,cmd);
        if (rc == OK) {
            Built_In_Cmds result = exec_built_in_cmd(cmd);
            if (result == BI_CMD_EXIT) {
                break;
            } else if (result == BI_NOT_BI){
                rc = execCmd(cmd);
                printError(rc);
                if (rc != 0) {
                    return_code = ERR_EXEC_CMD;
                } else {
                    return_code = OK;
                }
            } else if (result == BI_EXECUTED) {
                return_code = OK;
            } else if (result == BI_RC) {
                printf("%d\n", return_code);
                return_code = OK;
            } else {
                return_code = ERR_EXEC_CMD;
            }
        } else if (rc == ERR_MEMORY) {
            perror("Error Allocating memory");
            return_code = ERR_MEMORY;
            continue;
        } else if (rc == ERR_CMD_OR_ARGS_TOO_BIG) {
            printf("Total command length too long\n");
            return_code = ERR_CMD_OR_ARGS_TOO_BIG;
            continue;
        } else if (rc == WARN_NO_CMDS) {
            printf(CMD_WARN_NO_CMD);
            return_code = WARN_NO_CMDS;
            continue;
        }
    free(cmd->_cmd_buffer);
    memset(cmd, 0, CMD_ARGV_MAX);
    cmd->argc = 0;
    //TODO free everything
    }
    free(cmd_buff);
    //free(cmd->_cmd_buffer);
    free(cmd);
    return OK;
}
void printError(int error) {
    switch (error) {
        case E2BIG:
            printf("The total number of bytes in the environment and argument list is too large\n");
            break;
        case ENOMEM:
            printf("Lack of memory to execute program\n");
            break;
        case ENOEXEC:
            printf("Error in the format of the executable\n");
            break;
        case ENOENT:
            printf("File does not exist\n");
            break;
        case EACCES:
            printf("Execute permission for file is denied\n");
            break;
        case ENOTSUP:
            printf("Operation not supported\n");
            break;
        case EFAULT:
            printf("The filename points outside your addressable name space\n");
            break;
        case EINVAL:
            printf("The executable tried to name more than one interpreter\n");
            break;
        case EIO:
            printf("An I/O Error has occured\n");
            break;
        case EISDIR:
            printf("An ELF interpreter was a directory\n");
            break;
        case ELIBBAD:
            printf("An ELF interpreter was not in a recognized format\n");
            break;
        case ELOOP:
            printf("Too many symbolic links were encountered in resolving the executable\n");
            break;
        case EMFILE:
            printf("The process has the maximum number of files open\n");
            break;
        case ENAMETOOLONG:
            printf("The filename was too long\n");
            break;
        case ENOTDIR:
            printf("A component of the path prefix of the filename is not a directory\n");
            break;
        case EPERM:
            printf("The user is not the superuser/the filesystem is mounted nosuid\n");
            break;
    }
}
int execCmd(cmd_buff_t *cmd){
    int f_result, c_result;
    f_result = fork();
    if (f_result < 0){
        return errno;
    }
    if (f_result == 0) {
        int rc = execvp(cmd->argv[0], cmd->argv);
        if (rc < 0) {
            exit(errno);
        }
    } else {
        wait(&c_result);
        return WEXITSTATUS(c_result);
    }
    return 0;
}
int changeDirectory(cmd_buff_t* cmd){
    if (cmd->argc == 1) { //No arguments
        return OK;
    } else if (cmd->argc == 2){
        if (chdir(cmd->argv[1]) != 0) {
           perror("chdir failed\n");
           return -1;
        } else {
            return 0;
        }
    } else {
        printf("cd(): Too many arguments\n");
        return -1;
    }
}
int countPipes(char* cmd_buff){
    int pipeCount = 0;
    char* cmdBuffPipe = (char *)malloc(SH_CMD_MAX * sizeof(char));

    strcpy(cmdBuffPipe, cmd_buff);
    
    char* start = cmdBuffPipe;
    while(*cmdBuffPipe){
        if(*cmdBuffPipe == PIPE_CHAR){
            pipeCount++;
        }
        cmdBuffPipe++;
    }
    cmdBuffPipe = start;
    free(cmdBuffPipe);
    return pipeCount;
}
int build_cmd_buff(char* cmd_line, cmd_buff_t* cmd_buff){
    int frontOffset = 0;
    int tokenLen = strlen(cmd_line);
    char* commandToken = strdup(cmd_line);
    if (commandToken == NULL){
        perror("Memory Allocation failed");
        return ERR_MEMORY;
    }
    int newLen = countWhitespace(commandToken, tokenLen, &frontOffset);
    if (newLen < 0){
        return WARN_NO_CMDS;
    }
    char* token_cpy = malloc(sizeof(char) * (newLen + 1));
    if (token_cpy == NULL){
        perror("Memory Allocation failed");
        return ERR_MEMORY;
    }
    removeWhitespace(token_cpy, commandToken, newLen, frontOffset);
    char* token_cpy_start = token_cpy;
    cmd_buff->_cmd_buffer = strdup(token_cpy);
    if (cmd_buff->_cmd_buffer == NULL){
        perror("Memory Allocation failed");
        return ERR_MEMORY;
    }
    char* firstSpace = strchr(token_cpy, SPACE_CHAR);
    if (firstSpace == NULL) {

        if(newLen > EXE_MAX) {
                return ERR_CMD_OR_ARGS_TOO_BIG;
        }

        cmd_buff->argc = 1;
        cmd_buff->argv[0] = cmd_buff->_cmd_buffer;
    } else {
        int exeLen = 0;
        while(!isspace(*token_cpy)) {
            exeLen++;
            token_cpy++;
        }
        if (exeLen > EXE_MAX) {
            return ERR_CMD_OR_ARGS_TOO_BIG;
        }

        if ((newLen - exeLen - 1) > ARG_MAX){
            return ERR_CMD_OR_ARGS_TOO_BIG;
        }
        
        bool inQuotes = false;
        bool prevSpace = false;
        char* nextWord;
        cmd_buff->argc = 1;
        cmd_buff->argv[0] = cmd_buff->_cmd_buffer;
        for (int i = 0; i < (newLen + 1); i++) {
            if ((isspace(cmd_buff->_cmd_buffer[i]) && !inQuotes && !prevSpace)) {
                cmd_buff->_cmd_buffer[i] = '\0';
                prevSpace = true;
            } else if (cmd_buff->_cmd_buffer[i] == '\"' && inQuotes) {
                cmd_buff->_cmd_buffer[i] = '\0';
                inQuotes = false;
                i += 1;
                prevSpace = true;
            }  else if (!isspace(cmd_buff->_cmd_buffer[i]) && prevSpace){
                cmd_buff->argc += 1;
                if (cmd_buff->argc >= 10) {
                    printf("Too many arguments\n");
                    return ERR_CMD_OR_ARGS_TOO_BIG;
                }
                if (cmd_buff->_cmd_buffer[i] == '\"'){
                    nextWord = cmd_buff->_cmd_buffer + (i + 1);
                    cmd_buff->argv[cmd_buff->argc - 1] = nextWord;
                    inQuotes = true;
                } else {
                    nextWord = cmd_buff->_cmd_buffer + i;
                    cmd_buff->argv[cmd_buff->argc - 1] = nextWord;
                }
                prevSpace = false;
            } else {
                continue;
                }
            }
        }
    token_cpy = token_cpy_start;
    cmd_buff->argv[cmd_buff->argc] = NULL; //Needed for execvp
    free(token_cpy);
    free(commandToken);
    return OK;
}
void removeWhitespace(char* destination, char* toBeStripped, int sourceLen, int frontOffset) {
    toBeStripped = toBeStripped + frontOffset;
    char* start = destination;
    for(int i = 0; i < (sourceLen); i++){
        *destination = *toBeStripped;
        toBeStripped++;
        destination++;
    }

    destination = start;
    destination[sourceLen] = '\0';
}

int countWhitespace(char* token, int tokenLen, int* frontOffset){

    char* tbsCopy = (char *)malloc(sizeof(char) * (tokenLen + 1));

    strcpy(tbsCopy, token);
    
    char* start = tbsCopy;
    while(isspace(*tbsCopy)){
        tbsCopy++;
        *frontOffset += 1;
    }

    tbsCopy = start + tokenLen - 1;
    
    int backOffset = 0;
    while(isspace(*tbsCopy)) {
        backOffset++;
        tbsCopy--;
    }

    tbsCopy = start;
    free(tbsCopy);
    return tokenLen - *frontOffset - backOffset;
}
Built_In_Cmds match_command(const char *input) {
    if (strcmp(input, "cd") == 0){
        return BI_CMD_CD;
    } else if (strcmp(input, "exit") == 0) {
        return BI_CMD_EXIT;
    } else if (strcmp(input, "dragon") == 0) {
        return BI_CMD_DRAGON;
    } else if (strcmp(input, "rc") == 0){
        return BI_RC;
    } else {
        return BI_NOT_BI;
    }
}
Built_In_Cmds exec_built_in_cmd(cmd_buff_t *cmd) {
    Built_In_Cmds rc = match_command(cmd->argv[0]);
    int retVal;
    switch (rc) {
        case BI_CMD_CD:
           retVal = changeDirectory(cmd);
           if (retVal != 0){
               return BI_CMD_CD;
           }
           break;
        case BI_CMD_EXIT:
           return BI_CMD_EXIT;
           break;
        case BI_CMD_DRAGON:
           print_dragon();
           break;
        case BI_NOT_BI:
           return BI_NOT_BI;
           break;
        case BI_RC:
            return BI_RC;
            break;
        default:
           break;
    }
    return BI_EXECUTED;
}

