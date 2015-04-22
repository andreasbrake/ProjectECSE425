-- Entity declaration for instruction_execute
-- Copyright (C) 2014
-- Version 1.0
-- Author: Andreas Brake
-- Date: February 25, 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY instruction_execute IS
   PORT(reg_data_0     : IN STD_LOGIC_VECTOR(31 downto 0);
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
        mem_read_out   : OUT STD_LOGIC;
        mem_write_out  : OUT STD_LOGIC;
        -- WB
        mem_to_reg_in  : IN STD_LOGIC;
        reg_write_in   : IN STD_LOGIC;        
        mem_to_reg_out : OUT STD_LOGIC;
        reg_write_out  : OUT STD_LOGIC;
        ---------------------------------

        mem_read_back  : OUT STD_LOGIC;
        reg_rt_back    : OUT STD_LOGIC_VECTOR(4 downto 0);

        -- FORWARDING UNIT INPUTS -------
        ex_mem_rd       : IN STD_LOGIC_VECTOR(4 downto 0);
        ex_mem_regwrite : IN STD_LOGIC;
        mem_wb_rd       : IN STD_LOGIC_VECTOR(4 downto 0);
        mem_wb_regwrite : IN STD_LOGIC;
        
        if_id_rs        : IN STD_LOGIC_VECTOR(4 downto 0);
        ---------------------------------
        
        -- FORWARDING MUX INPUTS --------
        ex_mem_alu_in : IN STD_LOGIC_VECTOR(31 downto 0); -- output from alu in mem stage for forwarding mux
        wb_mux_out    : IN STD_LOGIC_VECTOR(31 downto 0); -- output from wb stage for forwarding mux
        ---------------------------------

        next_pc        : OUT STD_LOGIC_VECTOR(9 downto 0);
        alu_result     : OUT STD_LOGIC_VECTOR(31 downto 0);
        alu_zero       : OUT STD_LOGIC;
        write_data_out : OUT STD_LOGIC_VECTOR(31 downto 0);
        wreg_dst_out   : OUT STD_LOGIC_VECTOR(4 downto 0);

        clock          : IN STD_LOGIC;
        reset          : IN STD_LOGIC);
END instruction_execute;

ARCHITECTURE main of instruction_execute is

    COMPONENT forwarding_unit
    port(   ex_mem_rd       : in  std_logic_vector(4 downto 0); 
            id_ex_rs        : in  std_logic_vector(4 downto 0); 
            id_ex_rt        : in  std_logic_vector(4 downto 0); 
            mem_wb_rd       : in  std_logic_vector(4 downto 0);
            mem_wb_regwrite : in std_logic; 
            ex_mem_regwrite : in std_logic;
            
            ForwardA        : out std_logic_vector(1 downto 0); 
            ForwardB        : out std_logic_vector(1 downto 0));     
    end COMPONENT;

    COMPONENT ALU IS
    PORT ( in1, in2 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
           control  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
           result   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           zero     : OUT STD_LOGIC);
    END COMPONENT;

    -- Input signals set on the clock high
    SIGNAL alu_reg_data0_latched  : std_logic_vector(31 downto 0);
    SIGNAL alu_reg_data1_latched  : std_logic_vector(31 downto 0);
    SIGNAL sign_extended_latched  : std_logic_vector(31 downto 0);
    SIGNAL sign_extended_latched1 : std_logic_vector(7 downto 0);

    -- Other latched signal
    SIGNAL alu_mux_latched       : std_logic_vector(31 downto 0);
    SIGNAL alu_control_latched   : std_logic_vector(2 downto 0);

    -- Internal signals
    SIGNAL alu_op_latched        : std_logic_vector(1 downto 0);
    SIGNAL alu_mux_out           : std_logic_vector(31 downto 0);
    SIGNAL shifted_sign_extend   : std_logic_vector(9 downto 0);
    SIGNAL wreg_dst_out_tmp      : std_logic_vector(4 downto 0);
    SIGNAL alu_control           : std_logic_vector(2 downto 0);
    SIGNAL funct_code            : std_logic_vector(5 downto 0);

    SIGNAL alu_result_inter      : std_logic_vector(31 downto 0);
    SIGNAL state                 : std_logic;
    SIGNAL alu_cont_temp         : std_logic_vector(2 downto 0);
    SIGNAL control_case          : std_logic_vector(7 downto 0);

    signal forwardA      : std_logic_vector(1 downto 0);
    signal forwardB      : std_logic_vector(1 downto 0);
    signal inter_alu_mux : std_logic_vector(31 downto 0);
    signal alu_mux_out_1 : std_logic_vector(31 downto 0);

