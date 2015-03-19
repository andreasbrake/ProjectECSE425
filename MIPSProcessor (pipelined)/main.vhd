-- Entity declaration for Main
-- Copyright (C) 2014
-- Version 1.0
-- Author: Andreas Brake
-- Date: February 25, 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY main IS
   PORT(clock : IN STD_LOGIC;
        reset : IN STD_LOGIC);
END main;

ARCHITECTURE arch of main is

COMPONENT instruction_fetch
    PORT(
        pc_in        : IN STD_LOGIC_VECTOR(9 downto 0);
        
        stall        : IN STD_LOGIC;
        clock        : IN STD_LOGIC;
        reset        : IN STD_LOGIC;

        pc_plus_out  : OUT STD_LOGIC_VECTOR(9 downto 0);
        instruction  : OUT STD_LOGIC_VECTOR(31 downto 0));
END COMPONENT;

COMPONENT instruction_decode
   PORT(instruction     : IN STD_LOGIC_VECTOR(31 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        write_register  : IN STD_LOGIC_VECTOR(4 downto 0);
        pc_plus_4_in    : IN STD_LOGIC_VECTOR(9 downto 0);
        
        reg_write_in    : IN STD_LOGIC;
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC;

        -- CONTROL UNIT OUTPUTS --------
        -- EX
        alu_src_out     : OUT STD_LOGIC;
        alu_op_out      : OUT STD_LOGIC_VECTOR(1 downto 0);
        reg_dst_out     : OUT STD_LOGIC;
        -- MEM
        mem_read_out    : OUT STD_LOGIC;
        mem_write_out   : OUT STD_LOGIC;
        branch_out      : OUT STD_LOGIC;
        branch_ne_out   : OUT STD_LOGIC;
        jump_out        : OUT STD_LOGIC;
        word_byte_out   : OUT STD_LOGIC;
        -- WB       
        mem_to_reg_out  : OUT STD_LOGIC;
        reg_write_out   : OUT STD_LOGIC;
        --------------------------------

        stall_out       : OUT STD_LOGIC;

        read_data1      : OUT STD_LOGIC_VECTOR(31 downto 0);
        read_data2      : OUT STD_LOGIC_VECTOR(31 downto 0);
        wreg_dst_out1   : OUT STD_LOGIC_VECTOR(4 downto 0);
        wreg_dst_out2   : OUT STD_LOGIC_VECTOR(4 downto 0);
        sign_extend_out : OUT STD_LOGIC_VECTOR(31 downto 0);
        pc_plus_4_out   : OUT STD_LOGIC_VECTOR(9 downto 0));
END COMPONENT;

COMPONENT instruction_execute
   PORT(pc_plus_4      : IN STD_LOGIC_VECTOR(9 downto 0);
        reg_data_0     : IN STD_LOGIC_VECTOR(31 downto 0);
        reg_data_1     : IN STD_LOGIC_VECTOR(31 downto 0);
        sign_extend_in : IN STD_LOGIC_VECTOR(31 downto 0);
        wreg_dst_0     : IN STD_LOGIC_VECTOR(4 downto 0);
        wreg_dst_1     : IN STD_LOGIC_VECTOR(4 downto 0);


        -- CONTROL UNIT INPUTS ---------
        -- EX
        alu_src        : IN STD_LOGIC;
        alu_op         : IN STD_LOGIC_VECTOR(1 downto 0);
        reg_dst        : IN STD_LOGIC;
        -- MEM
        mem_read_in    : IN STD_LOGIC;
        mem_write_in   : IN STD_LOGIC;
        branch_in      : IN STD_LOGIC;
        branch_ne_in   : IN STD_LOGIC;
        jump_in        : IN STD_LOGIC;
        mem_read_out   : OUT STD_LOGIC;
        mem_write_out  : OUT STD_LOGIC;
        branch_out     : OUT STD_LOGIC;
        branch_ne_out  : OUT STD_LOGIC;
        jump_out       : OUT STD_LOGIC;
        -- WB
        mem_to_reg_in  : IN STD_LOGIC;
        reg_write_in   : IN STD_LOGIC;        
        mem_to_reg_out : OUT STD_LOGIC;
        reg_write_out  : OUT STD_LOGIC;
        ---------------------------------

        next_pc        : OUT STD_LOGIC_VECTOR(9 downto 0);
        alu_result     : OUT STD_LOGIC_VECTOR(31 downto 0);
        alu_zero       : OUT STD_LOGIC;
        write_data_out : OUT STD_LOGIC_VECTOR(31 downto 0);
        wreg_dst_out   : OUT STD_LOGIC_VECTOR(4 downto 0);

        clock          : IN STD_LOGIC;
        reset          : IN STD_LOGIC);
END COMPONENT;

COMPONENT data_memory
   PORT(mem_address     : IN STD_LOGIC_VECTOR(31 downto 0);
        write_data      : IN STD_LOGIC_VECTOR(31 downto 0);
        read_data_out   : OUT STD_LOGIC_VECTOR(31 downto 0);
        mem_address_out : OUT STD_LOGIC_VECTOR(31 downto 0);

        -- CARRY THROUGHS
        next_pc_in      : IN STD_LOGIC_VECTOR(9 downto 0);
        next_pc_out     : OUT STD_LOGIC_VECTOR(9 downto 0);
        reg_mux_in      : IN STD_LOGIC_VECTOR(4 downto 0);
        reg_mux_out     : OUT STD_LOGIC_VECTOR(4 downto 0);
        -----------------

        zero            : IN STD_LOGIC;

        -- INPUTS FROM  THE CONTROL UNIT
        -- MEM
        mem_read        : IN STD_LOGIC;
        mem_write       : IN STD_LOGIC;
        branch          : IN STD_LOGIC;
        branch_ne       : IN STD_LOGIC;
        jump            : IN STD_LOGIC;
        -- WB
        mem_to_reg_in   : IN STD_LOGIC;
        reg_write_in    : IN STD_LOGIC;
        mem_to_reg_out  : OUT STD_LOGIC;
        reg_write_out   : OUT STD_LOGIC;
        --------------------------------

        pc_src_out      : OUT STD_LOGIC;
        
        reset           : IN STD_LOGIC;
        clock           : IN STD_LOGIC);
END COMPONENT;

COMPONENT writeback
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
END COMPONENT;

-- CONTROL UNIT SIGNALS --------
-- EX
signal alu_src_1     : STD_LOGIC;
signal alu_op_1      : STD_LOGIC_VECTOR(1 downto 0);
signal reg_dst_1     : STD_LOGIC;
-- MEM
signal mem_read_1    : STD_LOGIC;
signal mem_write_1   : STD_LOGIC;
signal branch_1      : STD_LOGIC;
signal branch_ne_1   : STD_LOGIC;
signal jump_1        : STD_LOGIC;
signal word_byte_1   : STD_LOGIC;
signal mem_read_2    : STD_LOGIC;
signal mem_write_2   : STD_LOGIC;
signal branch_2      : STD_LOGIC;
signal branch_ne_2   : STD_LOGIC;
signal jump_2        : STD_LOGIC;
signal word_byte_2   : STD_LOGIC;
-- WB       
signal mem_to_reg_1  : STD_LOGIC;
signal reg_write_1   : STD_LOGIC;
signal mem_to_reg_2  : STD_LOGIC;
signal reg_write_2   : STD_LOGIC;
signal mem_to_reg_3  : STD_LOGIC;
signal reg_write_3   : STD_LOGIC;
signal reg_write_4   : STD_LOGIC;
-- MISC?

--------------------------------


-- IF/ID --
signal pc_plus_1     : STD_LOGIC_VECTOR(9 downto 0);
signal instruction   : STD_LOGIC_VECTOR(31 downto 0);
-----------

-- ID/EX --
signal pc_plus_2     : STD_LOGIC_VECTOR(9 downto 0);
signal r_data_1      : STD_LOGIC_VECTOR(31 downto 0);
signal r_data_2      : STD_LOGIC_VECTOR(31 downto 0);
signal sgnx          : STD_LOGIC_VECTOR(31 downto 0);
signal wreg_dst_1    : STD_LOGIC_VECTOR(4 downto 0);
signal wreg_dst_2    : STD_LOGIC_VECTOR(4 downto 0);
-----------

-- EX/MEM --
signal next_pc_1     : STD_LOGIC_VECTOR(9 downto 0);
signal zero          : STD_LOGIC;
signal mem_addr      : STD_LOGIC_VECTOR(31 downto 0);
signal mem_data      : STD_LOGIC_VECTOR(31 downto 0);
signal w_reg_1       : STD_LOGIC_VECTOR(4 downto 0);
------------

-- MEM/WB --
signal mem_read_data : STD_LOGIC_VECTOR(31 downto 0);
signal mem_read_addr : STD_LOGIC_VECTOR(31 downto 0);
signal w_reg_2       : STD_LOGIC_VECTOR(4 downto 0);
------------

-- GEN OUTS --
signal next_pc_2     : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
signal next_pc_3     : STD_LOGIC_VECTOR(9 downto 0);
signal pc_src        : STD_LOGIC := '0';
signal wb_data       : STD_LOGIC_VECTOR(31 downto 0);
signal wb_reg        : STD_LOGIC_VECTOR(4 downto 0);
signal stall         : STD_LOGIC;
--------------

-- GEN INS --
signal next_pc       : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
-------------

BEGIN

WITH pc_src SELECT next_pc <= next_pc_3 WHEN '1', next_pc_2 WHEN OTHERS;
next_pc_2 <= pc_plus_1;

ifetch: instruction_fetch
    PORT MAP(
        pc_in        => next_pc,
        
        stall        => stall,
        clock        => clock,
        reset        => reset,

        pc_plus_out  => pc_plus_1,
        instruction  => instruction);

idecode: instruction_decode
   PORT MAP(instruction     => instruction,
        write_data      => wb_data,
        write_register  => wb_reg,
        pc_plus_4_in    => pc_plus_1,
        
        reg_write_in    => reg_write_4,
        reset           => reset,
        clock           => clock,

        -- CONTROL UNIT OUTPUTS --------
        -- EX
        alu_src_out     => alu_src_1,
        alu_op_out      => alu_op_1,
        reg_dst_out     => reg_dst_1,
        -- MEM
        mem_read_out    => mem_read_1,
        mem_write_out   => mem_write_1,
        branch_out      => branch_1,
        branch_ne_out   => branch_ne_1,
        jump_out        => jump_1,
        word_byte_out   => word_byte_1,
        -- WB       
        mem_to_reg_out  => mem_to_reg_1,
        reg_write_out   => reg_write_1,
        --------------------------------

        stall_out       => stall,
        read_data1      => r_data_1,
        read_data2      => r_data_2,
        wreg_dst_out1   => wreg_dst_1,
        wreg_dst_out2   => wreg_dst_2,
        sign_extend_out => sgnx,
        pc_plus_4_out   => pc_plus_2);

iexecute: instruction_execute
   PORT MAP(pc_plus_4      => pc_plus_2,
        reg_data_0     => r_data_1,
        reg_data_1     => r_data_2,
        sign_extend_in => sgnx,
        wreg_dst_0     => wreg_dst_1,
        wreg_dst_1     => wreg_dst_2,


        -- CONTROL UNIT INPUTS ---------
        -- EX
        alu_src        => alu_src_1,
        alu_op         => alu_op_1,
        reg_dst        => reg_dst_1,
        -- MEM
        mem_read_in    => mem_read_1,
        mem_write_in   => mem_write_1,
        branch_in      => branch_1,
        branch_ne_in   => branch_ne_1,
        jump_in        => jump_1,
        mem_read_out   => mem_read_2,
        mem_write_out  => mem_write_2,
        branch_out     => branch_2,
        branch_ne_out  => branch_ne_2,
        jump_out       => jump_2,
        -- WB
        mem_to_reg_in  => mem_to_reg_1,
        reg_write_in   => reg_write_1,        
        mem_to_reg_out => mem_to_reg_2,
        reg_write_out  => reg_write_2,
        ---------------------------------

        next_pc        => next_pc_1,
        alu_result     => mem_addr,
        alu_zero       => zero,
        write_data_out => mem_data,
        wreg_dst_out   => w_reg_1,

        clock          => clock,
        reset          => reset);

mem: data_memory
   PORT MAP(
        mem_address     => mem_addr,
        write_data      => mem_data,
        zero            => zero,
        read_data_out   => mem_read_data,
        mem_address_out => mem_read_addr,

        -- CARRY THROUGHS
        next_pc_in      => next_pc_1,
        next_pc_out     => next_pc_3,
        reg_mux_in      => w_reg_1,
        reg_mux_out     => w_reg_2,
        -----------------

        -- INPUTS FROM  THE CONTROL UNIT
        -- MEM
        mem_read        => mem_read_2,
        mem_write       => mem_write_2,
        branch          => branch_2,
        branch_ne       => branch_ne_2,
        jump            => jump_2,
        -- WB
        mem_to_reg_in   => mem_to_reg_2,
        reg_write_in    => reg_write_2,
        mem_to_reg_out  => mem_to_reg_3,
        reg_write_out   => reg_write_3,
        --------------------------------

        pc_src_out      => pc_src,
        
        reset           => reset,
        clock           => clock);

wb: writeback
   PORT MAP(write_data0     => mem_read_data,
        write_data1     => mem_read_addr,
        write_reg_in    => w_reg_2,

        mem_to_reg      => mem_to_reg_3,
        reg_write_in    => reg_write_3,
        reg_write_out   => reg_write_4,

        reset           => reset,
        clock           => clock,
        
        write_back      => wb_data,
        write_register  => wb_reg);

end arch;