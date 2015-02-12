/*
 * dictionary.c
 *
 *  Created on: Feb 12, 2015
 *      Author: Andreas Brake
 */

#include <string.h>

#define NUM_OF_INSTRUCTIONS 7
typedef struct key_val {
    char* key;
    char* val;
} Keyval;

Keyval instructions[NUM_OF_INSTRUCTIONS];
int pairs = 0;

char* convert_instruction(char* instruction){
	int i;
	for(i=0; i < NUM_OF_INSTRUCTIONS; i++){
		char* key = instructions[i].key;
		if(!strcmp(key, instruction)){
			return instructions[i].val;
		}
	}
	return "DNE";
}
char* convert_register(char* reg){
	reg++;
	int regnum = atoi(reg);

	char bits[] = "000000";

	bits[5] = (regnum & 1) + '0';
	regnum >>= 1;
	bits[4] = (regnum & 1) + '0';
	regnum >>= 1;
	bits[3] = (regnum & 1) + '0';
	regnum >>= 1;
	bits[2] = (regnum & 1) + '0';
	regnum >>= 1;
	bits[1] = (regnum & 1) + '0';
	regnum >>= 1;
	bits[0] = regnum + '0';

	return bits;
}

int add_key_val(char* key, char* value){
	Keyval kv;
	kv.key = key;
	kv.val = value;
	instructions[pairs] = kv;
	pairs++;
	return 0;
}


int init_dictionary(){
	add_key_val("addi", "001000");
	add_key_val("mult", "001000");
	add_key_val("slti", "001010");
	add_key_val("bne",  "000101");
	add_key_val("mflo", "010010");
	add_key_val("j",    "000010");
	add_key_val("jr",   "000011");

	return 0;
}
