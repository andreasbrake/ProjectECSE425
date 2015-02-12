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

char* parse_line(char input[]){
	char* output = "";

	int readingWord = 0;
	int instructionRead = 0;
	int registerRead = 0;
	int i;

	char inst[32];
	inst[0] = '\0';

	for(i=0; i<strlen(input); i++){
		if(input[i] == '#') // Line is over if comment begins
			break;
		else if(input[i] == ':'){ // line flag
			output = append(output, inst);
			output = append(output, " ");
			readingWord = 0;
			inst[0] = '\0';
			continue;
		}
		else if(input[i] == ','){ // End of register or value
			char out[] = "000000";
			if(registerRead){
				int regnum = atoi(inst);
				out[5] = (regnum & 1) + '0';
				regnum >>= 1;
				out[4] = (regnum & 1) + '0';
				regnum >>= 1;
				out[3] = (regnum & 1) + '0';
				regnum >>= 1;
				out[2] = (regnum & 1) + '0';
				regnum >>= 1;
				out[1] = (regnum & 1) + '0';
				regnum >>= 1;
				out[0] = regnum + '0';

				registerRead = 0;
			}

			output = append(output, out);
			readingWord = 0;
			inst[0] = '\0';
			continue;
		}
		else if(input[i] == ' '){ // End of opcode or just whitespace
			if(readingWord){
				if(!instructionRead){
					instructionRead = 1;
					char* word = convert_instruction(inst);
					output = append(output, word);
				}else{
					output = append(output, " ");
					output = append(output, inst);
					output = append(output, " ");
				}

				readingWord = 0;

				inst[0] = '\0';
			}
			continue;
		}
		else if(input[i] == '$'){
			registerRead = 1;
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

	}

	printf("%s\n", output);

	return output;
}

int main(int argc, char* argv[]){
	init_dictionary();

    char ch;
    FILE *fp;

    fp = fopen(argv[1],"r");
    if( fp == NULL ){
        perror("Error while opening the file.\n");
        exit(EXIT_FAILURE);
    }

    char line[256] = "";
    while( ( ch = fgetc(fp) ) != EOF ){
    	if(ch == '\n'){
    		// Parse line / convert
			char* output = parse_line(line);
			//printf("%s \n", output);
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
