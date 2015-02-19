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

typedef struct rword{
	char opcode[6];
	char rs[5];
	char rt[5];
	char rd[5];
	char shamt[5];
	char funct[6];
} RWord;

char* EMPTY_WORD = "00000000000000000000000000000000";

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
			convert_to_binary(inst, 5, &word);
			add_to_word(word);

			readingWord = 0;
			inst[0] = '\0';
			continue;
		}
		else if(input[i] == ' '){ // End of opcode or just whitespace
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
					inst[0] = '\0';
				}
				readingWord = 0;
			}
			continue;
		}
		else if(input[i] == '$'){
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
			convert_to_binary(inst, 5, &thing);
		}else if(wordType == 1){
			convert_to_binary(inst, 16, &thing);
		}else if(wordType == 2){
			convert_to_binary(inst, 26, &thing);
		}else{
			printf("ERROR!");
		}
		if(strcmp(thing, ""))
			add_to_word(thing);
	}

	return 0;
}

int parse_file(char* filename, int mode){
    char ch;
    FILE *fp;

    fp = fopen(filename,"r");
    if( fp == NULL ){
        perror("Error while opening the file.\n");
        exit(EXIT_FAILURE);
    }

    char line[256] = "";
    while( ( ch = fgetc(fp) ) != EOF ){
    	if(ch == '\n'){
    		// Parse line / convert
			parse_line(line);
			if(strcmp(lineWord, EMPTY_WORD))
				printf("%s\n", lineWord);

			line[0] = '\0'; // Empty array
		}
    	else{
    		// Append ch to the line
			int len = strlen(line);
			line[len] = ch;
			line[len+1] = '\0';
    	}
    }

    fclose(fp);

    return 0;
}
int main(int argc, char* argv[]){
	init_dictionary();
	parse_file(argv[1], 0);

    return 0;
}
