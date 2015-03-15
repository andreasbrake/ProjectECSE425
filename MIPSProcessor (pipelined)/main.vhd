-- Entity declaration for Main
-- Copyright (C) 2014
-- Version 1.0
-- Author: Andreas Brake
-- Date: February 25, 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY pipelined_main IS
   PORT(clock : IN STD_LOGIC;
        reset : IN STD_LOGIC);
END pipelined_main;

ARCHITECTURE main of pipelined_main is

COMPONENT instruction_decode
   PORT(instruction     : IN STD_LOGIC_VECTOR(25 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        write_register  : IN STD_LOGIC_VECTOR(4 downto 0);
        pc_plus_4_in    : IN STD_LOGIC_VECTOR(9 downto 0);
        
        reg_dst         : IN STD_LOGIC;
        reg_write       : IN STD_LOGIC;
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC;
		
        read_data1      : OUT STD_LOGIC_VECTOR(31 downto 0);
        read_data2      : OUT STD_LOGIC_VECTOR(31 downto 0);
	wreg_dst_out1   : OUT STD_LOGIC_VECTOR(4 downto 0);
        wreg_dst_out2   : OUT STD_LOGIC_VECTOR(4 downto 0);
        sign_extend_out : OUT STD_LOGIC_VECTOR(31 downto 0);
        pc_plus_4_out   : OUT STD_LOGIC_VECTOR(9 downto 0));
END COMPONENT;

BEGIN



end main;