#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <ctype.h>

#define BUFFER_SZ 50

//prototypes
void usage(char *);
void print_buff(char *, int);
int  setup_buff(char *, char *, int);

//prototypes for functions to handle required functionality
int  count_words(char *, int, int);
//add additional prototypes here
int reverse_string(char *, int, int);
void print_reversed_string(char*, int);
int word_print(char*, int, int);
int replace_string(char*, char*, char*, int, int, int);

int setup_buff(char *buff, char *user_str, int len){
    int string_length = 0;
    while(*user_str != '\0'){
        if (isspace(*user_str)) {
            *buff = ' ';
            buff++;
            while(isspace(*(user_str + 1))){
                user_str++;
            }
        }
        else{
            *buff = *user_str;
            buff++;
        }
        user_str++;
        string_length++;
        if(string_length > len){
            return -1;
        }
    } 
    for(int i = 0; i < (len - string_length); i++){
        *(buff + i) = '.';
    }
    //TODO: #4:  Implement the setup buff as per the directions
    return string_length; //for now just so the code compiles. 
}

void print_buff(char *buff, int len){
    printf("Buffer:  ");
    for (int i=0; i<len; i++){
        putchar(*(buff+i));
    }
    putchar('\n');
}

void usage(char *exename){
    printf("usage: %s [-h|c|r|w|x] \"string\" [other args]\n", exename);

}

int count_words(char *buff, int len, int str_len){
    if (str_len > len){
        return -1;
    }
    int count = 0;
    for(int i = 0; i < len; i++){
        if(isspace(*buff)){
            count++;
        }
        buff++;
    }
    count++;
    return count;
}

int reverse_string(char* buff, int len, int str_len){
    if (str_len > len){
        return -1;
    }
    int end_index = str_len - 1;
    int start_index = 0;
    char tmp_char;

    while(end_index > start_index){
        tmp_char = *(buff + end_index);
        *(buff + end_index) = *(buff + start_index);
        *(buff + start_index) = tmp_char;
        end_index--;
        start_index++;
    }
    return 0;
}
void print_reversed_string(char* buff, int str_len){
    printf("Reversed String:  ");
    for(int i = 0; i < str_len; i++){
        putchar(*(buff + i));
    }
    putchar('\n');
}

int word_print(char* buff, int len, int str_len){
    if(str_len > len){
        return -1;
    }
    int num_letters = 0;
    int word_num = 1;
    printf("Word Print\n----------\n");
    printf("%d. ", word_num);
    word_num++;
    for(int i = 0; i < str_len; i++){
        if(isspace(*(buff + i))){
            printf(" (%d)\n%d. ", num_letters, word_num);
            word_num++;
            num_letters = 0;
        } else{
            putchar(*(buff + i));
            num_letters++;
        }
    }
    printf(" (%d)\n", num_letters);
    return 0;
}

int replace_string(char* buff, char* tbrBuff, char* rBuff, int buff_sz, int tbrbuff_sz, int rbuff_sz){
    int curr_word_size = 0;
    bool prev_letter_valid = true;
    for(int i = 0; i < buff_sz; i++){
        if(isspace(*(buff + i)) && curr_word_size == tbrbuff_sz && prev_letter_valid){
            //Handle resizing
             if (buff_sz + (rbuff_sz - tbrbuff_sz) > BUFFER_SZ){
              printf("Error: Replaced String Overruns buffer");
              return -2;
            }
            int amount_to_be_moved = rbuff_sz - tbrbuff_sz; //If bigger, start at front and go forwards, smaller, do
                                                            //opposite, 
            printf("%d\n", buff_sz);
            char temp_ptr;
            if (amount_to_be_moved > 0){
                for (int j = 0; j <= (buff_sz - i); j++){
                    printf("%d\n", buff_sz - j + amount_to_be_moved);
                    temp_ptr = *(buff + buff_sz - j + amount_to_be_moved); 
                    *(buff + buff_sz - j + amount_to_be_moved) = *(buff + buff_sz - j);
                    *(buff + buff_sz - j) = temp_ptr;
                }
            } else { 
                for (int j = i; j < (buff_sz); j++) {
                    temp_ptr = *(buff + j + amount_to_be_moved);
                    *(buff + j + amount_to_be_moved) = *(buff + j);
                    *(buff + j) = temp_ptr;
                }
            }
            for (int k = 0; k < rbuff_sz; k++){
                *(buff + i + k - tbrbuff_sz) = *(rBuff + k);
            }
            curr_word_size = 0;
            prev_letter_valid = false;
            buff += amount_to_be_moved;
        } else if (*(buff + i) == *(tbrBuff + curr_word_size) && prev_letter_valid){
            curr_word_size++;
        } else if (isspace(*(buff + i)) && !prev_letter_valid){
            curr_word_size = 0;
            prev_letter_valid = true;
        } else {
            prev_letter_valid = false;
        }
    }
    //Add if to check if last word was valid
    return 0;
}

