LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--USE IEEE.numeric_std.ALL;

ENTITY ALU_control IS
  PORT (
    ALUOp   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    funct : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
    ALUopcode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END ALU_control;

architecture behavior OF ALU_control IS
BEGIN

  alucontrol : PROCESS(funct, ALUOp)
       
  BEGIN
     case ALUOp is
        when "00" => ALUopcode <= "010"; -- ADD
        when "01" => ALUopcode <= "110"; -- SUB
        when "10" =>
            case funct(5 downto 0) is
                when "100000" => ALUopcode <= "010"; -- ADD
                when "100010" => ALUopcode <= "110"; -- SUB
                when "100100" => ALUopcode <= "000"; -- AND
                when "100101"  => ALUopcode <= "001";  -- OR
                when "101010" => ALUopcode <= "111";  --SLT
                when others => ALUopcode <= "000";
            end case;
        when others => ALUopcode <= "000";
     end case;
  END PROCESS;
END behavior;
