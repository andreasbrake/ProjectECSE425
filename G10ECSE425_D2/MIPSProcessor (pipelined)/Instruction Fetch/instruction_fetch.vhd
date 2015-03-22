library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY instruction_fetch IS
    PORT(
        pc_in        : IN STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
        
        stall        : IN STD_LOGIC;
        clock        : IN STD_LOGIC;
        reset        : IN STD_LOGIC;

        stall_inst   : IN STD_LOGIC_VECTOR(31 downto 0);
        pc_back      : IN STD_LOGIC_VECTOR(9 downto 0);
        pc_out       : OUT STD_LOGIC_VECTOR(9 downto 0);

        pc_plus_out  : OUT STD_LOGIC_VECTOR(9 downto 0);
        instruction  : OUT STD_LOGIC_VECTOR(31 downto 0));
END instruction_fetch;

ARCHITECTURE arch OF instruction_fetch IS

SIGNAL PC_IN_LATCHED  : std_logic_vector(9 downto 0);
SIGNAL PC_PLUS_FOUR   : std_logic_vector(10 downto 0);
SIGNAL PC_OUT_LATCHED : std_logic_vector(9 downto 0);
SIGNAL PC_PREVIOUS    : std_logic_vector(9 downto 0);
SIGNAL PC_OLDER       : std_logic_vector(9 downto 0);
SIGNAL INST_PREVIOUS  : std_logic_vector(31 downto 0);
SIGNAL INST_INTERNAL  : std_logic_vector(31 downto 0);

SIGNAL state          : std_logic;

COMPONENT instruction_memory IS
    PORT(
        instruction  : OUT STD_LOGIC_VECTOR(31 downto 0);
        PC           : IN STD_LOGIC_VECTOR(9 downto 0);
        read_in      : IN STD_LOGIC;
        clock        : IN std_logic;
        init         : IN std_logic);
END COMPONENT;

BEGIN

mem: instruction_memory
    PORT MAP(
        instruction  => INST_INTERNAL,
        PC           => PC_IN_LATCHED,
        read_in      => stall,
        clock        => clock,
        init         => reset);

-- ADD FOUR
PC_PLUS_FOUR <= (PC_IN_LATCHED + "00000000100");
PC_PLUS_OUT  <= PC_OUT_LATCHED;

process(clock, reset)
begin
    if clock = '1' and clock'event then
        if stall = '1' then -- ON A STALL, USE VALUES SENT BACK BY ID
            PC_IN_LATCHED <= pc_back;
            instruction    <= stall_inst;
        elsif reset = '1' then
            PC_IN_LATCHED <= "0000000000";
            state <= '0';
        elsif state = '0' then -- USE STATES TO GET PROPER TIMING FOR INPUTS/OUTPUTS
            PC_IN_LATCHED <= PC_IN;
            PC_OLDER <= PC_PREVIOUS;
            state <= '1';
        elsif state = '1' then
            PC_OUT_LATCHED <= PC_PLUS_FOUR(9 downto 0);
            pc_out <= PC_IN_LATCHED;
            instruction <= INST_INTERNAL;
            state <= '0';
        end if;
    end if;
end process;
END arch;