//ADD OTHER HELPER FUNCTIONS HERE FOR OTHER REQUIRED PROGRAM OPTIONS

int main(int argc, char *argv[]){

    char *input_string;     //holds the string provided by the user on cmd line
    char opt;               //used to capture user option from cmd line
    int  rc;                //used for return codes
    int  user_str_len;      //length of user supplied string

    //TODO:  #1. WHY IS THIS SAFE, aka what if arv[1] does not exist?
    // This is safe, as if argv[1] does no exist, it will exit and the program will not continue to run.
    if ((argc < 2) || (*argv[1] != '-')){
        usage(argv[0]);
        exit(1);
    }

    opt = (char)*(argv[1]+1);   //get the option flag

    //handle the help flag and then exit normally
    if (opt == 'h'){
        usage(argv[0]);
        exit(0);
    }

    //WE NOW WILL HANDLE THE REQUIRED OPERATIONS

    //TODO:  #2 Document the purpose of the if statement below
    //The if statement checks if the user submitted too many arguments, and exits if they did.
    if (argc < 3){
        usage(argv[0]);
        exit(1);
    }

    input_string = argv[2]; //capture the user input string

    //TODO:  #3 Allocate space for the buffer using malloc and
    //          handle error if malloc fails by exiting with a 
    //          return code of 99
    // CODE GOES HERE FOR #3
    char* buff = (char*) malloc(sizeof(char) * BUFFER_SZ); 

    if (buff == NULL) {
        printf("Memory not allocated correctly.\n");
        exit(99);
    }

    user_str_len = setup_buff(buff, input_string, BUFFER_SZ);     //see todos
    if (user_str_len < 0){
        printf("Error setting up buffer, error = %d", user_str_len);
        exit(2);
    }

    switch (opt){
        case 'c':
            rc = count_words(buff, BUFFER_SZ, user_str_len);  //you need to implement
            if (rc < 0){
                printf("Error counting words, rc = %d", rc);
                exit(2);
            }
            printf("Word Count: %d\n", rc);
            break;
        case 'r':
            rc = reverse_string(buff, BUFFER_SZ, user_str_len);
            if (rc < 0){
                printf("Error reversing string, rc = %d", rc);
                exit(2);
            }
            print_reversed_string(buff, user_str_len);
            break;
        case 'w':
            rc = word_print(buff, BUFFER_SZ, user_str_len);
            if (rc < 0){
                printf("Error finding wordcount, rc = %d", rc);
                exit(2);
            }
            break;
        case 'x':
            if (argc < 5){
                usage(argv[0]);
                exit(1);
            }
            char* to_be_replaced = argv[3];
            char* replacement_string = argv[4];

            char* tbrBuff = (char *)malloc(sizeof(char) * BUFFER_SZ);
            if (tbrBuff == NULL){
                printf("Memory not allocated correctly.\n");
                exit(99);
            }
            char* rBuff = (char *)malloc(sizeof(char) * BUFFER_SZ);
            if (rBuff == NULL){
                printf("Memory not allocated correctly.\n");
                exit(99);
            }
            int tbr_size = setup_buff(tbrBuff, to_be_replaced, BUFFER_SZ);
            int r_size = setup_buff(rBuff, replacement_string, BUFFER_SZ);
            print_buff(tbrBuff, BUFFER_SZ);
            print_buff(rBuff, BUFFER_SZ);
            
            rc = replace_string(buff, tbrBuff, rBuff, user_str_len, tbr_size, r_size);
            if (rc < 0){
                printf("Error replacing string, rc = %d", rc);
                exit(2);
            }
            break;
        //TODO:  #5 Implement the other cases for 'r' and 'w' by extending
        //       the case statement options
        default:
            usage(argv[0]);
            exit(1);
    }

    //TODO:  #6 Dont forget to free your buffer before exiting
    print_buff(buff,BUFFER_SZ);
    free(buff);
    exit(0);
}

//TODO:  #7  Notice all of the helper functions provided in the 
//          starter take both the buffer as well as the length.  Why
//          do you think providing both the pointer and the length
//          is a good practice, after all we know from main() that 
//          the buff variable will have exactly 50 bytes?
//  
//          PLACE YOUR ANSWER HERE
