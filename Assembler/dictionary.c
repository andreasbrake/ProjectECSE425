/*
 * dictionary.c
 *
 *  Created on: Feb 12, 2015
 *      Author: Andreas Brake
 */

#include <string.h>
#include <stdio.h>
#include <malloc.h>

#define LABEL_LEN 16

#define NUM_OF_R 4
#define NUM_OF_I 12
#define NUM_OF_J 2

typedef struct {
	char** label;
	int line;
} Label;

typedef struct {
    char* key;
    char* opcode;
    char* function;
} Opfun;

Label* labels;

Opfun opcodesR[NUM_OF_R];
Opfun opcodesI[NUM_OF_I];
Opfun opcodesJ[NUM_OF_J];

int lblnum = 0; // number of lables for add_label

int pairsR = 0; // counters for adding opcodes in add_key_val
int pairsI = 0; // ..
int pairsJ = 0; // ..

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

	printf("looking for %s", instruction);
	return -1;
}
int convert_to_binary(int linenum, char* numchar, int length, char** bin){
	int num = 0;
	int res = sscanf(numchar, "%d", &num);

	if(res == 0){
		int i;
		for(i=0; i < NUM_OF_R; i++){
			if(!strcmp((char*)&labels[i].label, numchar)){
				num = labels[i].line - linenum;
				if(num > 0)
					num--;
				break;
			}
		}
	}else{
		num = atoi(numchar);
	}

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

	*bin = tempbin;

	return 0;
}

int add_label(char** label, int lineNumber){
	Label newLabel;
	newLabel.label = (char**)*label;
	newLabel.line = lineNumber;

	labels = (Label*)realloc(labels, (lblnum+1) * sizeof(newLabel));
	labels[lblnum] = newLabel;

	lblnum ++;
	return 0;
}
int add_key_val(char* key, char* opcode, char* function, char* type){
	Opfun op;
	op.key = key;
	op.opcode = opcode;
	op.function = function;

	if(!strcmp(type, "R")){
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

int init_dictionary(){
	add_key_val("j",    "000010", "", "J");
	add_key_val("jal",  "000011", "", "J");

	add_key_val("beq",  "000100", "", "I");
	add_key_val("bne",  "000101", "", "I");
	add_key_val("blez", "000110", "", "I");
	add_key_val("bgtz", "000111", "", "I");

	add_key_val("addi", "001000", "", "I");
	add_key_val("addiu","001001", "", "I");
	add_key_val("slti", "001010", "", "I");
	add_key_val("sltiu","001011", "", "I");

	add_key_val("andi", "001100", "", "I");
	add_key_val("ori",  "001101", "", "I");
	add_key_val("xori", "001110", "", "I");
	add_key_val("lui",  "001111", "", "I");

	add_key_val("add",  "000000", "100000", "R");
	add_key_val("jr",   "000000", "001000", "R");
	add_key_val("mflo", "000000", "010010", "R");
	add_key_val("mult", "000000", "011000", "R");

	return 0;
}
