----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/04/16 21:21:33
-- Design Name: 
-- Module Name: tanh_h_t - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tanh_h_t is
  generic(MED_WL:integer:=24;
          MED_FL:integer:=13
          );
  Port (
        clk  : in std_logic; 
        reset: in std_logic;
        r_u_valid: in std_logic;
        cx_in: in std_logic_vector (MED_WL-1 downto 0); 
        ch_in: in std_logic_vector (MED_WL-1 downto 0); 
        r_t  : in std_logic_vector (15 downto 0); 
        h_can: out std_logic_vector(15 downto 0)     
   );
end tanh_h_t;

architecture Behavioral of tanh_h_t is
signal ralut: std_logic_vector(9 downto 0);
signal temp_h: std_logic_vector(15 downto 0);
begin

 temp_h<=std_logic_vector(resize(shift_right(signed(cx_in)+shift_right(signed(ch_in)*signed(r_t),6),MED_FL-6),16)) when  r_u_valid='1' else
          (others=>'0');

 ralut<="0000000110" when  signed(temp_h)=to_signed(17,16) or  signed(temp_h)=to_signed(-17,16) else  --0.265625"0010001"
        "0000000111" when  signed(temp_h)=to_signed(18,16) or  signed(temp_h)=to_signed(-18,16) else  --0.28125 "0010010"
        "0000001001" when  signed(temp_h)=to_signed(19,16) or  signed(temp_h)=to_signed(-19,16) else  --        "0010011"
        "0000001010" when  signed(temp_h)=to_signed(20,16) or  signed(temp_h)=to_signed(-20,16) else  --        "0010100"
        "0000001100" when  signed(temp_h)=to_signed(21,16) or  signed(temp_h)=to_signed(-21,16) else  --        "0010101"
        "0000001101" when  signed(temp_h)=to_signed(22,16) or  signed(temp_h)=to_signed(-22,16) else  --        "0010110"
        "0000001111" when  signed(temp_h)=to_signed(23,16) or  signed(temp_h)=to_signed(-23,16) else  --        "0010111"
        "0000010001" when  signed(temp_h)=to_signed(24,16) or  signed(temp_h)=to_signed(-24,16) else  --        "0011000"
        "0000010011" when  signed(temp_h)=to_signed(25,16) or  signed(temp_h)=to_signed(-25,16) else  --        "0011001"
        "0000010101" when  signed(temp_h)=to_signed(26,16) or  signed(temp_h)=to_signed(-26,16) else  --        "0011010"
        "0000011000" when  signed(temp_h)=to_signed(27,16) or  signed(temp_h)=to_signed(-27,16) else  --        "0011011"
        "0000011011" when  signed(temp_h)=to_signed(28,16) or  signed(temp_h)=to_signed(-28,16) else  --        "0011100"
        "0000011101" when  signed(temp_h)=to_signed(29,16) or  signed(temp_h)=to_signed(-29,16) else  --        "0011101"
        "0000100000" when  signed(temp_h)=to_signed(30,16) or  signed(temp_h)=to_signed(-30,16) else  --        "0011110"
        "0000100011" when  signed(temp_h)=to_signed(31,16) or  signed(temp_h)=to_signed(-31,16) else  --        "0011111"
        "0000100111" when  signed(temp_h)=to_signed(32,16) or  signed(temp_h)=to_signed(-32,16) else  --        "0100000"
        "0000101010" when  signed(temp_h)=to_signed(33,16) or  signed(temp_h)=to_signed(-33,16) else  --        "0100001"
        "0000101110" when  signed(temp_h)=to_signed(34,16) or  signed(temp_h)=to_signed(-34,16) else  --        "0100010"
        "0000110010" when  signed(temp_h)=to_signed(35,16) or  signed(temp_h)=to_signed(-35,16) else  --        "0100011"
        "0000110110" when  signed(temp_h)=to_signed(36,16) or  signed(temp_h)=to_signed(-36,16) else  --        "0100100"
        "0000111010" when  signed(temp_h)=to_signed(37,16) or  signed(temp_h)=to_signed(-37,16) else  --        "0100101"
        "0000111111" when  signed(temp_h)=to_signed(38,16) or  signed(temp_h)=to_signed(-38,16) else  --        "0100110"
        "0001000011" when  signed(temp_h)=to_signed(39,16) or  signed(temp_h)=to_signed(-39,16) else  --        "0100111"
        "0001001000" when  signed(temp_h)=to_signed(40,16) or  signed(temp_h)=to_signed(-40,16) else  --        "0101000"
        "0001001101" when  signed(temp_h)=to_signed(41,16) or  signed(temp_h)=to_signed(-41,16) else  --        "0101001"
        "0001010010" when  signed(temp_h)=to_signed(42,16) or  signed(temp_h)=to_signed(-42,16) else  --        "0101010"
        "0001011000" when  signed(temp_h)=to_signed(43,16) or  signed(temp_h)=to_signed(-43,16) else  --        "0101011"
        "0001011101" when  signed(temp_h)=to_signed(44,16) or  signed(temp_h)=to_signed(-44,16) else  --        "0101100"
        "0001100011" when  signed(temp_h)=to_signed(45,16) or  signed(temp_h)=to_signed(-45,16) else  --        "0101101"
        "0001101001" when  signed(temp_h)=to_signed(46,16) or  signed(temp_h)=to_signed(-46,16) else  --        "0101110"
        "0001101111" when  signed(temp_h)=to_signed(47,16) or  signed(temp_h)=to_signed(-47,16) else  --        "0101111"
        "0001110110" when  signed(temp_h)=to_signed(48,16) or  signed(temp_h)=to_signed(-48,16) else  --        "0110000"
        "0001111100" when  signed(temp_h)=to_signed(49,16) or  signed(temp_h)=to_signed(-49,16) else  --        "0110001"
        "0010000011" when  signed(temp_h)=to_signed(50,16) or  signed(temp_h)=to_signed(-50,16) else  --        "0110010"
        "0010001010" when  signed(temp_h)=to_signed(51,16) or  signed(temp_h)=to_signed(-51,16) else  --        "0110011"
        "0010010001" when  signed(temp_h)=to_signed(52,16) or  signed(temp_h)=to_signed(-52,16) else  --        "0110100"
        "0010011000" when  signed(temp_h)=to_signed(53,16) or  signed(temp_h)=to_signed(-53,16) else  --        "0110101"
        "0010100000" when  signed(temp_h)=to_signed(54,16) or  signed(temp_h)=to_signed(-54,16) else  --        "0110110"
        "0010100111" when  signed(temp_h)=to_signed(55,16) or  signed(temp_h)=to_signed(-55,16) else  --        "0110111"
        "0010101111" when  signed(temp_h)=to_signed(56,16) or  signed(temp_h)=to_signed(-56,16) else  --        "0111000"
        "0010110111" when  signed(temp_h)=to_signed(57,16) or  signed(temp_h)=to_signed(-57,16) else  --        "0111001"
        "0010111111" when  signed(temp_h)=to_signed(58,16) or  signed(temp_h)=to_signed(-58,16) else  --        "0111010"
        "0011001000" when  signed(temp_h)=to_signed(59,16) or  signed(temp_h)=to_signed(-59,16) else  --        "0111011"
        "0011010000" when  signed(temp_h)=to_signed(60,16) or  signed(temp_h)=to_signed(-60,16) else  --        "0111100"
        "0011011001" when  signed(temp_h)=to_signed(61,16) or  signed(temp_h)=to_signed(-61,16) else  --        "0111101"
        "0011100010" when  signed(temp_h)=to_signed(62,16) or  signed(temp_h)=to_signed(-62,16) else  --        "0111110"
        "0011101011" when  signed(temp_h)=to_signed(63,16) or  signed(temp_h)=to_signed(-63,16) else  --        "0111111"
        "0011110100" when  signed(temp_h)=to_signed(64,16) or  signed(temp_h)=to_signed(-64,16) else  --1       "1000000"     
        "0011101101" when  signed(temp_h)=to_signed(65,16) or  signed(temp_h)=to_signed(-65,16) else
        "0011100111" when  signed(temp_h)=to_signed(66,16) or  signed(temp_h)=to_signed(-66,16) else
        "0011100001" when  signed(temp_h)=to_signed(67,16) or  signed(temp_h)=to_signed(-67,16) else
        "0011011011" when  signed(temp_h)=to_signed(68,16) or  signed(temp_h)=to_signed(-68,16) else
        "0011010100" when  signed(temp_h)=to_signed(69,16) or  signed(temp_h)=to_signed(-69,16) else
        "0011001111" when  signed(temp_h)=to_signed(70,16) or  signed(temp_h)=to_signed(-70,16) else
        "0011001001" when  signed(temp_h)=to_signed(71,16) or  signed(temp_h)=to_signed(-71,16) else
        "0011000011" when  signed(temp_h)=to_signed(72,16) or  signed(temp_h)=to_signed(-72,16) else
        "0010111110" when  signed(temp_h)=to_signed(73,16) or  signed(temp_h)=to_signed(-73,16) else
        "0010111001" when  signed(temp_h)=to_signed(74,16) or  signed(temp_h)=to_signed(-74,16) else
        "0010110011" when  signed(temp_h)=to_signed(75,16) or  signed(temp_h)=to_signed(-75,16) else
        "0010101110" when  signed(temp_h)=to_signed(76,16) or  signed(temp_h)=to_signed(-76,16) else
        "0010101001" when  signed(temp_h)=to_signed(77,16) or  signed(temp_h)=to_signed(-77,16) else
        "0010100101" when  signed(temp_h)=to_signed(78,16) or  signed(temp_h)=to_signed(-78,16) else
        "0010100000" when  signed(temp_h)=to_signed(79,16) or  signed(temp_h)=to_signed(-79,16) else
        "0010011011" when  signed(temp_h)=to_signed(80,16) or  signed(temp_h)=to_signed(-80,16) else
        "0010010111" when  signed(temp_h)=to_signed(81,16) or  signed(temp_h)=to_signed(-81,16) else
        "0010010011" when  signed(temp_h)=to_signed(82,16) or  signed(temp_h)=to_signed(-82,16) else
        "0010001110" when  signed(temp_h)=to_signed(83,16) or  signed(temp_h)=to_signed(-83,16) else
        "0010001010" when  signed(temp_h)=to_signed(84,16) or  signed(temp_h)=to_signed(-84,16) else
        "0010000110" when  signed(temp_h)=to_signed(85,16) or  signed(temp_h)=to_signed(-85,16) else
        "0010000010" when  signed(temp_h)=to_signed(86,16) or  signed(temp_h)=to_signed(-86,16) else
        "0001111111" when  signed(temp_h)=to_signed(87,16) or  signed(temp_h)=to_signed(-87,16) else
        "0001111011" when  signed(temp_h)=to_signed(88,16) or  signed(temp_h)=to_signed(-88,16) else
        "0001110111" when  signed(temp_h)=to_signed(89,16) or  signed(temp_h)=to_signed(-89,16) else
        "0001110100" when  signed(temp_h)=to_signed(90,16) or  signed(temp_h)=to_signed(-90,16) else
        "0001110001" when  signed(temp_h)=to_signed(91,16) or  signed(temp_h)=to_signed(-91,16) else
        "0001101101" when  signed(temp_h)=to_signed(92,16) or  signed(temp_h)=to_signed(-92,16) else
        "0001101010" when  signed(temp_h)=to_signed(93,16) or  signed(temp_h)=to_signed(-93,16) else
        "0001100111" when  signed(temp_h)=to_signed(94,16) or  signed(temp_h)=to_signed(-94,16) else
        "0001100100" when  signed(temp_h)=to_signed(95,16) or  signed(temp_h)=to_signed(-95,16) else
        "0001100001" when  signed(temp_h)=to_signed(96,16) or  signed(temp_h)=to_signed(-96,16) else
        "0001011110" when  signed(temp_h)=to_signed(97,16) or  signed(temp_h)=to_signed(-97,16) else
        "0001011100" when  signed(temp_h)=to_signed(98,16) or  signed(temp_h)=to_signed(-98,16) else
        "0001011001" when  signed(temp_h)=to_signed(99,16) or  signed(temp_h)=to_signed(-99,16) else
        "0001010110" when  signed(temp_h)=to_signed(100,16) or signed(temp_h)=to_signed(-100,16) else
        "0001010100" when  signed(temp_h)=to_signed(101,16) or signed(temp_h)=to_signed(-101,16) else
        "0001010001" when  signed(temp_h)=to_signed(102,16) or signed(temp_h)=to_signed(-102,16) else
        "0001001111" when  signed(temp_h)=to_signed(103,16) or signed(temp_h)=to_signed(-103,16) else
        "0001001100" when  signed(temp_h)=to_signed(104,16) or signed(temp_h)=to_signed(-104,16) else
        "0001001010" when  signed(temp_h)=to_signed(105,16) or signed(temp_h)=to_signed(-105,16) else
        "0001001000" when  signed(temp_h)=to_signed(106,16) or signed(temp_h)=to_signed(-106,16) else
        "0001000110" when  signed(temp_h)=to_signed(107,16) or signed(temp_h)=to_signed(-107,16) else
        "0001000100" when  signed(temp_h)=to_signed(108,16) or signed(temp_h)=to_signed(-108,16) else
        "0001000010" when  signed(temp_h)=to_signed(109,16) or signed(temp_h)=to_signed(-109,16) else
        "0001000000" when  signed(temp_h)=to_signed(110,16) or signed(temp_h)=to_signed(-110,16) else
        "0000111110" when  signed(temp_h)=to_signed(111,16) or signed(temp_h)=to_signed(-111,16) else
        "0000111100" when  signed(temp_h)=to_signed(112,16) or signed(temp_h)=to_signed(-112,16) else
        "0000111010" when  signed(temp_h)=to_signed(113,16) or signed(temp_h)=to_signed(-113,16) else
        "0000111000" when  signed(temp_h)=to_signed(114,16) or signed(temp_h)=to_signed(-114,16) else
        "0000110111" when  signed(temp_h)=to_signed(115,16) or signed(temp_h)=to_signed(-115,16) else
        "0000110101" when  signed(temp_h)=to_signed(116,16) or signed(temp_h)=to_signed(-116,16) else
        "0000110100" when  signed(temp_h)=to_signed(117,16) or signed(temp_h)=to_signed(-117,16) else
        "0000110010" when  signed(temp_h)=to_signed(118,16) or signed(temp_h)=to_signed(-118,16) else
        "0000110001" when  signed(temp_h)=to_signed(119,16) or signed(temp_h)=to_signed(-119,16) else
        "0000101111" when  signed(temp_h)=to_signed(120,16) or signed(temp_h)=to_signed(-120,16) else
        "0000101110" when  signed(temp_h)=to_signed(121,16) or signed(temp_h)=to_signed(-121,16) else
        "0000101100" when  signed(temp_h)=to_signed(122,16) or signed(temp_h)=to_signed(-122,16) else
        "0000101011" when  signed(temp_h)=to_signed(123,16) or signed(temp_h)=to_signed(-123,16) else
        "0000101010" when  signed(temp_h)=to_signed(124,16) or signed(temp_h)=to_signed(-124,16) else
        "0000101000" when  signed(temp_h)=to_signed(125,16) or signed(temp_h)=to_signed(-125,16) else
        "0000100111" when  signed(temp_h)=to_signed(126,16) or signed(temp_h)=to_signed(-126,16) else
        "0000100110" when  signed(temp_h)=to_signed(127,16) or signed(temp_h)=to_signed(-127,16) else
        "0000100101" when  signed(temp_h)=to_signed(128,16) or signed(temp_h)=to_signed(-128,16) else
        "0000100100" when  signed(temp_h)=to_signed(129,16) or signed(temp_h)=to_signed(-129,16) else
        "0000100011" when  signed(temp_h)=to_signed(130,16) or signed(temp_h)=to_signed(-130,16) else
        "0000100010" when  signed(temp_h)=to_signed(131,16) or signed(temp_h)=to_signed(-131,16) else
        "0000100001" when  signed(temp_h)=to_signed(132,16) or signed(temp_h)=to_signed(-132,16) else
        "0000100000" when  signed(temp_h)=to_signed(133,16) or signed(temp_h)=to_signed(-133,16) else
        "0000011111" when  signed(temp_h)=to_signed(134,16) or signed(temp_h)=to_signed(-134,16) else
        "0000011110" when  signed(temp_h)=to_signed(135,16) or signed(temp_h)=to_signed(-135,16) else
        "0000011101" when  signed(temp_h)=to_signed(136,16) or signed(temp_h)=to_signed(-136,16) else
        "0000011100" when  signed(temp_h)=to_signed(137,16) or signed(temp_h)=to_signed(-137,16) else
        "0000011011" when  signed(temp_h)=to_signed(138,16) or signed(temp_h)=to_signed(-138,16) else
        "0000011010" when  signed(temp_h)=to_signed(139,16) or signed(temp_h)=to_signed(-139,16) else
        "0000011001" when  signed(temp_h)=to_signed(140,16) or signed(temp_h)=to_signed(-140,16) else
        "0000011001" when  signed(temp_h)=to_signed(141,16) or signed(temp_h)=to_signed(-141,16) else
        "0000011000" when  signed(temp_h)=to_signed(142,16) or signed(temp_h)=to_signed(-142,16) else
        "0000010111" when  signed(temp_h)=to_signed(143,16) or signed(temp_h)=to_signed(-143,16) else
        "0000010111" when  signed(temp_h)=to_signed(144,16) or signed(temp_h)=to_signed(-144,16) else
        "0000010110" when  signed(temp_h)=to_signed(145,16) or signed(temp_h)=to_signed(-145,16) else
        "0000010101" when  signed(temp_h)=to_signed(146,16) or signed(temp_h)=to_signed(-146,16) else
        (others=>'0');

