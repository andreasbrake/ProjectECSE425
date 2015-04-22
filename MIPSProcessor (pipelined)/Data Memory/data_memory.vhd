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
   PORT(mem_address     : IN STD_LOGIC_VECTOR(31 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        read_data_out   : OUT STD_LOGIC_VECTOR(31 downto 0);
        mem_address_out : OUT STD_LOGIC_VECTOR(31 downto 0);

        -- CARRY THROUGHS
        reg_mux_in      : IN  STD_LOGIC_VECTOR(4 downto 0);
        reg_mux_out     : OUT STD_LOGIC_VECTOR(4 downto 0);
        -----------------

        -- INPUTS FROM  THE CONTROL UNIT
        -- MEM
        mem_read        : IN STD_LOGIC;
        mem_write       : IN STD_LOGIC;
        -- WB
        mem_to_reg_in   : IN STD_LOGIC;
        reg_write_in    : IN STD_LOGIC;
        mem_to_reg_out  : OUT STD_LOGIC;
        reg_write_out   : OUT STD_LOGIC;
        --------------------------------

        ---OUTPUTS FOR FORWARDING UNIT--------
        ex_mem_rd          : OUT STD_LOGIC_VECTOR(4 downto 0);
        ex_mem_regwrite    : OUT STD_LOGIC;   
        address_forwarding : OUT STD_LOGIC_VECTOR(31 downto 0);
        
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC);
END data_memory;

ARCHITECTURE main of data_memory is

COMPONENT Main_Memory
    generic (
        File_Address_Read  : string  :="Init.dat";
        File_Address_Write : string  :="MemCon.dat";
        Mem_Size_in_Word   : integer :=256;	
        Num_Bytes_in_Word  : integer :=4;
        Num_Bits_in_Byte   : integer := 8; 
        Read_Delay         : integer :=0; 
        Write_Delay        : integer :=0);
    port (
        clk                : in std_logic;
        address            : in integer;
        Word_Byte          : in std_logic; -- when '1' you are interacting with the memory in word otherwise in byte
        we                 : in std_logic;
        wr_done            : out std_logic; --indicates that the write operation has been done.
        re                 : in std_logic;
        rd_ready           : out std_logic; --indicates that the read data is ready at the output.
        data               : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);        
        initialize         : in std_logic;
        dump               : in std_logic);			
END COMPONENT;

signal mem_data      : std_logic_vector(31 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
signal mem_addr_int  : integer;
signal rd_ready      : std_logic;
signal wr_done       : std_logic;

signal mem_state     : std_logic;
signal state         : std_logic;

signal mem_read_latched: std_logic:= '0';
signal mem_write_latched: std_logic:= '0';
signal read_data_inter : std_logic_vector(31 downto 0);
BEGIN

mem_addr_int <= to_integer(unsigned(mem_address));

mem: main_memory 	
    generic MAP (
        Mem_Size_in_Word  => 1024
    )
    port MAP (
        clk         => clock,
        address     => mem_addr_int,
        Word_Byte   => '1', -- when '1' you are interacting with the memory in word otherwise in byte

        we          => mem_write_latched,
        re          => mem_read_latched,
			
        data        => mem_data,       
        initialize  => reset,
        dump        => '1',
			
        rd_ready    => rd_ready, --indicates that the read data is ready at the output.		
        wr_done     => wr_done --indicates that the write operation has been done.
    );

-- State dependent process
process(clock, reset, mem_state, rd_ready, wr_done)
begin
if clock = '1' and clock'event then
    if reset = '1' then
        state <= '0';
    else
        if state = '0' then
            ex_mem_rd <= reg_mux_in;
            ex_mem_regwrite <= reg_write_in;
            address_forwarding <= mem_address;
            state <= '1';
        elsif state = '1' then
            reg_mux_out <= reg_mux_in;
            mem_address_out <= mem_address;
            read_data_out <= read_data_inter;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out <= reg_write_in;
            state <= '0';
        end if; 
    end if;
end if;

if reset = '1' then
    mem_state <= '0';
elsif mem_state = '0' then
    -- IN MEM_STATE 0, WAIT UNTIL A READ OR WRITE IS SET AND ACT ACCORDINGLY
    if mem_read = '1' then
        mem_read_latched <= mem_read;
        mem_data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"; -- SET TO 'Z's WHEN NOT IN USE
        mem_state <= '1';
    elsif mem_write = '1' then
        mem_write_latched <= mem_write;
        mem_data <= write_data;
        mem_state <= '1';
    else
        mem_data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
    end if;
elsif mem_state = '1' then
    -- IN MEM_STATE 1, WAIT UNTIL A READY STATE IS SET AND LATCH VALUE
    if rd_ready = '1' and rd_ready'event then
        read_data_inter <= mem_data;
        mem_read_latched <= '0';
        mem_state <= '0';
    elsif wr_done = '1' and wr_done'event then
        mem_data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
        mem_write_latched <= '0';
        mem_state <= '0';
    elsif mem_read = '0' and mem_write = '0' then
        mem_data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
        mem_read_latched <= '0';
        mem_write_latched <= '0';
        mem_state <= '0';
    end if;
end if;

end process;

end main;

