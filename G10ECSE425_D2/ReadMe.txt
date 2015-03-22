-------Main File Restarted---------

In the first deliverable, the team had opted to put the whole project together in a BDF schematic file from Quartus, but this turned out to be problematic due to the simulator. The fact that Quartus needs to Synthesize the VHDL code such that it can be run on hardware made the code basically uncompilable within a reasonable amount of time. Therefore, the whole Main file from the deliverable one needed to be re-written, and the team abandoned the initiative to use Quartus as the simulation software. This step took a very significant amount of time due to the fact that many of the blocks were lpm modules from Quartus, which needed to be re-coded to match the new code. The Main was tested after the re-code for the first and second deliverable and seems to be working at an appreciable level. 

-------Pipelining--------

To make our processor pipelined, registers were needed between the various stages of instructions. These registers are used to pass on control
signals as well as feed into the hazard detection unit to allow the processor to handle various situations. Instead of actually implementing physical register
blocks, we used signal lines and passed them through the various processor components. WB, MEM, and EX are determined through the control unit, and 
the status of the current instruction is fed into the register as the instruction passes through the pipeline. If a hazard is detected, a stall is set 
in place in the pipeline, determied by the control unit and hazard detection units.

-------Hazard Detection--------

For the Hazard Detection unit, the idea was to add it as a component of the Instruction Decode block. The unit presently takes care of data hazards such as Read After Write and Read After Read. Basically, the way it operates is that it checks the registers presently in the pipeline to make sure that they are not used by previous instructions in the code. If they are, a Stall is issued until the registers are freed. 

--------Forwarding--------

In order to implement forwarding in piplining, a forwarding unit was added to the processor in the Execute stage. The forwarding unit
logic was determined depending on the EX/MEM and MEM/WB reg_write signal passed through the registers. These signals are used to determine which stage
to forward the data back from to the ALU in the execute stage. This means that the pipelined data from the current instruction is also fed into the
forwarding unit which determines whether to forward the output of the ALU or not. If forwarding is necessary, as determined through the hazard detection unit, 
the corresponding output from the ALU is fed back and multiplexed, with the forwarding unit sending control signals to determine the data from which output
stage is needed in the current instruction. The forwarding unit also takes in the RS, RD, and RT values of the current and previous instructions and uses
these values to check whether or not there is a hazard between the same registers: specifically RS from the ID/EX stage, RD from EX/MEM, RD from MEM/WB and 
RT from MEM/WB.

-----Early Branch Dectection------

To implement this part, branch detection is implemented in the decode stage. This was done by checking the OP code of the current instruction. If the 
code is either a jump or branch, the RD value of the instruction is passed to the control unit, which then compares and calculates the PC value of the 
required branch instruction.
