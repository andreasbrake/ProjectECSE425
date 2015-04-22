-- Entity declaration for Data Memory
-- Copyright (C) 2014
-- Version 1.0
-- Author: Andreas Brake
-- Date: February 24, 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY writeback IS
   PORT(write_data0     : IN STD_LOGIC_VECTOR(31 downto 0);
        write_data1     : IN STD_LOGIC_VECTOR(31 downto 0);
        write_reg_in    : IN STD_LOGIC_VECTOR(4 downto 0);

        -- CONTROL UNIT OUTPUTS --------
        -- WB --
        mem_to_reg      : IN STD_LOGIC;
        reg_write_in    : IN STD_LOGIC;
        reg_write_out   : OUT STD_LOGIC;
        --------
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC;
		
        write_back      : OUT STD_LOGIC_VECTOR(31 downto 0);
        write_register  : OUT STD_LOGIC_VECTOR(4 downto 0));
END writeback;

ARCHITECTURE main of writeback is

signal mem_to_reg_latched  : std_logic;

signal wb_data_x           : std_logic_vector(31 downto 0);
signal wb_reg_x            : std_logic_vector(4 downto 0);

signal wb_data_latched     : std_logic_vector(31 downto 0);
signal wb_reg_latched      : std_logic_vector(4 downto 0);

signal state               : std_logic;

BEGIN

-- Writeback
with mem_to_reg select write_back <= write_data0 when '1', write_data1 when others;

process(clock, write_reg_in)
begin
    write_register <= write_reg_in;
    reg_write_out       <= reg_write_in;

    if clock = '1' and clock'event then
        -- Reset to output zero
        if reset = '1' then
            mem_to_reg_latched  <= '0';
        else
            -- SEND TO ID TO WRITE THE REGISTER
            mem_to_reg_latched  <= mem_to_reg;
            --write_back          <= wb_data_x;
            
        end if;  
    end if;
end process;

end main;
