LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ADDER IS
    PORT ( A      : in std_logic_vector(9 downto 0);
	   B      : in std_logic_vector(9 downto 0);
	   result : out std_logic_vector(9 downto 0));
END ADDER;

ARCHITECTURE behavior of  ADDER is

BEGIN

PROCESS(A, B)

    VARIABLE result_unsigned : unsigned(10 downto 0); -- Set to 11 bits instead of 10 in order to handle end-case overflow

BEGIN
	-- ADD YO!
    result_unsigned  := "00000000000" + unsigned(signed(A) + signed(B));
    result         <= std_logic_vector(result_unsigned(9 downto 0));
	
END PROCESS;


end behavior;