#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#define BUFFER_SZ 50

//prototypes
void usage(char *);
void print_buff(char *, int);
int  setup_buff(char *, char *, int);

//prototypes for functions to handle required functionality
int  count_words(char *, int, int);
//add additional prototypes hereA
void print_string(char*, int);
int reverse_string(char *, int, int);
void print_reversed_string(char*, int);
int word_print(char*, int, int);
int replace_string(char*, char*, char*, int, int, int, int);
int size_check(int, int, int, int);
void dot_pad(char*, int, int);
void print_modified_string(char*, int);
int isspace(int c);

int isspace(int c){
    return ((c == ' ') || (c =='\n') || (c == '\t'));
}

int setup_buff(char *buff, char *user_str, int len){
    int string_length = 0;
    bool leading_whitespace = true;
    while(*user_str != '\0'){
        if (isspace(*user_str) && leading_whitespace){
            while(isspace(*(user_str + 1))) {
                user_str++;
            }
        } else if (isspace(*user_str)) {
            while(isspace(*(user_str + 1))){ //Skips over extra spaces
                user_str++;
            }
            if (*(user_str + 1) == '\0') {
                string_length--;
                break;
            }else{
            *buff = ' ';
            buff++;
            }
        }
        else{
            *buff = *user_str;
            buff++;
        }
        user_str++;
        string_length++;
        if((string_length > len) && (!isspace(*(buff + string_length + 1)))){
            return -1;
        }
        leading_whitespace = false;
    } 
    for(int i = 0; i < (len - string_length); i++){ //Pads buffer
        *(buff + i) = '.';
    }
    //TODO: #4:  Implement the setup buff as per the directions
    return string_length; //for now just so the code compiles. 
}

void print_buff(char *buff, int len){
    printf("Buffer:  ");
    print_string(buff, len);
}

void print_string(char* buff, int len){
    for (int i = 0; i < len; i++){
        putchar(*(buff + i));
    }
    putchar('\n');
}
void usage(char *exename){
    printf("usage: %s [-h|c|r|w|x] \"string\" [other args]\n", exename);

}

int count_words(char *buff, int len, int str_len){ //Counts words in buffer
    if (str_len > len){
        return -1;
    }
    if (str_len == 0) {
        return 0;
    }
    int count = 0;
    for(int i = 0; i < str_len; i++){
        if(isspace(*buff)){
            count++;
        }
        buff++;
    }
    count++;
    return count;
}

