library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- -- ST_SPHS_48x64_mem2011
--words = 48
--bits  = 64

entity Mem48x64 is
  port (
    ClkxCI  : in  std_logic;
    CSxSI   : in  std_logic;            -- Active Low
    WExSI   : in  std_logic;            --Active Low
    AddrxDI : in  std_logic_vector (5 downto 0);
    RYxSO   : out std_logic;
    DataxDI : in  std_logic_vector (63 downto 0);
    DataxDO : out std_logic_vector (63 downto 0)
    );
end Mem48x64;


architecture rtl of Mem48x64 is
  
  component ST_SPHS_48x64m4_L
    port (
      Q       : out std_logic_vector (63 downto 0);
      RY      : out std_logic;
      CK      : in  std_logic;
      CSN     : in  std_logic;
      TBYPASS : in  std_logic;
      WEN     : in  std_logic;
      A       : in  std_logic_vector (5 downto 0);
      D       : in  std_logic_vector (63 downto 0)
      );
  end component;

  signal LOW  : std_logic;
  signal HIGH : std_logic;

begin

  LOW  <= '0';
  HIGH <= '1';

-- mem2011
  DUT_ST_SPHS_48x64_mem2011 :ST_SPHS_48x64m4_L
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