BEGIN

    fwd: forwarding_unit port map(   
            ex_mem_rd       => ex_mem_rd, 
            id_ex_rs        => if_id_rs, 
            id_ex_rt        => wreg_dst_0, 
            mem_wb_rd       => mem_wb_rd,
            mem_wb_regwrite => mem_wb_regwrite, 
            ex_mem_regwrite => ex_mem_regwrite,
            
            ForwardA        => forwardA, 
            ForwardB        => forwardB);


    a1u: ALU PORT MAP(
            in1      => reg_data_0,
            in2      => alu_mux_out,
            control  => alu_control,
            result   => alu_result_inter,
            zero     => alu_zero);

    -- SHIFT LEFT
    shifted_sign_extend (9 downto 2) <= sign_extended_latched(7 downto 0);
    shifted_sign_extend (1 downto 0) <= "00";

    -- MUX computations
    with forwardA SELECT alu_mux_out_1 <= reg_data_0    WHEN "00", wb_mux_out     WHEN "01", ex_mem_alu_in WHEN OTHERS; 
    with forwardB SELECT inter_alu_mux <= reg_data_1    WHEN "00", wb_mux_out     WHEN "01", ex_mem_alu_in WHEN OTHERS; 
    with alu_src  SELECT alu_mux_out   <= inter_alu_mux WHEN '0',  sign_extend_in WHEN OTHERS; 
    
    with reg_dst select wreg_dst_out_tmp <= wreg_dst_0 when '0', wreg_dst_1 when others;

    -----------------------------------------------------------------------
    -- ALU Control Bits

    funct_code     <= sign_extended_latched(5 downto 0);
    alu_cont_temp  <= ((funct_code(1) AND alu_op_latched(1)) OR alu_op_latched(0)) & (( NOT funct_code(2) ) OR ( NOT alu_op_latched(1) ) ) & (( funct_code(1) AND funct_code(3) AND alu_op_latched(1) ) OR ( funct_code(0) AND funct_code(2) AND alu_op_latched(1) ));

    control_case   <= funct_code & alu_op_latched;

    with control_case select alu_control <= "011" when "01100010", alu_cont_temp when others;
    -----------------------------------------------------------------------

-- 
PROCESS(clock)    
BEGIN
    if clock = '1' and clock'event then
        if reset = '1' then
            -- INITIAL VALUES
            state <= '0';
        elsif state = '0' then
            -- BURN A CYCLE TO KEEP IN TIME
            alu_reg_data0_latched <= reg_data_0;
            alu_reg_data1_latched <= reg_data_1;
            sign_extended_latched <= sign_extend_in;
            alu_op_latched        <= alu_op;
            mem_read_back         <= mem_read_in;
            reg_rt_back           <= wreg_dst_0;
	
            alu_result     <= alu_result_inter;
            state <= '1';
        elsif state = '1' then
            -- Latch values from the input signals, muxs, and control bits
            
            write_data_out        <= reg_data_1;
            wreg_dst_out          <= wreg_dst_out_tmp;

            -- PASSING ON CONTROL BITS
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out  <= reg_write_in;
            

            state <= '0';
        end if;

    end if;
END PROCESS;

end main;

