/*
 * main.c
 *
 *  Created on: Feb 12, 2015
 *      Author: Andreas Brake
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dictionary.h"

#define EMPTY_WORD "00000000000000000000000000000000"

int lineNumber = 0;

char* lineWord;
int pos = 0;
int wordType = 0;

char* append(char* str1, char* str2){
    char* temp = "";
    if((temp = malloc(strlen(str1)+strlen(str2)+1)) != NULL){
        temp[0] = '\0';
        strcat(temp,str1);
        strcat(temp,str2);
    } else{
        printf("ERROR APPENDING STRING");
    }
    return temp;
}

int add_to_word(char* bin){
    int len;
    int i;
    int offset = 0;

    if(pos == 0){ // opcode (will always be the first thing added independent of instruction type)
        len = 6;
        offset = 0;
    }else{
        if(wordType == 0){ // R instruction
            if(pos == 1){ // funct
                len = 6;
                offset = 26;
            }else if(pos == 2){ // rd
                len = 5;
                offset = 16;
            }else if(pos == 3){ // rs
                len = 5;
                offset = 6;
            }else if(pos == 4){ // rt
                len = 5;
                offset = 11;
            }
        }else if(wordType == 1){ // I instruction
            if(pos == 1){ // rt
                len = 5;
                offset = 11;
            }else if(pos == 2){ // rs
                len = 5;
                offset = 6;
            }else if(pos == 3){ // immediate
                len = 16;
                offset = 16;
            }
        }else if(wordType == 2){ // J instruction
            if(pos == 1){ // address
                len = 26;
                offset = 6;
            }
        }
    }

    for(i=0; i<len; i++){
        lineWord[(offset+i)] = bin[i];
    }

    pos++;
    return 0;
}

int parse_line(char input[]){
    lineWord = (char*)malloc(32);
    int i;
    for(i=0; i<32; i++){
        lineWord[i] = '0';
    }
    lineWord[32] = '\0';
    wordType = 0;
    pos = 0;

    int instructionRead = 0;
    int readingWord = 0;
    int parenParse = 0;

    char inst[32];
    inst[0] = '\0';

    for(i=0; i<strlen(input); i++){
        if(input[i] == '#') // Line is over if comment begins
            break;
        else if(input[i] == ':'){ // line flag
            readingWord = 0;
            inst[0] = '\0';
            continue;
        }
        else if(input[i] == ','){ // End of register or value
            char* word = malloc(5);
            convert_to_binary(lineNumber, inst, 5, &word);
            add_to_word(word);

            readingWord = 0;
            inst[0] = '\0';
            continue;
        }
        else if(input[i] == ' ' || input[i] == '\t'){ // End of opcode or just whitespace
            if(readingWord){
                if(!instructionRead){
                    char* opcode = "";
                    char* function = "";

                    wordType = convert_instruction(inst, &opcode, &function);
                    add_to_word(opcode);
                    if(wordType == 0){
                        add_to_word(function);
                    }

                    instructionRead = 1;
                    lineNumber++;

                    inst[0] = '\0';
                }
                readingWord = 0;
            }
            continue;
        }
        else if(input[i] == '(' || input[i] == ')'){
        	parenParse = 1;
        	continue;
        }
        else if(input[i] == '$'){
        	if(parenParse){
        		int len = strlen(inst);
				inst[len] = input[i];
				inst[len+1] = '\0';
        	}
            continue;
        }
        else{
            int len = strlen(inst);
            inst[len] = input[i];
            inst[len+1] = '\0';
            readingWord = 1;
        }
    }
    if(inst[0] != '\0'){
        char* thing = ""; // either rt, immediate, or address depending on instruction type
        if(wordType == 0){
            convert_to_binary(lineNumber, inst, 5, &thing);
        }else if(wordType == 1){
        	if(parenParse){ // parsing something in the form cc($reg)
        		char* rs = "";
        		char* rsbin = "";
        		char* immed = "";

        		paren_parse(inst, strlen(inst), &rs, &immed);

        		convert_to_binary(lineNumber, rs, 5, &rsbin);
        		convert_to_binary(lineNumber, immed, 16, &thing);

        		add_to_word(rsbin);
        	}
        	else
        		convert_to_binary(lineNumber, inst, 16, &thing);
        }else if(wordType == 2){
            convert_to_binary(lineNumber, inst, 26, &thing);
        }else{
            printf("ERROR!");
        }
        if(strcmp(thing, ""))
            add_to_word(thing);
    }

    return 0;
}
int parse_line_labels(char input[]){
    int i;

    char label[32];
    label[0] = '\0';

    for(i=0; i<strlen(input); i++){
        if(input[i] == '#') // Line is over if comment begins
            break;
        else if(input[i] == ':'){ // line label
            add_label(&label[0], lineNumber);
            label[0] = '\0';

        }
        else if(input[i] != ' ' && input[i] != '\t'){
            int len = strlen(label);
            label[len] = input[i];
            label[len+1] = '\0';
        }
    }

    if(label[0] != '\0'){
        lineNumber++;
    }
    return 0;
}

int parse_file(char* filename, int mode){
    char ch;
    FILE *readFile;
    FILE *writeFile;

    readFile = fopen(filename,"r");
    writeFile = fopen("output.bin", "w");

    if( readFile == NULL || writeFile == NULL){
        perror("Error while opening the file.\n");
        exit(EXIT_FAILURE);
    }

    char line[256] = "";
    while( ( ch = fgetc(readFile) ) != EOF ){
        if(ch == '\n'){
            // Parse line / label

            if(mode == 0){
                parse_line_labels(line);
                line[0] = '\0'; // Empty array
            }
            else{
                parse_line(line);
                if(strcmp(lineWord, EMPTY_WORD)){
                    printf("%s\n", lineWord);
                    fprintf(writeFile,"%s\n", lineWord);
                }

                line[0] = '\0'; // Empty array
            }
        }
        else{
            // Append ch to the line
            int len = strlen(line);
            line[len] = ch;
            line[len+1] = '\0';
        }
    }

    fclose(writeFile);
    fclose(readFile);

    lineNumber = -1;
    return 0;
}

int main(int argc, char* argv[]){

    parse_file(argv[1], 0); // parse for labels
    init_dictionary();
    parse_file(argv[1], 1); // parse for everything else

    return 0;
}
