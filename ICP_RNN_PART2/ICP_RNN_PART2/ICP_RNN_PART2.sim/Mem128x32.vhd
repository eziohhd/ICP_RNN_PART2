library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- -- ST_SPHDL_128x32_mem2010
--words = 128
--bits  = 32

entity Mem128x32 is
  port (
    ClkxCI  : in  std_logic;
    CSxSI   : in  std_logic;            -- Active Low
    WExSI   : in  std_logic;            --Active Low
    AddrxDI : in  std_logic_vector (6 downto 0);
    RYxSO   : out std_logic;
    DataxDI : in  std_logic_vector (31 downto 0);
    DataxDO : out std_logic_vector (31 downto 0)
    );
end Mem128x32;


architecture rtl of Mem128x32 is
  
  component ST_SPHDL_128x32m8_L
    port (
      Q       : out std_logic_vector (31 downto 0);
      RY      : out std_logic;
      CK      : in  std_logic;
      CSN     : in  std_logic;
      TBYPASS : in  std_logic;
      WEN     : in  std_logic;
      A       : in  std_logic_vector (6 downto 0);
      D       : in  std_logic_vector (31 downto 0)
      );
  end component;

  signal LOW  : std_logic;
  signal HIGH : std_logic;

begin

  LOW  <= '0';
  HIGH <= '1';

-- mem2011
  DUT_ST_SPHDL_128x32_mem2010 : ST_SPHDL_128x32m8_L
    port map(
      Q       => DataxDO,
      RY      => RYxSO,
      CK      => ClkxCI,
      CSN     => CSxSI,
      TBYPASS => LOW,
      WEN     => WExSI,
      A       => AddrxDI,
      D       => DataxDI
      );

end rtl;


