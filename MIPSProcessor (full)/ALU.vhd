LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
  PORT (
    in1, in2   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    opcode : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    clock, reset : IN STD_LOGIC;
    result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    zero   : OUT STD_LOGIC);
END ALU;


ARCHITECTURE behavior OF ALU IS
BEGIN
   PROCESS(in1, in2, opcode, clock, reset)
       
       VARIABLE in1_unsigned : UNSIGNED(31 DOWNTO 0);
       VARIABLE in2_unsigned : UNSIGNED(31 DOWNTO 0);
       VARIABLE result_unsigned : UNSIGNED(31 DOWNTO 0);
       VARIABLE zero_unsigned : UNSIGNED(0 DOWNTO 0);
       BEGIN
        if reset = '1' then
	   in1_unsigned := (OTHERS => '0');
           in2_unsigned := (OTHERS => '0');
           result_unsigned := (OTHERS => '0');
           zero_unsigned(0) := '0';   

	elsif clock = '1' and clock'event then
           in1_unsigned := UNSIGNED(in1);
           in2_unsigned := UNSIGNED(in2);
           result_unsigned := (OTHERS => '0');
           zero_unsigned(0) := '0';
           
           CASE opcode IS
               -- addition
               WHEN "010" =>
                  result_unsigned := in1_unsigned + in2_unsigned;
               -- subtraction
               WHEN "110" =>
                  result_unsigned := in1_unsigned - in2_unsigned;
               -- and
               WHEN "000" =>
                  result_unsigned := in1_unsigned AND in2_unsigned;
               -- or
               WHEN "001" =>
                  result_unsigned := in1_unsigned OR in2_unsigned;
               -- set on less than
               WHEN "111" =>
		  IF in1_unsigned < in2_unsigned THEN
                    result_unsigned := (0 => '1', OTHERS => '0');
                  ELSE
                    result_unsigned := (OTHERS => '0');
                  END IF;

               WHEN OTHERS => result_unsigned := (OTHERS => 'X');
           END CASE;
           
	   -- zero bit
           IF TO_INTEGER(result_unsigned) = 0 THEN
               zero_unsigned(0) := '1';
           ELSE
               zero_unsigned(0) := '0';
           END IF;
       END IF; --end clock cycle
       result <= STD_LOGIC_VECTOR(result_unsigned);
       zero <= zero_unsigned(0);
       END PROCESS;
END behavior;