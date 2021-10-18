
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity write_file is
    generic (
        FILE_NAME: string ;
        INPUT_WIDTH: positive
        ); 
    Port (
        clk: in std_logic;
        reset: in std_logic;
        write_file_en: in std_logic;
	end_sim      : in std_logic;
        input_sample: in std_logic_vector(INPUT_WIDTH-1 downto 0)
        );
end write_file;

architecture Behavioral of write_file is

begin

  process (clk, reset,input_sample)
     --   file test_vector_file: text is in FILE_NAME;
        file  FILE_OUT : text;
        variable file_row: line;
        variable file_status:file_open_status;
        variable input_raw: bit_vector(INPUT_WIDTH-1 downto 0);
         
    begin
     
        if (reset = '1') then
	     file_open(file_status,FILE_OUT,FILE_NAME,write_mode);
      	     --file_close(FILE_OUT);
             --file_open(file_status,FILE_OUT,FILE_NAME,append_mode);
            input_raw := (others => '0');  
        elsif rising_edge(clk) then
            input_raw := to_bitvector(input_sample);
	  
            if  write_file_en='1' then
		write(file_row, input_raw);  
                writeline(FILE_OUT, file_row);
                              
            end if;
	    if(end_sim = '1') then
             file_close(FILE_OUT);
	     end if;
        end if;
    end process;

end Behavioral;
