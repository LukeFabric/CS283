#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "dshlib.h"

/*
 *  build_cmd_list
 *    cmd_line:     the command line from the user
 *    clist *:      pointer to clist structure to be populated
 *
 *  This function builds the command_list_t structure passed by the caller
 *  It does this by first splitting the cmd_line into commands by spltting
 *  the string based on any pipe characters '|'.  It then traverses each
 *  command.  For each command (a substring of cmd_line), it then parses
 *  that command by taking the first token as the executable name, and
 *  then the remaining tokens as the arguments.
 *
 *  NOTE your implementation should be able to handle properly removing
 *  leading and trailing spaces!
 *
 *  errors returned:
 *
 *    OK:                      No Error
 *    ERR_TOO_MANY_COMMANDS:   There is a limit of CMD_MAX (see dshlib.h)
 *                             commands.
 *    ERR_CMD_OR_ARGS_TOO_BIG: One of the commands provided by the user
 *                             was larger than allowed, either the
 *                             executable name, or the arg string.
 *
 *  Standard Library Functions You Might Want To Consider Using
 *      memset(), strcmp(), strcpy(), strtok(), strlen(), strchr()
 */
int build_cmd_list(char *cmd_line, command_list_t *clist)
{
    clist->num = 0;
    char* commandToken;

    //int numCommands = 0;

    commandToken = strtok(cmd_line, PIPE_STRING);

    int frontOffset;

    while(commandToken != NULL){

        frontOffset = 0;

        int tokenLen = strlen(commandToken);

        int newLen = countWhitespace(commandToken, tokenLen, &frontOffset);

        char* token_cpy = malloc(sizeof(char) * (newLen + 1));

        if (token_cpy == NULL){
            return -1;
        }

        removeWhitespace(token_cpy, commandToken, newLen, frontOffset);

        char* token_cpy_start = token_cpy;
        
        command_t* newCmd = (command_t*)malloc(sizeof(command_t));

        if (newCmd == NULL) {
            return -1;
        }

        char* firstSpace = strchr(token_cpy, SPACE_CHAR);

        if (firstSpace == NULL){

            if(newLen > EXE_MAX) {
                return ERR_CMD_OR_ARGS_TOO_BIG;
            }
            
            strcpy(newCmd->exe, token_cpy);
            newCmd->exe[newLen + 1] = '\0';
            memset(newCmd->args, 0, ARG_MAX);
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
            strncpy(newCmd->exe, token_cpy, exeLen);
            newCmd->exe[exeLen] = '\0';
            token_cpy = firstSpace + 1;
            strcpy(newCmd->args, token_cpy);
            newCmd->args[newLen] = '\0';
        }
        clist->commands[clist->num] = *newCmd;
        clist->num++;
        commandToken = strtok(NULL, PIPE_STRING);
        token_cpy = token_cpy_start;
        free(token_cpy);
        free(newCmd);
    }

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