int reverse_string(char* buff, int len, int str_len){ //Reverses String in place
    if (str_len > len){
        return -1;
    }
    if (str_len == 0){
        return 0;
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
    print_string(buff, str_len);
}

int word_print(char* buff, int len, int str_len){ //Pretty prints word and num chars in word
    if(str_len > len){
        return -1;
    }
    if (str_len == 0) {
        printf("No Words to print\n");
        return 0;
    }
    int num_letters = 0;
    int word_num = 1;
    printf("Word Print\n----------\n");
    printf("%d. ", word_num);
    word_num++;
    for(int i = 0; i < str_len; i++){ //Main loop
        if(isspace(*(buff + i))){
            printf(" (%d)\n%d. ", num_letters, word_num);
            word_num++;
            num_letters = 0;
        } else{
            putchar(*(buff + i));
            num_letters++;
        }
    }
    printf(" (%d)\n", num_letters); //Prints number of letters in last word
    printf("\nNumber of words returned: %d\n", word_num - 1);
    return 0;
}

int replace_string(char* buff, char* tbrBuff, char* rBuff, int buff_sz, int tbrbuff_sz, int rbuff_sz, int max_size){
    if(buff_sz == 0){
        printf("No words to replace\n");
        return 0;
    }
    int curr_word_size = 0;
    bool prev_letter_valid = true;
    int rc;
    int current_letter = 0;
    while( (*(buff + current_letter) != '.') && (current_letter < max_size)) {
        if(isspace(*(buff + current_letter)) && curr_word_size == tbrbuff_sz && prev_letter_valid){ //If we have reached
                                                                                                    //the end of a word
                                                                                                    //to be replaced
            rc = size_check(buff_sz, tbrbuff_sz, rbuff_sz, max_size);
            if (rc < 0){
                return -2;
            }
            int amount_to_be_moved = rbuff_sz - tbrbuff_sz; //If new word bigger, start at front and go forwards, smaller, do
                                                            //opposite to prevent overwriting values that need to be
                                                            //moved 
            if (amount_to_be_moved > 0){
                for (int j = 0; j <= (buff_sz - current_letter); j++){ //Start at front and go back
                    *(buff + buff_sz - j + amount_to_be_moved) = *(buff + buff_sz - j);
                }
            } else { 
                for (int j = current_letter; j < (buff_sz); j++) { //Start at back and go forwards
                    *(buff + j + amount_to_be_moved) = *(buff + j);
                }
                dot_pad(buff, buff_sz, -(amount_to_be_moved));
            }
            for (int k = 0; k < rbuff_sz; k++){ //Put in new word
                *(buff + current_letter + k - tbrbuff_sz) = *(rBuff + k);
            }
            curr_word_size = 0;
            prev_letter_valid = false;
            buff_sz += amount_to_be_moved;
            current_letter += amount_to_be_moved;
        } else if (*(buff + current_letter) == *(tbrBuff + curr_word_size) && prev_letter_valid){ //If we are not at the
                                                                                                  //end of a word and
                                                                                                  //all previous letters
                                                                                                  //have been valid
            curr_word_size++;
        } else if (isspace(*(buff + current_letter)) && !prev_letter_valid){ //If we reach the end of an invalid word
            curr_word_size = 0;
            prev_letter_valid = true;
        } else {
            prev_letter_valid = false;
        }
        current_letter++;
    }
    if(curr_word_size == tbrbuff_sz && prev_letter_valid){ //Checks if last word was valid
        rc = size_check(buff_sz, tbrbuff_sz, rbuff_sz, max_size);
        if (rc < 0){
            return -2;
        }
        for(int k = 0; k < rbuff_sz; k++){
            *(buff + buff_sz - tbrbuff_sz + k) = *(rBuff + k);
        }
        if ((rbuff_sz - tbrbuff_sz) < 0) {
            dot_pad(buff, buff_sz, -(rbuff_sz - tbrbuff_sz));
        }
        buff_sz += rbuff_sz - tbrbuff_sz;
    }
    print_modified_string(buff, buff_sz); 
    return 0;
}

void dot_pad(char* buff, int buff_sz, int pad_amount){ //Pad periods
    for (int i = 0; i <= pad_amount; i++){
       *(buff + buff_sz - pad_amount + i) = '.';
    }
}
int size_check(int max_sz, int size_initial, int size_new, int buffer_sz){ //Checks if replacement string overruns
                                                                           //buffer
        if (max_sz + (size_new - size_initial) > buffer_sz){
        printf("Error: Replacement String Overruns buffer\n");
        return -2;
    } else {
    return 0;
    }
}

void print_modified_string(char* buff, int str_len){
    printf("Modified String:  ");
    print_string(buff, str_len);
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
        printf("Error setting up buffer, error = %d\n", user_str_len);
        exit(2);
    }

    switch (opt){
        case 'c':
            rc = count_words(buff, BUFFER_SZ, user_str_len);  //you need to implement
            if (rc < 0){
                printf("Error counting words, rc = %d\n", rc);
                exit(2);
            }
            printf("Word Count: %d\n", rc);
            break;
        case 'r':
            rc = reverse_string(buff, BUFFER_SZ, user_str_len);
            if (rc < 0){
                printf("Error reversing string, rc = %d\n", rc);
                exit(2);
            }
            print_reversed_string(buff, user_str_len);
            break;
        case 'w':
            rc = word_print(buff, BUFFER_SZ, user_str_len);
            if (rc < 0){
                printf("Error finding wordcount, rc = %d\n", rc);
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

            char* tbrBuff = (char *)malloc(sizeof(char) * BUFFER_SZ); //Buffer of word to be replaced
            if (tbrBuff == NULL){
                printf("Memory not allocated correctly.\n");
                exit(99);
            }
            char* rBuff = (char *)malloc(sizeof(char) * BUFFER_SZ); //Buffer of replacement word
            if (rBuff == NULL){
                printf("Memory not allocated correctly.\n");
                exit(99);
            }
            int tbr_size = setup_buff(tbrBuff, to_be_replaced, BUFFER_SZ);
            int r_size = setup_buff(rBuff, replacement_string, BUFFER_SZ);
            
            rc = replace_string(buff, tbrBuff, rBuff, user_str_len, tbr_size, r_size, BUFFER_SZ);
            if (rc < 0){
                printf("Error replacing string, rc = %d\n", rc);
                exit(2);
            }
            free(tbrBuff);
            free(rBuff);
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
//          It is good practice as we could change the length of the buffer, and so hard-coding fifty would result in
//          errors. It also helps ensure that we are always working with the correct size of the buffer, ensuring that
//          we don't try to access memory that isn't ours.
