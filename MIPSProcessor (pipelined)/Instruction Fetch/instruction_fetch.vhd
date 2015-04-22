library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY instruction_fetch IS
    PORT(
        pc_in        : IN STD_LOGIC_VECTOR(9 downto 0);
        
        stall        : IN STD_LOGIC;
        clock        : IN STD_LOGIC;
        reset        : IN STD_LOGIC;

        branch       : IN STD_LOGIC;
        pc_out       : OUT STD_LOGIC_VECTOR(9 downto 0);

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
        clock        : IN std_logic;
        init         : IN std_logic);
END COMPONENT;

BEGIN

mem: instruction_memory
    PORT MAP(
        instruction  => INST_INTERNAL,
        PC           => PC_IN_LATCHED,
        clock        => clock,
        init         => reset);

process(clock, stall, reset)
begin
    if branch = '1' or stall = '1' then -- ON A STALL, USE VALUES SENT BACK BY ID
        if stall = '1' then
            instruction   <= INST_PREVIOUS;
        end if;
	
    end if;

    if clock = '1' and clock'event then
        if reset = '1' then
            PC_IN_LATCHED <= "0000000000";
            PC_PLUS_FOUR  <= "00000000100";
            state <= '0';
        elsif state = '0' then -- USE STATES TO GET PROPER TIMING FOR INPUTS/OUTPUTS
            if branch = '1' or stall = '1' then
                
            else
                PC_IN_LATCHED <= PC_PLUS_FOUR(9 downto 0); 
                PC_PLUS_FOUR  <= (PC_PLUS_FOUR(9 downto 0) + "00000000100");
            end if;
	    
            state <= '1';
        elsif state = '1' then
            if stall = '1' then
                instruction   <= INST_PREVIOUS;
            else
                if INST_INTERNAL(0) /= 'U' then 
                    INST_PREVIOUS <= INST_INTERNAL;
                    instruction   <= INST_INTERNAL;
                else -- INST INTNERNAL CAN BE UNDEFINED AFTER BRANCH SO FLUSH RESULT
		    INST_PREVIOUS <= "00000000000000000000000000000000";
                    instruction   <= "00000000000000000000000000000000";
                end if;
            end if;
            
	    if branch = '1' or stall = '1' then
		PC_IN_LATCHED <= PC_IN;
                PC_PLUS_FOUR  <= (PC_IN + "00000000100");
                if branch = '1' then
                    INST_PREVIOUS <= "00000000000000000000000000000000";
                    instruction   <= "00000000000000000000000000000000";
                end if;
            end if;
            pc_out <= PC_IN_LATCHED;
            state <= '0';
        end if;

        
    end if;
end process;
END arch;
