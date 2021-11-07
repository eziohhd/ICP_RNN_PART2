----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/05/20 16:59:03
-- Design Name: 
-- Module Name: sigmoid_fc - Behavioral
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

entity sigmoid_fc is
--  generic(SIG_WL:integer:=16;
--          SIG_FL:integer:=6
--          );
  Port (clk  : in std_logic; 
        reset: in std_logic;
        result_valid : in std_logic;
        fc_in       : in std_logic_vector(15 downto 0);
        result       : out std_logic_vector(15 downto 0);
        fc_out       : out std_logic_vector(15 downto 0);
        final_result : out std_logic
          );
end sigmoid_fc;

architecture Behavioral of sigmoid_fc is
type state_type is (idle,store_fc, sig_fc);
signal current_state, next_state: state_type;
signal fc_in_current,fc_in_next : std_logic_vector(15 downto 0);
begin

--state machine
    process(clk,reset)
    begin
        if rising_edge(clk) then
            if reset='1' then
                current_state<=idle;
                fc_in_current <= (others => '0');
            else 
                current_state<=next_state;
                fc_in_current <= fc_in_next;
            end if;
        end if;
    end process;
    
     process(current_state,result_valid,fc_in)
    begin
        result<=(others=>'0');
        fc_in_next <= fc_in_current;
        next_state<=current_state;
        case current_state is 
            when idle=>
                fc_in_next <= fc_in;
                if result_valid='1' then
                    next_state<=store_fc;
                else
                    next_state<=idle;
                end if;
            when store_fc=>
                fc_in_next <= fc_in;
                next_state<=sig_fc;
            when sig_fc=>
            if signed(fc_in)<shift_left(to_signed(-5,16),5) then
                    result<=(others=>'0');
                else if signed(fc_in)>shift_left(to_signed(5,16),5) then
                        result<=std_logic_vector(shift_left(to_signed(1,16),6)); 
                     else 
                        result<=std_logic_vector(resize(shift_right(signed(fc_in)*to_signed(13,16)+shift_left(to_signed(1,16),11),6),16));
                     end if;
                end if;
          end case;
       end process;      
final_result<='1' when current_state=sig_fc else
              '0';                      
fc_out <= fc_in_current;           

--result<= (others=>'0') when result_valid='0' else
--         (others=>'0') when signed(fc_in)<shift_left(to_signed(-5,16),5) else
--         std_logic_vector(shift_left(to_signed(1,16),6)) when   signed(fc_in)>shift_left(to_signed(5,16),5)  else     
--         std_logic_vector(resize(shift_right(signed(fc_in)*to_signed(13,16)+shift_left(to_signed(1,16),11),6),16));  
end Behavioral;
