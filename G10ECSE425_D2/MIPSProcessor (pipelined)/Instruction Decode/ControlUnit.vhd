LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--USE IEEE.numeric_std.ALL;

ENTITY Control_Unit IS
    PORT (
        opcode     : IN STD_LOGIC_VECTOR(5 DOWNTO 0);

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
        reg_rd      : IN STD_LOGIC_VECTOR(4 downto 0);
        reg_rs      : IN STD_LOGIC_VECTOR(4 downto 0);
        reg_rt      : IN STD_LOGIC_VECTOR(4 downto 0);
        curr_npc    : IN STD_LOGIC_VECTOR(9 downto 0);
        stall_out   : OUT STD_LOGIC;
        stall_npc   : OUT STD_LOGIC_VECTOR(9 downto 0);
        --------------------

        clock       : IN STD_LOGIC;
        reset       : IN STD_LOGIC);
END Control_Unit;

architecture behavior OF Control_Unit IS

SIGNAL R_Type, LW, SW, BEQ, BNE, JMP, ADDI, STALL, STATE : STD_LOGIC;

SIGNAL rd_ex, rd_mem, rd_wb : STD_LOGIC_VECTOR(4 downto 0);

SIGNAL stall_inst_internal: STD_LOGIC_VECTOR(31 downto 0);
BEGIN
    R_Type <= '1' WHEN opcode = "000000" ELSE '0';
    LW     <= '1' WHEN opcode = "100011" ELSE '0';
    SW     <= '1' WHEN opcode = "101011" ELSE '0';
    BEQ    <= '1' WHEN opcode = "000100" ELSE '0';
    BNE    <= '1' WHEN opcode = "000101" ELSE '0';
    JMP    <= '1' WHEN opcode = "000010" ELSE '0';
    ADDI   <= '1' WHEN opcode = "001000" ELSE '0'; 

--HAZARD DETECTION
PROCESS(mem_read_in, reg_rt_p, reg_rs, reg_rt, rd_ex, rd_mem, rd_wb)
BEGIN
    -- SET A STALL FOR THE VARIOUS SCENARIOS BELOW
    IF (rd_ex = "00000" and rd_mem = "00000" and rd_wb = "00000") then
        stall <= '0';
    ELSIF (mem_read_in = '1') AND ((reg_rt_p = reg_rs) OR (reg_rt_p = reg_rt)) THEN
        stall <= '1';
    ELSIF (reg_rs /= "00000" and reg_rs /= "UUUUU") and (reg_rs = rd_ex or reg_rs = rd_mem or reg_rs = rd_wb) THEN
        stall <= '1';
    ELSIF (r_type = '1') and (reg_rt /= "00000" and reg_rt /= "UUUUU") and (reg_rt = rd_ex or reg_rt = rd_mem or reg_rt = rd_wb)  THEN
        stall <= '1';
    ELSE
        stall <= '0';
    END IF;
END PROCESS; 

process(clock)
begin

-- USE TWO STATES TO GET THE PROPER TIMING OF OUTPUTS
if clock = '1' and clock'event then   
    if reset = '1' or stall = '1' then
        alu_op(1)  <= '0';
        alu_op(0)  <= '0';
        alu_src    <= '0';
        reg_dst    <= '0';

        mem_write  <= '0';
        mem_read   <= '0';
        word_byte  <= '0';

        branch     <= '0';
        branch_ne  <= '0';
        jump       <= '0';

        mem_to_reg <= '0';
        reg_write  <= '0';

        if_flush   <= '0';

        if reset = '1' then
            rd_wb  <= "00000";
            rd_mem <= "00000";
            rd_ex  <= "00000";
            state  <= '0';
        else
            rd_wb  <= rd_mem;
            rd_mem <= rd_ex;
            rd_ex  <= "00000";
        end if;
        stall_out  <= stall; 
    else
        if state = '0' then
            stall_out <= stall;
            stall_npc <= curr_npc;
            state <= '1';
        else
            rd_wb  <= rd_mem;
            rd_mem <= rd_ex;
            
            alu_op(1)  <= R_Type;
            alu_op(0)  <= BEQ OR BNE;
            alu_src    <= LW  OR SW  OR ADDI;
            reg_dst    <= R_Type;

            mem_write  <= SW;
            mem_read   <= LW;
            word_byte  <= LW OR SW;

            branch     <= BEQ;
            jump       <= JMP;
            branch_ne  <= BNE;

            mem_to_reg <= LW;
            reg_write  <= R_Type OR LW OR ADDI;

            if_flush   <= BEQ or BNE;

            if r_type = '1' and reg_rd /= "UUUUU" then
                rd_ex  <= reg_rd;
            elsif reg_rd /= "UUUUU" then
                rd_ex  <= reg_rt;
            else
                rd_ex  <= "00000";
            end if;
            state <= '0';
        end if;
    end if;
end if;
end process;
END behavior;
