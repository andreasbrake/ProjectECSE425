-- Entity declaration for Instruction Register
-- Copyright (C) 2014 Group 10
-- Version 1.0
-- Author: Mete Kemertas
-- Date: February 19, 2015

library ieee;
use ieee.std_logic_1164.all;

ENTITY g10_inst_reg IS
   PORT(memory_data : IN STD_LOGIC_VECTOR(31 downto 0);
        clock, reset : IN STD_LOGIC;
        
	inst1 : OUT STD_LOGIC_VECTOR(5 downto 0);
	inst2 : OUT STD_LOGIC_VECTOR(4 downto 0);
	inst3 : OUT STD_LOGIC_VECTOR(4 downto 0);
	inst4 : OUT STD_LOGIC_VECTOR(15 downto 0));
END g10_inst_reg;

architecture main of g10_inst_reg is
Begin

process(memory_data,clock,reset,inst1,inst2,inst3,inst4)
begin
    if reset = '1' then
        inst1 <= "000000";
        inst2 <= "00000";
        inst3 <= "00000";
        inst4 <= "0000000000000000";
    elsif clock = '1' and clock'event then
        inst1 <= memory_data(31 downto 26);
        inst2 <= memory_data(25 downto 21);
        inst3 <= memory_data(20 downto 16);
        inst4 <= memory_data(15 downto 0);
        end if;
        end if;

end process;


end main;