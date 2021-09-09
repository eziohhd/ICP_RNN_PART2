----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/04/15 19:05:57
-- Design Name: 
-- Module Name: counter - Behavioral
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter_gate is
  generic(INPUT_SIZE:integer:=256;
          SIZE_HOR  :integer:=384
           );
  Port (
        clk         : in std_logic;
        reset       : in std_logic;
        GRU_en       : in std_logic;
        input_done_g  : out std_logic;
        h_prev_done_g : out std_logic;
        op_done_g     : out std_logic;
        count_hor_g   : out std_logic_vector(5 downto 0);
        count_ver_g   : out std_logic_vector(6 downto 0)
         );
end counter_gate;

architecture Behavioral of counter_gate is
------------------signals-------------------------------------------------
type state_type is (idle, count);
signal current_state, next_state: state_type;
signal counter_hor_g_next, counter_hor_g: std_logic_vector(5 downto 0);
signal counter_ver_g_next, counter_ver_g: std_logic_vector(6 downto 0);

component FF 
  generic(N:integer:=1);
  port(   D  :  in std_logic_vector(N-1 downto 0);
          Q  : out std_logic_vector(N-1 downto 0);
        clk  :  in std_logic;
        reset:  in std_logic
      );
end component;

begin
--state machine
    process(clk,reset)
    begin
        if rising_edge(clk) then
            if reset='1' then
                current_state<=idle;
            else 
                current_state<=next_state;
            end if;
        end if;
    end process;
    
    process(current_state,GRU_en,counter_ver_g,counter_hor_g)
    begin
        next_state<=current_state;
        case current_state is 
            when idle=>
                if GRU_en='1' then
                    next_state<=count;
                else
                    next_state<=idle;
                end if;
            when count=>
                if counter_ver_g=std_logic_vector(to_unsigned(127,7)) and counter_hor_g=std_logic_vector(to_unsigned(SIZE_HOR/8-1,6)) then
                    next_state<=idle;
                else 
                    next_state<=count;
                end if;
         end case;
     end process;

--counters
count_hor_ff : FF
  generic map(N => 6)
  port map(
          D  => counter_hor_g_next,
          Q  => counter_hor_g,
          clk => clk,
          reset => reset
          );
count_ver_ff : FF
  generic map(N => 7)
  port map(
          D  => counter_ver_g_next,
          Q  => counter_ver_g,
          clk => clk,
          reset => reset
          );
-- next-state logic
counter_hor_g_next<= (others=>'0') when counter_hor_g=std_logic_vector(to_unsigned(SIZE_HOR/8-1,6)) or current_state=idle  else
                   counter_hor_g+1 when current_state=count else
                   counter_hor_g;-- 0 to 48
                   
counter_ver_g_next<= counter_ver_g+1 when counter_hor_g=std_logic_vector(to_unsigned(SIZE_HOR/8-1,6)) else --0 to 127
                 (others=>'0') when current_state=idle     else
                   counter_ver_g;
                 
-- output logic
input_done_g<= '1' when  counter_hor_g=std_logic_vector(to_unsigned(INPUT_SIZE/8-1,6)) else--counter_hor = 32
             '0';
h_prev_done_g<= '1' when  counter_hor_g=std_logic_vector(to_unsigned(SIZE_HOR/8-1,6)) else--counter_hor = 48
              '0';
op_done_g<= '1' when  counter_ver_g=std_logic_vector(to_unsigned(127,7)) and counter_hor_g=std_logic_vector(to_unsigned(SIZE_HOR/8-1,6)) else
          '0';
count_hor_g<=counter_hor_g;
count_ver_g<=counter_ver_g;
end Behavioral;

