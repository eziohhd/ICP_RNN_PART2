library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input_gen is
    generic (
        FILE_NAME: string ;
        INPUT_WIDTH: positive
        ); 
    Port (
        clk: in std_logic;
        reset: in std_logic;
        input_write_en: in std_logic;
        input_sample: out std_logic_vector(INPUT_WIDTH-1 downto 0)
        );
end input_gen;

architecture Behavioral of input_gen is

begin

  process (clk, reset)
        file test_vector_file: text is in FILE_NAME;
        variable file_row: line;
        variable input_raw: bit_vector(INPUT_WIDTH-1 downto 0);
    begin
        if (reset = '1') then
            input_sample <= (others => '0');  
        elsif rising_edge(clk) then
           -- input_raw := 0;
            if not endfile(test_vector_file) and input_write_en='1' then
                readline(test_vector_file, file_row);
                read(file_row, input_raw);                
            end if;
            input_sample <=to_stdlogicvector(input_raw);
        end if;
    end process;

end Behavioral;
