----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/05/05 14:28:57
-- Design Name: 
-- Module Name: fc_counter - Behavioral
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
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fc_counter is
  generic(INPUT_SIZE:integer:=128
           );
  Port (
        clk         : in std_logic;
        reset       : in std_logic;
        fc_en       : in std_logic;
        fc_done     : out std_logic
         );
end fc_counter;

architecture Behavioral of fc_counter is
--type state_type is (idle, count);
constant counter_length: integer:=integer(log2(real(INPUT_SIZE)));
--signal current_state, next_state: state_type;
signal counter_fc_next, counter_fc: std_logic_vector(counter_length downto 0);

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
--    process(clk,reset)
--    begin
--        if rising_edge(clk) then
--            if reset='1' then
--                current_state<=idle;
--            else 
--                current_state<=next_state;
--            end if;
--        end if;
--    end process;
    
--      process(current_state,fc_en)
--    begin
--        next_state<=current_state;
--        case current_state is 
--            when idle=>
--                if fc_en='1' then
--                    next_state<=count;
--                else
--                    next_state<=idle;
--                end if;
--            when count=>
--                    next_state<=idle;                   
--         end case;
--     end process;

--counter_fc_next<=std_logic_vector(unsigned(counter_fc)+1) when current_state=count else
counter_fc_next<=std_logic_vector(unsigned(counter_fc)+1) when fc_en='1' else
                 (others=>'0') when counter_fc=std_logic_vector(to_unsigned(INPUT_SIZE,counter_length+1)) else
                 counter_fc;
fc_done<='1' when counter_fc=std_logic_vector(to_unsigned(INPUT_SIZE,counter_length+1)) else
         '0'; 
       
--counters
count_fc_ff : FF
  generic map(N => counter_length+1)
  port map(
          D  => counter_fc_next,
          Q  => counter_fc,
          clk => clk,
          reset => reset
          );
end Behavioral;
