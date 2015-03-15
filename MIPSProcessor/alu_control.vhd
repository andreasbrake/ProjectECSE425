LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU_control IS
  PORT (
    ALUOp   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    funct : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
    clock, reset : IN STD_LOGIC;

    in1, in2   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- ADDED LATER

    --ALUopcode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
    ALU_result : OUT STD_LOGIC_VECTOR(31 downto 0);
    zero : OUT STD_LOGIC);
END ALU_control;

architecture behavior OF ALU_control IS
BEGIN

  PROCESS(funct, ALUOp, clock, reset, in1, in2)
  
	VARIABLE ALUopcode : unsigned(2 downto 0);
  	VARIABLE in1_unsigned : UNSIGNED(31 DOWNTO 0);
       VARIABLE in2_unsigned : UNSIGNED(31 DOWNTO 0);
       VARIABLE result_unsigned : UNSIGNED(31 DOWNTO 0);
       VARIABLE zero_unsigned : UNSIGNED(0 DOWNTO 0);
       
  BEGIN
    if reset = '1' then
      ALUopcode := "000";
      in1_unsigned := (OTHERS => '0');
      in2_unsigned := (OTHERS => '0');
      result_unsigned := (OTHERS => '0');
      zero_unsigned(0) := '0';  
    elsif clock = '1' and clock'event then
      case ALUOp is
        when "00" => ALUopcode := "010"; -- ADD
        when "01" => ALUopcode := "110"; -- SUB
        when "10" =>
            case funct(5 downto 0) is
                when "100000" => ALUopcode := "010"; -- ADD
                when "100010" => ALUopcode := "110"; -- SUB
                when "100100" => ALUopcode := "000"; -- AND
                when "100101"  => ALUopcode := "001";  -- OR
                when "101010" => ALUopcode := "111";  -- SLT
                when others => ALUopcode := "000";
            end case;
        when others => ALUopcode := "000";
     end case;

   in1_unsigned := UNSIGNED(in1);
           in2_unsigned := UNSIGNED(in2);
           result_unsigned := (OTHERS => '0');
           zero_unsigned(0) := '0';
           
           CASE ALUopcode IS
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

	ALU_result <= STD_LOGIC_VECTOR(result_unsigned);
       zero <= zero_unsigned(0);

    
    end if;
  END PROCESS;
END behavior;
