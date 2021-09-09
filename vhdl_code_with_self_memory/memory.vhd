
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ram IS
  GENERIC(
    d_width  : INTEGER := 8;    --width of each data word
    size     : INTEGER := 64);  --number of data words the memory can store
  PORT(
    clk      : IN   STD_LOGIC;                             --system clock
    wrn_ena  : IN   STD_LOGIC;                             --write enable negative
    addr     : IN   INTEGER RANGE 0 TO size-1;             --address to write/read
    data_in  : IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --input data to write
    data_out : OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)); --output data read
END ram;

ARCHITECTURE logic OF ram IS
  TYPE memory IS ARRAY(size-1 DOWNTO 0) OF STD_LOGIC_VECTOR(d_width-1 DOWNTO 0); --data type for memory
  signal data_out_temp : STD_LOGIC_VECTOR(d_width-1 DOWNTO 0); 
  SIGNAL ram      : memory;   
  signal ram_next : memory;                                                   --memory array
 -- SIGNAL addr_int : INTEGER RANGE 0 TO size-1:=0;                                   --internal address register
BEGIN

  PROCESS(clk)
  BEGIN
    if rising_edge(clk) then  
       data_out <= data_out_temp;
       ram<=ram_next;
    end if;
  end process;
  process(clk)
  begin
     if rising_edge(clk) then
      if (wrn_ena = '0') then
          ram_next(addr) <= data_in;
      else
          ram_next <= ram;
          
      end if;  
     end if;
  end process;
  data_out_temp <= ram(addr);
END logic;

