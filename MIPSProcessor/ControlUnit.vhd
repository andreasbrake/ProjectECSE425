LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--USE IEEE.numeric_std.ALL;

ENTITY Control_Unit IS
  PORT (
    ControlOp : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    RegDst : OUT STD_LOGIC;
    Jump : OUT STD_LOGIC;
    Branch : OUT STD_LOGIC;
    MemRead : OUT STD_LOGIC;
    BranchNotEqual : OUT STD_LOGIC;
    MemtoReg : OUT STD_LOGIC;
    ALUOp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    MemWrite : OUT STD_LOGIC;
    ALUSrc : OUT STD_LOGIC;
    RegWrite : OUT STD_LOGIC);

END Control_Unit;

architecture behavior OF Control_Unit IS

SIGNAL R_Type, LW, SW, BEQ, BNE, JMP, ADDI : STD_LOGIC;

BEGIN
  R_Type <= '1' WHEN ControlOp = "000000" ELSE '0';
  LW <= '1' WHEN ControlOp = "100011" ELSE '0';
  SW <= '1' WHEN ControlOp = "101011" ELSE '0';
  BEQ <= '1' WHEN ControlOp = "000100" ELSE '0';
  BNE <= '1' WHEN ControlOp = "000101" ELSE '0';
  JMP <= '1' WHEN ControlOp = "000010" ELSE '0';
  ADDI <= '1' WHEN ControlOp = "001000" ELSE '0'; 
  
  RegDst <= R_Type;
  Branch <= BEQ;
  Jump <= JMP;
  MemRead <= LW;
  BranchNotEqual <=BNE;
  MemtoReg <= LW;
  ALUOp(1) <= R_Type;
  ALUOp(0) <= BEQ OR BNE;
  MemWrite <= SW;
  ALUSrc <= LW OR SW OR ADDI;
  RegWrite <= R_Type OR LW OR ADDI; 
  
END behavior;
