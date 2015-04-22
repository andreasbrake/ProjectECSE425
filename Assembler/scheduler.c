/*
 * sheduler.c
 *
 *  Created on: Apr 11, 2015
 *      Author: Andreas Brake
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define OUTPUT_FILE "Init_Sched.dat"

int mode = 0;
int lastProgLine = 0;
int currLine = 0;

// This structure will contain the data about a line in a program including the instruction,
//      the instruction type, and other instructions (as lineNums) it depends on 
typedef struct {
    char* inst;
    int type;
    int* deps1;
    int dep1Num;
    int* deps2;
    int dep2Num;
} ProgLine;

// A program is a collection of lines
// Instructions between lables and branches are considered separate programs for sheduling
typedef struct{
    ProgLine* lines;
    int lineCount;
} Program;

// All the 'programs'
Program* programs;
int numProgs;

ProgLine* program;

// Called by main.c as it parses the assembly file
// This adds a line the current program
int add_line(char* l, int t){
    ProgLine newLine;
    newLine.inst = l;
    newLine.type = t;
    newLine.dep1Num = 0;
    newLine.dep2Num = 0;

    program[currLine] = newLine;
    ++currLine;

    return 0;
}
// When ending a program, this function is called and the new program is formally
//     created and added to the Program list (programs)
int end_subprogram(){
    int newProgLines = currLine - lastProgLine;

    if(newProgLines == 0) return;

    Program* tmp = programs;
    programs = (Program*)malloc(sizeof(Program) * (numProgs + 1));
    int i;
    for(i=0; i<numProgs; i++){
        programs[i] = tmp[i];
    }    

    Program newProg;
    newProg.lines = (ProgLine*)malloc(sizeof(ProgLine) * newProgLines);
    newProg.lineCount = newProgLines;

    for(i=0; i<newProgLines; i++){
        newProg.lines[i] = program[lastProgLine + i];
    }
    
    printf("copied %d lines: %d to %d \n", newProgLines, lastProgLine, currLine-1);

    programs[numProgs] = newProg;
    lastProgLine = currLine;
    ++numProgs;
    free(tmp);
    return 0;
}
// Unitl function to determine if an instruction depends on another one at a specified linenumber
int depends_on(int lnum, int type, ProgLine line){
    int* deps;
    int depCnt;
    if(type == 0){
        deps = line.deps1;
        depCnt = line.dep1Num;        
    }else{
        deps = line.deps2;
        depCnt = line.dep2Num;        
    }
    int i;
    for(i=0; i<depCnt; i++){
        if(deps[i] == lnum){
            return 1;
        }
    }
    return 0;
}
// Compares registers to see if there is a dependency
int check_for_dep(char* reg1, char* reg2, int lineNum, ProgLine* line, int type){
    if(!strcmp(reg1, reg2) && strcmp(reg1, "00000")){
        printf("%s dep on line %d of type %d ", reg1, lineNum, type);
        int* tmp;
        int depNum;  
        if(type == 0){
            tmp = line->deps1;
            depNum = line->dep1Num;         
        } else{
            tmp = line->deps2;
            depNum = line->dep2Num;         
        }

        // Add new dep to list
        int* newDeps = (int*)malloc(sizeof(int) * (depNum + 1));
        int i;
        for(i = 0; i<depNum; i++){
            newDeps[i] = tmp[i];
        }
        newDeps[depNum] = lineNum;
        
        if(type == 0){
            line->dep1Num = depNum + 1;
            line->deps1 = newDeps;        
        } else{
            line->dep2Num = depNum + 1;
            line->deps2 = newDeps;        
        }
    }
}
// Parses all previous instructins and gets relevant registers to checks for dependencies (via check_for_dep)
int find_line_dep(int lineNum, char* reg, ProgLine* line, Program* p){
    // Loop through each previous line of the program and find dependencies
    
    int fromLine = lineNum - 1;
    if(fromLine < 0) return;

    int i;
    for(i = (lineNum-1); i >= 0; i--){
        ProgLine l = (p->lines)[i];
        int instType = l.type;
        char* inst = l.inst;

        if(instType == 0){ // R-type
            char rs[6];
            char rt[6];
            char rd[6];
            memcpy(rs, &inst[6], 5);
            memcpy(rt, &inst[11], 5);
            memcpy(rd, &inst[16], 5);
            rs[5] = '\0';
            rt[5] = '\0';
            rd[5] = '\0';

            check_for_dep(rs, reg, i, line, 1);
            check_for_dep(rt, reg, i, line, 1);
            check_for_dep(rd, reg, i, line, 0);
        }
        else if(instType == 1){ // I-type
            char rs[6];
            char rt[6];
            memcpy(rs, &inst[6], 5);
            memcpy(rt, &inst[11], 5);
            rs[5] = '\0';
            rt[5] = '\0';

            check_for_dep(rs, reg, i, line, 1);
            check_for_dep(rt, reg, i, line, 0);
        }
    }

    return 0;
}
// Loops through all lines in the program and calls find_line_dep on each to compare toe releavant registers
int find_all_deps(Program* p){
    ProgLine* currProg = p->lines;
    int currProgLineCount = p->lineCount;

    // Loop through each line of the program and find dependencies
    int i;
    for(i = (currProgLineCount-1); i >= 0; i--){
        ProgLine line = currProg[i];
        int instType = line.type;
        char* inst = line.inst;

        printf("\nchecking line %d ", i);

        if(instType == 0){ // R-type
            // Check rs and rt
            char rs[6];
            char rt[6];

            memcpy(rs, &inst[6], 5);
            memcpy(rt, &inst[11], 5);

            rs[5] = '\0';
            rt[5] = '\0';

            find_line_dep(i, rs, &line, p);
            find_line_dep(i, rt, &line, p);
        }
        else if(instType == 1){ // I-type
            // Check rs
            char rs[6];
            memcpy(rs, &inst[6], 5);
            rs[5] = '\0';

            find_line_dep(i, rs, &line, p);

            // And rt if the instruction is bne or beq
            char op[7];
            memcpy(op, &inst[0], 6);
            op[6] = '\0';
            if(!strcmp(op, "000100") || !strcmp(op, "000101")){ // bne or beq
                char rt[6];
                memcpy(rt, &inst[11], 5);
                rt[5] = '\0';

                find_line_dep(i, rt, &line, p);
            }
        }
        (p->lines)[i] = line;
    }
}
// Performs the actual rescheduling of the program
int reschedule_subprog(Program p, Program* newP){
    ProgLine* currProg = p.lines;
    ProgLine* schedProg = newP->lines;

    int currProgLineCount = p.lineCount; // Number of lines in the program

    // Adds endpoints
    schedProg[0] = currProg[0];
    if(currProgLineCount > 1){
        schedProg[currProgLineCount-1] = currProg[currProgLineCount-1];
    }

    if(currProgLineCount <= 2) return; // Too short. Nothing to schedule!

    // Loop through each line of the program and swap upwards if desired
    int i;
    int changed = 0;
 
    // Loops through all instrucitons (minus endpoints)
    for(i = 1; i <= currProgLineCount-2; i++){
        ProgLine line = currProg[i];
        ProgLine next = currProg[i+1];
        // If the previous instruction causes a stall and the next function will not
        if(depends_on(i-1, 0, line) && !depends_on(i, 1, next) && !depends_on(i, 0, next)){
            // If the instruciton after next will not cause and error then switch
            if((i+2) < currProgLineCount && !depends_on(i, 0, currProg[i+2])){
                schedProg[i] = currProg[i+1];
                schedProg[i+1] = currProg[i];
                printf("switching lines %d with %d\n", i, i+1);
                changed = 1;
                i++;
            }else if((i+2) >= currProgLineCount){
                schedProg[i] = currProg[i+1];
                schedProg[i+1] = currProg[i];
                printf("switching lines %d with %d\n", i, i+1);
                changed = 1;
                i++;
            }else{ // Dont switch
                schedProg[i] = currProg[i];
            }
            
        }else{ // Dont switch
            schedProg[i] = currProg[i];
        }
    }
    newP->lines = schedProg;
    newP->lineCount = currProgLineCount;
}
// Main function for this section
// Calls other functions and writes outputs to a file
int schedule_output(){
    char ch;
    FILE *writeFile;

    writeFile = fopen(OUTPUT_FILE, "w");

    if(writeFile == NULL){
        perror("Error while opening the write file.\n");
        exit(EXIT_FAILURE);
    }
    
    int i;
    for(i=0; i<numProgs; i++){
        // Generate program dependencies
        Program p = programs[i];
        printf("\nfinding subprogram deps %d", i);
        find_all_deps(&p);
        printf("\nscheduling subprogram %d", i);

        // Reschedules program
        Program np;
        np.lines = (ProgLine*)malloc(sizeof(ProgLine) * p.lineCount);
        np.lineCount = p.lineCount;
        reschedule_subprog(p, &np);
        printf("new prog lines %d\n", np.lineCount);
        int j;
        for(j=0; j<np.lineCount; j++){
            char* line = (np.lines[j]).inst;
            fprintf(writeFile,"%s\n", line); // Write to the write file
        }
    }

    // Close files
    fclose(writeFile);

    return 0;
}
// Init program length
int init_scheduler(int plen){
    program = (ProgLine*)malloc(sizeof(ProgLine) * plen);

    return 0;
}