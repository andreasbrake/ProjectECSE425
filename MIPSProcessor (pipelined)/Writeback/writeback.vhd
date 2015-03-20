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

signal write_data0_latched : std_logic_vector(31 downto 0);
signal write_data1_latched : std_logic_vector(31 downto 0);
signal mem_to_reg_latched  : std_logic;

signal wb_data_x           : std_logic_vector(31 downto 0);
signal wb_reg_x            : std_logic_vector(4 downto 0);

signal wb_data_latched     : std_logic_vector(31 downto 0);
signal wb_reg_latched      : std_logic_vector(4 downto 0);

signal state               : std_logic;

BEGIN

-- Writeback
with mem_to_reg_latched select wb_data_x <= write_data0_latched when '1', write_data1_latched when others;

process(clock)
begin
    if clock = '1' and clock'event then
        -- Reset to output zero
        if reset = '1' then
            mem_to_reg_latched  <= '0';
            write_data0_latched <= "00000000000000000000000000000000";
            write_data1_latched <= "00000000000000000000000000000000";
            state               <= '0';
        elsif state = '0' then
            -- BURN A CYCLE TO STAY IN TIME
            write_data0_latched <= write_data0;
            write_data1_latched <= write_data1;
            mem_to_reg_latched  <= mem_to_reg; 
            wb_reg_x            <= write_reg_in;
            state               <= '1';
        elsif state = '1' then
            write_back     <= wb_data_x;
            write_register <= wb_reg_x;
            reg_write_out <= reg_write_in;
            state          <= '0';
        end if;  
    end if;
end process;

end main;
