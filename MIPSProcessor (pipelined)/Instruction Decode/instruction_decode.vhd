-- Entity declaration for Instruction Decode
-- Copyright (C) 2014
-- Version 1.0
-- Author: Andreas Brake
-- Date: February 24, 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

ENTITY instruction_decode IS
   PORT(instruction     : IN STD_LOGIC_VECTOR(31 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        write_register  : IN STD_LOGIC_VECTOR(4 downto 0);
        pc_in           : IN STD_LOGIC_VECTOR(9 downto 0);

        reg_write_in    : IN STD_LOGIC;
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC;

        -- FORWARDING OUTPUT--
        id_ex_rs        : OUT STD_LOGIC_VECTOR(4 downto 0);

        -- CONTROL UNIT OUTPUTS --------
        -- EX
        alu_src_out     : OUT STD_LOGIC;
        alu_op_out      : OUT STD_LOGIC_VECTOR(1 downto 0);
        reg_dst_out     : OUT STD_LOGIC;
        -- MEM
        mem_read_out    : OUT STD_LOGIC;
        mem_write_out   : OUT STD_LOGIC;
        word_byte_out   : OUT STD_LOGIC;
        -- WB       
        mem_to_reg_out  : OUT STD_LOGIC;
        reg_write_out   : OUT STD_LOGIC;
        --------------------------------

        -- STUFF TO DO WITH HANDLING HAZARDS --
        mem_read_in     : IN STD_LOGIC;
        reg_rt_in       : IN STD_LOGIC_VECTOR(4 downto 0);
        stall_out       : OUT STD_LOGIC;
        if_flush        : OUT STD_LOGIC;
        ---------------------------------------

        read_data1      : OUT STD_LOGIC_VECTOR(31 downto 0);
        read_data2      : OUT STD_LOGIC_VECTOR(31 downto 0);
        wreg_dst_out1   : OUT STD_LOGIC_VECTOR(4 downto 0);
        wreg_dst_out2   : OUT STD_LOGIC_VECTOR(4 downto 0);
        sign_extend_out : OUT STD_LOGIC_VECTOR(31 downto 0);
	
	branch          : OUT STD_LOGIC;
        next_pc         : OUT STD_LOGIC_VECTOR(9 downto 0));
END instruction_decode;

ARCHITECTURE main of instruction_decode is

COMPONENT register_block
   PORT(read_register1 	: IN STD_LOGIC_VECTOR(4 downto 0);
        read_register2 	: IN STD_LOGIC_VECTOR(4 downto 0);
        
        write_register	: IN STD_LOGIC_VECTOR(4 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        
        reg_write       : IN STD_LOGIC;
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC;

        read_data1      : OUT STD_LOGIC_VECTOR(31 downto 0);
        read_data2      : OUT STD_LOGIC_VECTOR(31 downto 0));
END COMPONENT;

COMPONENT Control_Unit
    PORT (
        instruction: IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        alu_op     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_src    : OUT STD_LOGIC;
        reg_dst    : OUT STD_LOGIC;

        jump       : OUT STD_LOGIC;
        branch     : OUT STD_LOGIC;
        branch_ne  : OUT STD_LOGIC;

        mem_read   : OUT STD_LOGIC;
        mem_write  : OUT STD_LOGIC;
        word_byte  : OUT STD_LOGIC;

        mem_to_reg : OUT STD_LOGIC;
        reg_write  : OUT STD_LOGIC;

        if_flush   : OUT STD_LOGIC;

        -- HAZARD CONTROL --
        mem_read_in : IN STD_LOGIC;
        reg_rt_p    : IN STD_LOGIC_VECTOR(4 downto 0);
        reg_rs      : IN STD_LOGIC_VECTOR(4 downto 0);
        reg_rt      : IN STD_LOGIC_VECTOR(4 downto 0);
        reg_rd      : IN STD_LOGIC_VECTOR(4 downto 0);
        stall_out   : OUT STD_LOGIC;
        --------------------

        clock       : IN STD_LOGIC;
        reset       : IN STD_LOGIC);
END COMPONENT;

COMPONENT ADDER IS
    PORT (  A        : in std_logic_vector(9 downto 0);
            B        : in integer;
            result   : out std_logic_vector(9 downto 0));
END COMPONENT;


signal pc_plus_latched   : std_logic_vector(9 downto 0);

signal opcode_latched    : std_logic_vector(5 downto 0);
signal sx_out_latched    : std_logic_vector(31 downto 0);
signal branch_pc         : std_logic_vector(9 downto 0);
signal state             : std_logic;
signal stall             : std_logic := '0';
signal zero              : std_logic := '0';
signal stall_instruction : std_logic_vector(31 downto 0);
signal stall_inst_int    : std_logic_vector(31 downto 0);

signal inst_internal     : std_logic_vector(31 downto 0);

signal read_data_inter1  : std_logic_vector(31 downto 0);
signal read_data_inter2  : std_logic_vector(31 downto 0);

signal jump              : std_logic := '0';
signal branch_eq         : std_logic := '0';
signal branch_neq        : std_logic := '0';
signal branch_int        : std_logic := '0';

signal flag_comb         : std_logic_vector(1 downto 0);
signal data_diff         : std_logic_vector(31 downto 0);

signal pc_increase       : integer;

signal read_reg_1        : std_logic_vector(4 downto 0);
signal read_reg_2        : std_logic_vector(4 downto 0);

BEGIN


-- SET VALUES
stall_out      <= stall;
data_diff      <= read_data_inter1 - read_data_inter2;

reg: register_block PORT MAP (
        read_register1 => instruction(25 downto 21),
        read_register2 => instruction(20 downto 16),
        write_register => write_register,
        write_data     => write_data,
        reg_write      => reg_write_in,
        reset          => reset,
        clock          => clock,
        
        read_data1     => read_data_inter1,
        read_data2     => read_data_inter2);

con: control_unit PORT MAP(
        instruction     => instruction,

        alu_op     => alu_op_out,
        alu_src    => alu_src_out,
        reg_dst    => reg_dst_out,

        jump       => jump,
        branch     => branch_eq,
        branch_ne  => branch_neq,

        mem_read   => mem_read_out,
        mem_write  => mem_write_out,
        word_byte  => word_byte_out,

        mem_to_reg => mem_to_reg_out,
        reg_write  => reg_write_out,

        if_flush   => if_flush,

        -- HAZARD CONTROL --
        mem_read_in=> mem_read_in,
        reg_rt_p   => reg_rt_in,
        reg_rs     => instruction(25 downto 21),
        reg_rt     => instruction(20 downto 16),
        reg_rd     => instruction(15 downto 11),
        stall_out  => stall,
        --------------------

        clock      => clock,
        reset      => reset);

pc_branch: ADDER PORT MAP(
        A        => pc_in,
        B        => pc_increase,
        result   => branch_pc);

WITH data_diff SELECT zero <= '1' WHEN "00000000000000000000000000000000", '0' WHEN OTHERS;
branch_int <= jump or (branch_eq and zero) or (branch_neq and (not zero)) ;
branch <= branch_int;

flag_comb <= branch_int & stall;
next_pc <= branch_pc WHEN flag_comb = "10" ELSE pc_in;
--WITH (branch_int & stall) SELECT next_pc <= branch_pc WHEN "10", pc_int WHEN OTHERS;

process(clock)
begin
    if clock = '1' and clock'event then
        if reset = '1' then -- ON RESET, SET INITIAL VALUES
            state <= '0';
        elsif state = '0' then
            -- BLANK ON STALL
            if branch_int = '1' and stall = '0' then
                if jump = '1' and instruction(31 downto 26) = "00000" then
                    pc_increase <= (to_integer(signed(instruction(15 downto 11))) * 4);
                else
                    pc_increase <= (to_integer(signed(instruction(15 downto 0))) * 4); 
                end if;
            end if;

            -- LATCH VALUES TO BE PASSED OUT TO EX
            wreg_dst_out1 <= instruction(20 downto 16);
            wreg_dst_out2 <= instruction(15 downto 11);
	    
	    sx_out_latched <= std_logic_vector(resize(signed(instruction(15 downto 0)), sx_out_latched'length));

            id_ex_rs      <= instruction(25 downto 21);
	    
            state <= '1';
        elsif state = '1' then
            -- BLANK ON STALL
            if stall = '1' then
                sign_extend_out <= "00000000000000000000000000000000";
                read_data1 <= read_data_inter1;
                read_data2 <= read_data_inter2;
            else
                sign_extend_out <= sx_out_latched;
                
                read_data1 <= read_data_inter1;
                read_data2 <= read_data_inter2;
            end if;
           
            state <= '0';
        end if;
    end if;
end process;
end main;
