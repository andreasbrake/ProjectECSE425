-- Entity declaration for Instruction Decode
-- Copyright (C) 2014
-- Version 1.0
-- Author: Andreas Brake
-- Date: February 24, 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY instruction_decode IS
   PORT(instruction 	   : IN STD_LOGIC_VECTOR(25 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        pc_plus_4_in    : IN STD_LOGIC_VECTOR(9 downto 0);
        
        reg_dst         : IN STD_LOGIC;
        reg_write       : IN STD_LOGIC;
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC;
		
        read_data1      : OUT STD_LOGIC_VECTOR(31 downto 0);
        read_data2      : OUT STD_LOGIC_VECTOR(31 downto 0);
        sign_extend_out : OUT STD_LOGIC_VECTOR(31 downto 0);
        pc_plus_4_out   : OUT STD_LOGIC_VECTOR(9 downto 0));
END instruction_decode;

ARCHITECTURE main of instruction_decode is

COMPONENT register_block
   PORT(read_register1 	: IN STD_LOGIC_VECTOR(4 downto 0);
        read_register2 	: IN STD_LOGIC_VECTOR(4 downto 0);
        
        write_register	 : IN STD_LOGIC_VECTOR(4 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        
        reg_write       : IN STD_LOGIC;
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC;
		
        read_data1      : OUT STD_LOGIC_VECTOR(31 downto 0);
        read_data2      : OUT STD_LOGIC_VECTOR(31 downto 0));
END COMPONENT;

COMPONENT sign_extend
    PORT( data_in_16 : in std_logic_vector(15 downto 0);
          data_out_32 : out std_logic_vector(31 downto 0));
END COMPONENT;

signal rreg1  : std_logic_vector(4 downto 0);
signal rreg2  : std_logic_vector(4 downto 0);
signal wreg   : std_logic_vector(4 downto 0);

BEGIN
  
rreg1 <= instruction(25 downto 21);
rreg2 <= instruction(20 downto 16);
pc_plus_4_out <= pc_plus_4_in;

with reg_dst select wreg <= instruction(20 downto 16) when '0', instruction(15 downto 11) when others;

reg: register_block PORT MAP (
        read_register1 => rreg1,
        read_register2 => rreg2,
        write_register => wreg,
        write_data     => write_data,
        reg_write      => reg_write,
        reset          => reset,
        clock          => clock,
        
        read_data1     => read_data1,
        read_data2     => read_data2);
        
snx: sign_extend PORT MAP (
        data_in_16     => instruction(15 downto 0),
        data_out_32    => sign_extend_out);

end main;
