-- Entity declaration for Data Memory
-- Copyright (C) 2014
-- Version 1.0
-- Author: Andreas Brake
-- Date: February 24, 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY data_memory IS
   PORT(mem_address 	   : IN STD_LOGIC_VECTOR(31 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        next_pc_in      : IN STD_LOGIC_VECTOR(9 downto 0);
        reg_mux_in      : IN STD_LOGIC_VECTOR(4 downto 0);
        
        mem_read        : IN STD_LOGIC;
        mem_write       : IN STD_LOGIC;
        mem_to_reg      : IN STD_LOGIC;
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC;
		
        write_back      : OUT STD_LOGIC_VECTOR(31 downto 0);
        next_pc_out     : OUT STD_LOGIC_VECTOR(9 downto 0);
        reg_mux_out     : OUT STD_LOGIC_VECTOR(4 downto 0));
END data_memory;

ARCHITECTURE main of data_memory is

COMPONENT Main_Memory
	generic (
			File_Address_Read : string :="Init.dat";
			File_Address_Write : string :="MemCon.dat";
			Mem_Size_in_Word : integer:=256;	
			Num_Bytes_in_Word: integer:=4;
			Num_Bits_in_Byte: integer := 8; 
			Read_Delay: integer:=0; 
			Write_Delay:integer:=0
		 );
	port (
			clk : in std_logic;
			address : in integer;
			Word_Byte: in std_logic; -- when '1' you are interacting with the memory in word otherwise in byte
			we : in std_logic;
			wr_done:out std_logic; --indicates that the write operation has been done.
			re :in std_logic;
			rd_ready: out std_logic; --indicates that the read data is ready at the output.
			data : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);        
			initialize: in std_logic;
			dump: in std_logic
		 );			
END COMPONENT;

signal mem_data  : std_logic_vector(31 downto 0);
signal read_data_out: std_logic_vector(31 downto 0);
signal mem_addr_int  : integer;
signal rd_ready  : std_logic;
signal wr_done   : std_logic;

signal mem_state : std_logic:='0';

BEGIN

mem_addr_int <= to_integer(unsigned(mem_address));

-- Writeback
with mem_to_reg select write_back <= read_data_out when '1', mem_address when others;

mem: main_memory 	
    generic MAP (
			  Mem_Size_in_Word  => 1024
    )
    port MAP (
			clk         => clock,
			address     => mem_addr_int,
			Word_Byte   => '1', -- when '1' you are interacting with the memory in word otherwise in byte

			we          => mem_write,		
			re          => mem_read,
			
			data        => mem_data,       
			initialize  => '0',
			dump        => '0',
			
			rd_ready    => rd_ready, --indicates that the read data is ready at the output.		
      wr_done    => wr_done --indicates that the write operation has been done.
		 );

-- State dependent process
process(clock, rd_ready, wr_done, mem_state, mem_data, write_data)
begin
    if clock = '1' and clock'event then
        -- Reset to output zero
        if reset = '1' then
            read_data_out <= "00000000000000000000000000000000";
        -- State 0 sets the memory data when mem_write is set
        elsif mem_state = '0' then
            mem_state <= '1';
            if mem_write = '1' then
                mem_data <= write_data;
            end if;
        -- State 1 gets the memory data when a read is called
        else
            if (mem_write = '0' and mem_read = '0') or (rd_ready = '0' and wr_done = '1') then
                mem_state <= '0';
            elsif rd_ready = '1' or wr_done = '0' then
                mem_state <= '0';
                read_data_out <= mem_data;            
 
          end if;
        end if;  
    end if;
end process;

end main;

