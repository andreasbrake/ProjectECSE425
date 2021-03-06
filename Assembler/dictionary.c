/*
 * dictionary.c
 *
 *  Created on: Feb 12, 2015
 *      Author: Andreas Brake
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

// Number of opcodes being added to the dictionary of each type
#define NUM_OF_R 37
#define NUM_OF_I 36
#define NUM_OF_J 2

// Label structure consisting of the label name pointer line number
typedef struct {
    char* label;
    int line;
} Label;

// Opcode/Function to binary conversion structure
typedef struct {
    char* key;
    char* opcode;
    char* function;
} Opfun;

// Poiner relating to the list of labels and their line numbers
Label* labels;

// Opcode/Function conversions of each different type
Opfun opcodesR[NUM_OF_R];
Opfun opcodesI[NUM_OF_I];
Opfun opcodesJ[NUM_OF_J];

int lblnum = 0; // number of lables for add_label

int pairsR = 0; // counters for adding opcodes in add_key_val
int pairsI = 0; // ..
int pairsJ = 0; // ..

// Converts opcode or function to its binary equivalent
// Returns the type of instruction
// R type: 0
// I type: 1
// J type: 2
int convert_instruction(char* instruction, char** opcode, char** function){
    int i;
    for(i=0; i < NUM_OF_R; i++){
        if(!strcmp(opcodesR[i].key, instruction)){
            *opcode = opcodesR[i].opcode;
            *function = opcodesR[i].function;
            return 0;
        }
    }
    for(i=0; i < NUM_OF_I; i++){
        if(!strcmp(opcodesI[i].key, instruction)){
            *opcode = opcodesI[i].opcode;
            return 1;
        }
    }
    for(i=0; i < NUM_OF_J; i++){
        if(!strcmp(opcodesJ[i].key, instruction)){
            *opcode = opcodesJ[i].opcode;
            return 2;
        }
    }

    printf("can't find instruction %s", instruction);
    return -1;
}

// Convert value to binary
int convert_to_binary(int linenum, char* numchar, int length, char** bin){
    int num = 0;
    int res = sscanf(numchar, "%d", &num); // Check if value is numeric

    if(res == 0){   // If it's not numeric, then it's a label
        int i;
        // Loop over all the labels recorded
        for(i=0; i < lblnum; i++){
            if(!strcmp((char*)labels[i].label, numchar)){
                // Get the line difference between current line and label location
                num = labels[i].line - linenum - 1; 
                //printf("branching from line %d to %d (jump by %d)\n", linenum, labels[i].line, num);
                break;
            }
        }
        if(i >= lblnum){    // Label hasn't been recorded (typo by user perhaps)
            printf("ERROR!! Label %s not found\n", numchar);
            return 0;            
        }
    }else{          // If it's numeric, then convert it to a number
        num = atoi(numchar);
    }

    // Convert integer to a binary number
    char binNum[length];
    binNum[0] = '\0';

    int i;
    for(i=(length-1); i>=0; i--){
        binNum[i] = (num & 1) + '0';
        num >>= 1;
    }

    binNum[length] = '\0';

    char* tempbin;
    tempbin = (char*)malloc(length);
    tempbin[0] = '\0';
    strcpy(tempbin, binNum);

    // Set and return
    *bin = tempbin;

    return 0;
}

// Parse out registers and immediate from parenthesized instruction
int paren_parse(char* input, int len, char** reg, char** constant){
	int i;
	int isreg = 0;

    // Initialize
	char* regT = (char*)malloc(sizeof(char));
	char* conT = (char*)malloc(sizeof(char));
	int ri = 0;
	int ci = 0;

    // Loop throught instruction
	for(i=0; i<len; i++){
		char c = input[i];
		if(c == '$'){
			isreg = 1;
        }
		else if(isreg){   // Add to register
			regT = (char*)realloc(regT, (ri+1) * sizeof(char));
			regT[ri] = c;
			ri++;
		}
		else{             // Add to immediate
			conT = (char*)realloc(conT, (ci+1) * sizeof(char));
			conT[ci] = c;
			ci++;
		}
	}

    // Return values
	*reg = (char*)malloc(ri * sizeof(char));
	*reg = regT;

	*constant = (char*)malloc(ci * sizeof(char));
	*constant = conT;

    //    free(regT);
    //    free(conT);

	return 0;
}

// Add a label and line numbmer to the list of labels
int add_label(char* label, int lineNumber){
    Label newLabel;
    newLabel.label = (char*)label;
    newLabel.line = lineNumber;

    labels = (Label*)realloc(labels, (lblnum+1) * sizeof(newLabel));
    labels[lblnum] = newLabel;

    //printf("adding #%d, %s at %d\n", lblnum, labels[lblnum].label, lineNumber);

    lblnum ++;
    return 0;
}

// Add opcode and binary conversion to the list
int add_key_val(char* key, char* opcode, char* type){
    Opfun op;
    op.key = key;
    op.opcode = opcode;
    op.function = "";

    if(!strcmp(type, "R1")){
        op.function = opcode;
        op.opcode = "000000";
        opcodesR[pairsR] = op;
        pairsR++;
    }
    if(!strcmp(type, "R2")){
        op.function = opcode;
        op.opcode = "010001";
        opcodesR[pairsR] = op;
        pairsR++;
    }
    else if(!strcmp(type, "I")){
        opcodesI[pairsI] = op;
        pairsI++;
    }
    else if(!strcmp(type, "J")){
        opcodesJ[pairsJ] = op;
        pairsJ++;
    }

    return 0;
}

// Initilize R type opcodes
// R1 are with a function and opcode 000000
int init_R1_codes(){
    add_key_val("sll",  "000000", "R1");
    add_key_val("srl",  "000010", "R1");
    add_key_val("sra",  "000011", "R1");

    add_key_val("sllv", "000100", "R1");
    add_key_val("srlv", "000110", "R1");
    add_key_val("srav", "000111", "R1");

    add_key_val("jr",   "001000", "R1");
    add_key_val("jalr", "001001", "R1");
    add_key_val("movz", "001010", "R1");
    add_key_val("movn", "001011", "R1");

    add_key_val("syscall", "001100", "R1");
    add_key_val("break",   "001101", "R1");
    add_key_val("sync",    "001111", "R1");

    add_key_val("mfhi", "010000", "R1");
    add_key_val("mthi", "010001", "R1");
    add_key_val("mflo", "010010", "R1");
    add_key_val("mtlo", "010011", "R1");

    add_key_val("mult", "011000", "R1");
    add_key_val("multu","011001", "R1");
    add_key_val("div",  "011010", "R1");
    add_key_val("divu", "011011", "R1");

    add_key_val("add",  "100000", "R1");
    add_key_val("addu", "100001", "R1");
    add_key_val("sub",  "100010", "R1");
    add_key_val("subu", "100011", "R1");

    add_key_val("and",  "100100", "R1");
    add_key_val("or",   "100101", "R1");
    add_key_val("xor",  "100110", "R1");
    add_key_val("nor",  "100111", "R1");

    add_key_val("slt",  "101010", "R1");
    add_key_val("sltu", "101011", "R1");

    add_key_val("tge",  "110000", "R1");
    add_key_val("tgeu", "110001", "R1");
    add_key_val("tlt",  "110010", "R1");
    add_key_val("tltu", "110011", "R1");

    add_key_val("teq",  "110100", "R1");
    add_key_val("tne",  "110110", "R1");

    return 0;
}

// Initilize I type opcodes
int init_I_codes(){ 
    add_key_val("beq",  "000100", "I");
    add_key_val("bne",  "000101", "I");
    add_key_val("blez", "000110", "I");
    add_key_val("bgtz", "000111", "I");

    add_key_val("addi", "001000", "I");
    add_key_val("addiu","001001", "I");
    add_key_val("slti", "001010", "I");
    add_key_val("sltiu","001011", "I");

    add_key_val("andi", "001100", "I");
    add_key_val("ori",  "001101", "I");
    add_key_val("xori", "001110", "I");
    add_key_val("lui",  "001111", "I");

    add_key_val("lb",   "100000", "I");
    add_key_val("lh",   "100001", "I");
    add_key_val("lwl",  "100010", "I");
    add_key_val("lw",   "100011", "I");

    add_key_val("lbu",  "100100", "I");
    add_key_val("lhu",  "100101", "I");
    add_key_val("lwr",  "100110", "I");

    add_key_val("sb",   "101000", "I");
    add_key_val("sh",   "101001", "I");
    add_key_val("swl",  "101010", "I");
    add_key_val("sw",   "101011", "I");

    add_key_val("swr",  "101110", "I");
    add_key_val("cache","101111", "I");

    add_key_val("ll",   "110000", "I");
    add_key_val("lwc1", "110001", "I");
    add_key_val("lwc2", "110010", "I");
    add_key_val("pref", "110011", "I");

    add_key_val("ldc1", "110101", "I");
    add_key_val("ldc2", "110110", "I");

    add_key_val("sc",   "111000", "I");
    add_key_val("swc1", "111001", "I");
    add_key_val("swc2", "111010", "I");

    add_key_val("sdc1", "111101", "I");
    add_key_val("sdc2", "111110", "I");

    return 0;
}
// Initilize J type opcodes
int init_J_codes(){ 
    add_key_val("j",    "000010", "J");
    add_key_val("jal",  "000011", "J");

    return 0;
}

// Initialize all the opcodes
int init_dictionary(){

    init_R1_codes();
    init_I_codes();
    init_J_codes();

    return 0;
}
