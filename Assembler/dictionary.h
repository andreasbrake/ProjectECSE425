/*
 * dictionary.h
 *
 *  Created on: Feb 12, 2015
 *      Author: Andreas Brake
 */

#ifndef DICTIONARY_H_
#define DICTIONARY_H_

int init_dictionary();
int convert_instruction(char* instruction, char** opcode, char** function);
int convert_to_binary(char* numchar, int length, char** bin);

#endif /* DICTIONARY_H_ */
