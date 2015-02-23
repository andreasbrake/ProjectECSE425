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

// Add a binary instruction to the current binary line word
// Certain order for each part being read
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

// The main parsing function of the program
// This takes the input[] as an array of the line characters
int parse_line(char input[]){
    lineWord = (char*)malloc(32); // Allocate memory for the binary line

    // Initialize the binary line
    int i;
    for(i=0; i<32; i++){
        lineWord[i] = '0';
    }
    lineWord[32] = '\0';

    // Initialize values
    wordType = 0;
    pos = 0;

    int instructionRead = 0;
    int readingWord = 0;
    int parenParse = 0;

    char inst[32];
    inst[0] = '\0';

    // Iterate over all the characters in the line
    for(i=0; i<strlen(input); i++){
        if(input[i] == '#'){                 // Line is over if comment begins
            break;
        }
        else if(input[i] == ':'){           // line label (don't read here)
            readingWord = 0;
            inst[0] = '\0';
            continue;
        }
        else if(input[i] == ','){           // End of register or value
            char* word = malloc(5);         // allocate memory for the register/immediate/etc
            convert_to_binary(lineNumber, inst, 5, &word);  // Convert it to binary
            add_to_word(word);              // Add it to the binary line

            // Reset recording
            readingWord = 0;
            inst[0] = '\0';
            continue;
        }
        else if(input[i] == ' ' || input[i] == '\t'){       // End of opcode or just whitespace
            if(readingWord){                // If there is a word being read
                if(!instructionRead){       // If the opcode has not yet been read, then this is it
                    char* opcode = "";
                    char* function = "";

                    // Get the binary version of the opcode
                    wordType = convert_instruction(inst, &opcode, &function);
                    add_to_word(opcode);    // Add the opcode to the binary word
                    if(wordType == 0){      // If the word is an R type word
                        add_to_word(function);              // Add the function to the binary word
                    }

                    // Set/Reset values and increment the line number
                    instructionRead = 1;
                    lineNumber++;
                    inst[0] = '\0';
                }
                readingWord = 0;
            }
            continue;
        }
        else if(input[i] == '(' || input[i] == ')'){        // Set parenParse flag if a parenthesis is read
        	parenParse = 1;
        	continue;
        }
        else if(input[i] == '$'){           // If a register is being read then only add it if a parenParse is set 
        	if(parenParse){
        		int len = strlen(inst);
				inst[len] = input[i];
				inst[len+1] = '\0';
        	}
            continue;
        }
        else{                               // Add the current character to the current thing being read and set readingWord flag
            int len = strlen(inst);
            inst[len] = input[i];
            inst[len+1] = '\0';
            readingWord = 1;
        }
    }

    // Parse anything remaining once the line has been read (final part of word)
    if(inst[0] != '\0'){
        char* thing = "";                   // either rt, immediate, or address depending on instruction type
        if(wordType == 0){
            convert_to_binary(lineNumber, inst, 5, &thing);
        }else if(wordType == 1){            // I type instruction
        	if(parenParse){                 // parsing something in the form cc($reg)
        		char* rs = "";
        		char* rsbin = "";
        		char* immed = "";

        		paren_parse(inst, strlen(inst), &rs, &immed); // Parse out register and immediate

                // Add them to the binary line word
        		convert_to_binary(lineNumber, rs, 5, &rsbin);
        		convert_to_binary(lineNumber, immed, 16, &thing);

        		add_to_word(rsbin);
        	}
        	else{                           // Any other Immediate to be read (can be normally converted)
        		convert_to_binary(lineNumber, inst, 16, &thing);
            }
        }else if(wordType == 2){            // R type instruction
            convert_to_binary(lineNumber, inst, 26, &thing);
        }else{
            printf("ERROR!");
        }
        if(strcmp(thing, ""))               // Add immediate/rs to word
            add_to_word(thing);
    }

    return 0;
}

// This function parses the line for label information
// input[] is the line data
int parse_line_labels(char input[]){
    int i;

    //char label[32];
    char* label = malloc(32 * sizeof(char));
    label[0] = '\0';

    // Iterate over each character in the line
    for(i=0; i<strlen(input); i++){
        if(input[i] == '#') // Line is over if comment begins
            break;
        else if(input[i] == ':'){ // line label has been read
            add_label(label, lineNumber); // Record the label and its location
            break;
        }
        else if(input[i] != ' ' && input[i] != '\t'){ // Don't record spaces or tabs
            int len = strlen(label);
            label[len] = input[i];
            label[len+1] = '\0';
        }
    }

    // Iterate the line number if something exists on the line
    if(label[0] != '\0'){
        lineNumber++;
    }

    return 0;
}

// Parse_file takes in the name of the file to be parsed and the parsing mode
// Mode: 0 indicates that the program is looking for and recording labels
// Mode: 1 indicates that the program is parsing the general content of the lines
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

    // Assumes that each line is no longer than 256 characters
    char line[256] = "";

    // Loop through each line of the file and write the content to line
    while( ( ch = fgetc(readFile) ) != EOF ){
        if(ch == '\n'){ // If the line ends with a new line or a comment
            if(mode == 0){
                parse_line_labels(line); // Parse line for label information
            }
            else{
                parse_line(line); // Parse line for general content
                if(strcmp(lineWord, EMPTY_WORD)){ // If the line is empty then don't write it
                    printf("%s\n", lineWord); // For debugging
                    fprintf(writeFile,"%s\n", lineWord); // Write to the write file
                }
            }

            line[0] = '\0'; // Clear the line array
        }
        else{
            // Append ch to the line array
            int len = strlen(line);
            line[len] = ch;
            line[len+1] = '\0';
        }
    }

    // If the final line does not end with a comment then this will handle the final line
    if(line[0] != '\n'){  
        if(mode == 0){
            parse_line_labels(line);
        }
        else{
            parse_line(line);
            if(strcmp(lineWord, EMPTY_WORD)){
                printf("%s\n", lineWord);
                fprintf(writeFile,"%s\n", lineWord);
            }
        }
        line[0] = '\0';
    }

    // Close files
    fclose(writeFile);
    fclose(readFile);

    lineNumber = -1; // Reset line number
    return 0;
}

int main(int argc, char* argv[]){

    parse_file(argv[1], 0); // parse for labels
    init_dictionary();      // Initialize the dictionary of opcodes
    parse_file(argv[1], 1); // parse for everything else

    return 0;
}