--h_can<=temp_h when signed(temp_h)< to_signed(17,16) and  signed(temp_h)> to_signed(-17,16) else
       --std_logic_vector(shift_right(shift_left(signed(temp_h),4)- signed(ralut),4)) when signed(temp_h)>= to_signed(17,16) and  signed(temp_h)<=to_signed(64,16)   else 
       --std_logic_vector(shift_right(shift_left(signed(temp_h),4)+ signed(ralut),4)) when signed(temp_h)>= to_signed(-64,16) and  signed(temp_h)<=to_signed(-17,16) else 
       --std_logic_vector(shift_right(shift_left(to_signed(1,16),10)- signed(ralut),4)) when signed(temp_h)>= to_signed(64,16) and  signed(temp_h)<=to_signed(146,16)   else 
       --std_logic_vector(shift_right(shift_left(to_signed(-1,16),10)+ signed(ralut),4)) when signed(temp_h)>= to_signed(-146,16) and  signed(temp_h)<=to_signed(-64,16) else 
       --std_logic_vector(shift_left(to_signed(1,16),6));
h_can<=temp_h when signed(temp_h)< to_signed(17,16) and  signed(temp_h)> to_signed(-17,16) else
       std_logic_vector(shift_right(shift_left(signed(temp_h),4)- signed(ralut),4)) when signed(temp_h)>= to_signed(17,16) and  signed(temp_h)<to_signed(64,16)   else 
       std_logic_vector(shift_right(shift_left(signed(temp_h),4)+ signed(ralut),4)) when signed(temp_h)> to_signed(-64,16) and  signed(temp_h)<=to_signed(-17,16) else 
       std_logic_vector(shift_right(shift_left(to_signed(1,16),10)- signed(ralut),4)) when signed(temp_h)>= to_signed(64,16) and  signed(temp_h)<to_signed(146,16)   else 
       std_logic_vector(shift_right(shift_left(to_signed(-1,16),10)+ signed(ralut),4)) when signed(temp_h)> to_signed(-146,16) and  signed(temp_h)<=to_signed(-64,16) else 
       std_logic_vector(shift_left(to_signed(1,16),6)) when signed(temp_h)>=to_signed(146,16) else
       std_logic_vector(shift_left(to_signed(-1,16),6)); 
                             
end Behavioral;              
