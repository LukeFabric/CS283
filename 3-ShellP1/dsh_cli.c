#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dshlib.h"

/*
 * Implement your main function by building a loop that prompts the
 * user for input.  Use the SH_PROMPT constant from dshlib.h and then
 * use fgets to accept user input.  Since we want fgets to also handle
 * end of file so we can run this headless for testing we need to check
 * the return code of fgets.  I have provided an example below of how
 * to do this assuming you are storing user input inside of the cmd_buff
 * variable.
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
 *
 *   Expected output:
 *
 *      CMD_OK_HEADER      if the command parses properly. You will
 *                         follow this by the command details
 *
 *      CMD_WARN_NO_CMD    if the user entered a blank command
 *      CMD_ERR_PIPE_LIMIT if the user entered too many commands using
 *                         the pipe feature, e.g., cmd1 | cmd2 | ... |
 *
 *  See the provided test cases for output expectations.
 */
int main()
{
    char *cmd_buff = malloc(SH_CMD_MAX * sizeof(char));

    if(cmd_buff == NULL){
        printf("Error allocating memory for command buffer\n");
        return -1;
    }
    command_list_t clist;

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

        if (build_cmd_list(cmd_buff, &clist) == OK){
            if (clist.num == 1){
                command_t command = clist.commands[0];

                if (strcmp(command.exe, EXIT_CMD) == 0){
                    free(cmd_buff);
                    exit(OK);
                }

                if (strcmp(command.exe, DRAGON_CMD) == 0){
                    //int n_lines = sizeof(DRAGON_ASCII_CMP) / sizeof(DRAGON_ASCII_CMP[0]);
                    //print_dragon_cmp(DRAGON_ASCII_CMP, n_lines);
                    printf("nothing\n");
                    continue;
                }
            }
            printCmdList(clist);
    }
    
    }
    free(cmd_buff);
    printf("Skibidi\n");
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

void printCmdList(command_list_t clist){
    printf(CMD_OK_HEADER, clist.num);

    for (int i = 0; i < clist.num; i++){

        command_t currentCmd = clist.commands[i];

        printf("<%d> %s", (i + 1), currentCmd.exe);
        if(currentCmd.args[0] != '\0'){
            printf(" [%s]", currentCmd.args);
        }

        printf("\n");
    }
}
