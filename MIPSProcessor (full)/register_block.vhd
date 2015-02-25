-- Entity declaration for Instruction Register
-- Copyright (C) 2014
-- Version 1.0
-- Author: Andreas Brake
-- Date: February 24, 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY register_block IS
   PORT(read_register1 	: IN STD_LOGIC_VECTOR(4 downto 0);
        read_register2 	: IN STD_LOGIC_VECTOR(4 downto 0);
        
        write_register	 : IN STD_LOGIC_VECTOR(4 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        reg_write       : IN STD_LOGIC;
		
		    reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC;
		
        read_data1      : OUT STD_LOGIC_VECTOR(31 downto 0);
        read_data2      : OUT STD_LOGIC_VECTOR(31 downto 0));
END register_block;

ARCHITECTURE main of register_block is

type register_file is array(0 to 31) of std_logic_vector(31 downto 0);
signal registers : register_file;

BEGIN

regFile : process(reg_write, reset, clock, write_data, read_register1, read_register2) is
begin
    if clock = '1' and clock'event then
        if reset = '1' then
            FOR i IN 0 TO 31 LOOP
                  registers(i) <= "00000000000000000000000000000000";  
            END LOOP;
        else
		        read_data1 <= registers(to_integer(unsigned(read_register1)));
		        read_data2 <= registers(to_integer(unsigned(read_register2)));
		
		        if reg_write = '1' then
			          registers(to_integer(unsigned(write_register))) <= write_data;
			          if read_register1 = write_register then
				            read_data1 <= write_data;
			          end if;
			          if read_register2 = write_register then
				            read_data2 <= write_data;
			          end if;
		        end if;
		    end if;
	  end if;
end process;


end main;