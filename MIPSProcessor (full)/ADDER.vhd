LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity ADDER is

  port ( A: in std_logic_vector(9 downto 0);
	 --B: in std_logic_vector(9 downto 0);
	 B: in std_logic_vector(31 downto 0);
    	 clock, reset : IN STD_LOGIC;
	 result: out std_logic_vector(9 downto 0));
         
end ADDER;


architecture behavior of  ADDER is

	--signal B_shortened : std_logic_vector(7 downto 0);
	--signal B_shifted : std_logic_vector(9 downto 0);
BEGIN

    PROCESS(A, B, clock, reset)

	VARIABLE result_unsigned : unsigned(9 downto 0);
	VARIABLE A_unsigned : unsigned(9 downto 0);
	VARIABLE B_unsigned : unsigned(9 downto 0);
	VARIABLE B_shortened : unsigned(7 downto 0);
	VARIABLE B_shifted : unsigned(9 downto 0);

	BEGIN
	
	  

	if reset = '1' then
	  A_unsigned := (OTHERS => '0');
	  B_unsigned := (OTHERS => '0');
	  result_unsigned := (OTHERS => '0');
	 -- B_shortened <= (OTHERS => '0');
	 -- B_shifted <= (OTHERS => '0');
	  B_shortened := (OTHERS => '0');
	  B_shifted := (OTHERS => '0');

	elsif clock = '1' and clock'event then

	--B_shortened <= B(7 downto 0);
  	--B_shifted (9 downto 2) <= B_shortened;
  	--B_shifted (1 downto 0) <= "00";

	B_shortened := unsigned(B(7 downto 0));
  	B_shifted (9 downto 2) := B_shortened;
  	B_shifted (1 downto 0) := "00";
	
	A_unsigned := unsigned(A);
	--B_unsigned := unsigned(B_shifted);
	
	--result_unsigned := A_unsigned + B_unsigned;
	result_unsigned := A_unsigned + B_shifted;
	
	
	end if;
	
	result <= std_logic_vector(result_unsigned);
	
  END process;


end behavior;