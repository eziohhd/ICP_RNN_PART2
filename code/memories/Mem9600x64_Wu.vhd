library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- -- ST_SPHS_9600x64_mem2014
--words = 9600
--bits  = 64

entity Mem9600x64_Wu is
  port (
    ClkxCI  : in  std_logic;
    CSxSI   : in  std_logic;            -- Active Low
    WExSI   : in  std_logic;            --Active Low
    AddrxDI : in  std_logic_vector (13 downto 0);
    RYxSO   : out std_logic;
    DataxDI : in  std_logic_vector (63 downto 0);
    DataxDO : out std_logic_vector (63 downto 0)
    );
end Mem9600x64_Wu;


architecture rtl of Mem9600x64_Wu is
  

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
END COMPONENT;

  signal LOW  : std_logic;
  signal HIGH : std_logic;
  signal csn  : std_logic;
  signal wen  : std_logic_vector(0 downto 0);

begin
  csn <= not CSxSI;
  wen(0) <= not WExSI;

    DUT_ST_SPHS_9600x64_mem2014 :blk_mem_gen_0
    port map(
        addra   => AddrxDI,
        dina   => DataxDI,
        clka => ClkxCI,
        wea  => wen,
        douta => DataxDO  
    );
end rtl;
