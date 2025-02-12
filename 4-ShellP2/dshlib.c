#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
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

    if(cmd_buff == NULL){
        printf("Error allocating memory for command buffer\n");
        return 5;
    }
    while (1)
    {
        printf("%s", SH_PROMPT);
        if (fgets(cmd_buff, ARG_MAX, stdin) == NULL)
        {
            printf("\n");
            break;
        }
        // remove the trailing \n from cmd_buff
        cmd_buff[strcspn(cmd_buff, "\n")] = '\0';
        
        if (!cmd_buff[0]) {
            printf(CMD_WARN_NO_CMD);
            continue;
        }
        int pipeCount = countPipes(cmd_buff);

        if (pipeCount >= CMD_MAX) {
            printf(CMD_ERR_PIPE_LIMIT, CMD_MAX);
            continue;
        }
        rc = build_cmd_buff(cmd_buff,cmd);
        if (rc == 0) {
            if (exec_built_in_cmd(cmd) != BI_EXECUTED){
                int f_result, c_result;
                f_result = fork();
                 if (f_result < 0){
                    perror("fork error");
                    exit(1);
                }
                if (f_result == 0) {
                    rc = execvp(cmd->argv[0], cmd->argv);;
                    if (rc < 0) {
                        printf("AHHHHHH");
                        exit(36);
                    }
                }
        }
        }
    }

    // TODO IMPLEMENT MAIN LOOP

    // TODO IMPLEMENT parsing input to cmd_buff_t *cmd_buff

    // TODO IMPLEMENT if built-in command, execute builtin logic for exit, cd (extra credit: dragon)
    // the cd command should chdir to the provided directory; if no directory is provided, do nothing

    // TODO IMPLEMENT if not built-in command, fork/exec as an external command
    // for example, if the user input is "ls -l", you would fork/exec the command "ls" with the arg "-l"

    return OK;

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
        printf("Too many arguments\n");
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

    char* commandToken = (char *)malloc(sizeof(char) * (tokenLen + 1));

    strcpy(commandToken, cmd_line);

    int newLen = countWhitespace(commandToken, tokenLen, &frontOffset);
    
    char* token_cpy = malloc(sizeof(char) * (newLen + 1));

    removeWhitespace(token_cpy, commandToken, newLen, frontOffset);

    char* token_cpy_start = token_cpy;

    char* firstSpace = strchr(token_cpy, SPACE_CHAR);

    if (firstSpace == NULL) {

        if(newLen > EXE_MAX) {
                return ERR_CMD_OR_ARGS_TOO_BIG;
        }

        cmd_buff->argc = 1;
        cmd_buff->argv[0] = (char *)malloc(sizeof(char) * newLen);
        strcpy(cmd_buff->argv[0], token_cpy);
    } else {
        char* start = token_cpy;
        int exeLen = 0;
        while(!isspace(*token_cpy)){
            exeLen++;
            token_cpy++;
        }
        if (exeLen > EXE_MAX) {
            return ERR_CMD_OR_ARGS_TOO_BIG;
        }

        if ((newLen - exeLen - 1) > ARG_MAX){
            return ERR_CMD_OR_ARGS_TOO_BIG;
        }
        token_cpy = start;
        cmd_buff->argc = 1;
        cmd_buff->argv[0] = (char *)malloc(sizeof(char) * exeLen);
        strncpy(cmd_buff->argv[0], token_cpy, exeLen);
        cmd_buff->argv[0][exeLen] = '\0';
        token_cpy = firstSpace;
        token_cpy++;
        char arg[ARG_MAX];
        int argLen = 0;
        bool inQuotes = false;
        bool prevSpace = false;
        while(*token_cpy) {
            if ((isspace(*token_cpy) && !prevSpace && !inQuotes) || (*token_cpy == '\"' && inQuotes)) {
                cmd_buff->argc += 1;
                arg[argLen] = '\0';
                cmd_buff->argv[cmd_buff->argc - 1] = (char *)malloc(sizeof(char) * argLen + 1);
                strcpy(cmd_buff->argv[cmd_buff->argc - 1], arg);
                cmd_buff->argv[cmd_buff->argc - 1][argLen] = '\0';
                memset(arg, 0, ARG_MAX);
                inQuotes = false;
                argLen = 0;
                if (isspace(*(token_cpy + 1))){
                    token_cpy++;
                    prevSpace = true;
                }

            } else if (*token_cpy == '\"' && !inQuotes) {
                prevSpace = false;
                inQuotes = true;
            } else if (!isspace(*token_cpy) || inQuotes) {
                arg[argLen] = *token_cpy;
                argLen++;
                prevSpace = false;
            } else {
                prevSpace = true;
            }
            token_cpy++;
        }

        cmd_buff->argc += 1;
        arg[argLen] = '\0';
        cmd_buff->argv[cmd_buff->argc - 1] = (char *)malloc(sizeof(char) * argLen + 1);
        strcpy(cmd_buff->argv[cmd_buff->argc - 1], arg);
        cmd_buff->argv[cmd_buff->argc - 1][argLen] = '\0';
    }
    token_cpy = token_cpy_start;
    free(token_cpy);
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
               return BI_RC;
           }
           break;
        case BI_CMD_EXIT:
           exit(OK);
           break;
        case BI_CMD_DRAGON:
           print_dragon();
           break;
        case BI_NOT_BI:
           return BI_NOT_BI;
           break;
        default:
           break;
    }
    return BI_EXECUTED;
}

