LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL; 

ENTITY ALU IS
  PORT (
    in1, in2 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    control  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);

    result   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    zero     : OUT STD_LOGIC);
END ALU;


ARCHITECTURE behavior OF ALU IS
    SIGNAL result_temp : STD_LOGIC_VECTOR(32 downto 0) := "000000000000000000000000000000000";
    SIGNAL slt_temp : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";
BEGIN

    zero <= '1' WHEN ( result_temp (31 DOWNTO 0) = "000000000000000000000000000000000") ELSE '0';
    result <= result_temp(31 downto 0);

    PROCESS(in1, in2, control)
        BEGIN
            CASE control IS
                -- and
                WHEN "000" =>
                    result_temp <= (in1 AND in2) + "000000000000000000000000000000000";
                -- or
                WHEN "001" =>
                    result_temp <= (in1 OR in2) + "000000000000000000000000000000000";
                -- addition
                WHEN "010" =>
                    result_temp <= (in1 + "000000000000000000000000000000000" + in2) ;           
                --muliplication 
                WHEN "011" =>
                    result_temp <= (in1(15 downto 0) * in2(15 downto 0)) + "000000000000000000000000000000000";
                -- subtraction
                WHEN "110" =>
                    result_temp <= (in1 - in2) + "000000000000000000000000000000000";
                -- set on less than
                WHEN "111" =>
                    slt_temp <= in1 - in2;
                    result_temp <= "00000000000000000000000000000000" & slt_temp (31);
                WHEN OTHERS => 
                    result_temp <= "000000000000000000000000000000000";
            END CASE;
    END PROCESS;
END behavior;