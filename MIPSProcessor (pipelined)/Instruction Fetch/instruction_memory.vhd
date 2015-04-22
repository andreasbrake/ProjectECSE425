library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; 

ENTITY instruction_memory IS
  PORT(instruction : OUT STD_LOGIC_VECTOR(31 downto 0);
       PC          : IN STD_LOGIC_VECTOR(9 downto 0);
       clock       : IN std_logic;
       init        : IN std_logic);
END instruction_memory;

ARCHITECTURE main OF instruction_memory is

SIGNAL PC_int : integer;
SIGNAL mem_read_latched: std_logic;
SIGNAL mem_data: std_logic_vector(31 downto 0);
SIGNAL rd_ready: std_logic;
SIGNAL mem_state: std_logic;

COMPONENT main_memory
    generic (
        Mem_Size_in_Word   : integer := 256;	
        Num_Bytes_in_Word  : integer := 4;
        Num_Bits_in_Byte   : integer := 8;
        Read_Delay         : integer := 1);
    port (
        clk                : in std_logic;
        address            : in integer;
        Word_Byte          : in std_logic; -- when '1' you are interacting with the memory in word otherwise in byte
        re                 : in std_logic;
        we                 : in std_logic;
        rd_ready           : out std_logic; --indicates that the read data is ready at the output.
        data               : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);        
        initialize         : in std_logic;
        dump               : in std_logic);			
END COMPONENT;

BEGIN

PC_int <= to_integer(unsigned(PC));

mem: main_memory
    generic MAP (
        Mem_Size_in_Word  => 1024
    )
    port MAP (
        clk         => clock,
        address     => PC_int,
        Word_Byte   => '1', -- when '1' you are interacting with the memory in word otherwise in byte

        re          => '1', -- ALWAYS READ, ITS THE JOB!
        we          => '0',
        data        => mem_data,       
        initialize  => init,
        dump        => '1',
			
        rd_ready    => rd_ready --indicates that the read data is ready at the output.	
    );
    
-- State dependent process
process(init, mem_state, rd_ready)
begin
    if init = '1' then
        -- INITIALIZE
        mem_state <= '0';
        mem_data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
    elsif mem_state = '0' then
        mem_state <= '1';
        -- SET DATA TO 'Z's WHEN NOT IN USE
        mem_data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
    elsif mem_state = '1' then
        if rd_ready = '1' and rd_ready'event then
            instruction <= mem_data;
            mem_read_latched <= '0';
            mem_state <= '0';
        end if;
    end if;
end process;

end main;


  