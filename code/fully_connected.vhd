----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/05/05 11:10:41
-- Design Name: 
-- Module Name: fully_connected - Behavioral
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

entity fully_connected is
  generic(FC_WL:integer:=24;
          FC_FL:integer:=13;
          H_WL: integer:=16;
          H_FL: integer:=6
          );
           
  Port ( 
        clk       : in std_logic; 
        reset     : in std_logic;
        fc_en     : in std_logic; 
        fc_done   : in std_logic;
        h_t_in    : in std_logic_vector(15 downto 0);
        weight_fc_in : in std_logic_vector(31 downto 0);
        addr_fc_out: out std_logic_vector(5 downto 0);
        result_valid : out std_logic;
        fc_out    : out std_logic_vector(15 downto 0)        
        );
end fully_connected;

architecture Behavioral of fully_connected is
signal bfc :std_logic_vector(7 downto 0):= "11001001";
type state_type is (idle, wait_0,wait_00,first_fc_op, wait_1, fc_op_1,wait_2, fc_op_2,wait_3, fc_op_3, wait_4, fc_op_4);
signal current_state, next_state: state_type;
signal weight_fc_next,weight_fc : std_logic_vector(31 downto 0);
signal h_t_next,h_t : std_logic_vector(15 downto 0);
signal addr_fc,addr_fc_next : std_logic_vector(5 downto 0);
signal wfc: std_logic_vector(7 downto 0);
signal p_fc_next, p_fc: std_logic_vector(FC_WL-1 downto 0);
signal temp_fc: std_logic_vector(FC_WL-1 downto 0);
alias wfc1 is weight_fc(31 downto 24);
alias wfc2 is weight_fc(23 downto 16);
alias wfc3 is weight_fc(15 downto 8);
alias wfc4 is weight_fc(7 downto 0);
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

 process(current_state,fc_en, fc_done, p_fc,temp_fc, bfc, wfc1, wfc2, wfc3, wfc4,addr_fc,h_t_in,weight_fc_in)

    begin
        h_t_next <= h_t;
        weight_fc_next <= weight_fc;
        addr_fc_next <= addr_fc;
        temp_fc<=(others=>'0');
        wfc<=(others=>'0');
        result_valid<='0';
        next_state<=current_state;
        case current_state is 
            when idle=>
                p_fc_next<=(others=>'0');
                if fc_en='1' then
                    h_t_next <= h_t_in;
                    next_state<=wait_0;
                else
                    next_state<=idle;
                end if;
            when wait_0=>
                p_fc_next <= p_fc;
                weight_fc_next <= weight_fc_in;
                next_state<=first_fc_op;
	    when wait_00=>
	        p_fc_next <= p_fc;
                weight_fc_next <= weight_fc_in;
                next_state<=fc_op_1;
            when first_fc_op=>
           
                if bfc(7)='0' then 
                temp_fc<=std_logic_vector(to_signed(0,FC_WL-FC_FL-1)) & bfc & std_logic_vector(to_unsigned(0,FC_FL-7));
            else 
                temp_fc<=std_logic_vector(to_signed(-1,FC_WL-FC_FL-1)) & bfc & std_logic_vector(to_unsigned(0,FC_FL-7));
            end if;
                 p_fc_next <= std_logic_vector(resize(shift_right(signed(h_t)*signed(wfc),0)+signed(temp_fc),FC_WL));
                wfc<=wfc1;
                next_state<=wait_1;
            when fc_op_1=>
                temp_fc<=p_fc;
                p_fc_next <= std_logic_vector(resize(shift_right(signed(h_t)*signed(wfc),0)+signed(temp_fc),FC_WL));
                wfc<=wfc1;
                next_state<=wait_1;           
            when wait_1=>
                p_fc_next <= p_fc;
                if fc_en='1' then
                    h_t_next <= h_t_in;
                    next_state<=fc_op_2;
                else
                    next_state<=wait_1;
                end if;
            when fc_op_2=>
                temp_fc<=p_fc;
                p_fc_next <= std_logic_vector(resize(shift_right(signed(h_t)*signed(wfc),0)+signed(temp_fc),FC_WL));
                wfc<=wfc2;
                next_state<=wait_2;
            when wait_2=>
                p_fc_next <= p_fc;
                if fc_en='1' then
                    h_t_next <= h_t_in;
                    next_state<=fc_op_3;
                else
                    next_state<=wait_2;
                end if;
            when fc_op_3=>
                temp_fc<=p_fc;
                p_fc_next <= std_logic_vector(resize(shift_right(signed(h_t)*signed(wfc),0)+signed(temp_fc),FC_WL));
                wfc<=wfc3;
                next_state<=wait_3;
            when wait_3=>
                p_fc_next <= p_fc;
                if fc_en='1' then
                    h_t_next <= h_t_in;
                    next_state<=fc_op_4;
                else
                    next_state<=wait_3;
                end if;
            when fc_op_4=>

                temp_fc<=p_fc;
                p_fc_next <= std_logic_vector(resize(shift_right(signed(h_t)*signed(wfc),0)+signed(temp_fc),FC_WL));
                wfc<=wfc4;
                if fc_done='1' then
                    result_valid<='1';
                    next_state<=idle;
                else
                    next_state<=wait_4;
                    addr_fc_next <= std_logic_vector(unsigned(addr_fc )+ 1);
                end if;
             when wait_4=>
                p_fc_next <= p_fc;
                if fc_en='1' then
                    h_t_next <= h_t_in;
                    next_state<=wait_00;    
                else
                    next_state<=wait_4;
                end if;
         end case;
  end process;

--With current_state select 
    --p_fc_next<=(others=>'0') when idle,
                --p_fc         when wait_0 | wait_00 | wait_1 | wait_2 | wait_3 | wait_4,
                --std_logic_vector(resize(shift_right(signed(h_t)*signed(wfc),0)+signed(temp_fc),FC_WL)) when others;


fc_out<=p_fc(FC_WL-FC_FL+11 downto FC_FL-6);
addr_fc_out <= addr_fc;

fc_result : FF
  generic map(N => FC_WL)
  port map(
          D  => p_fc_next,       
          Q  => p_fc,
          clk => clk,
          reset => reset
          );
addr_fc_ff : FF
  generic map(N => 6)
  port map(
          D  => addr_fc_next,
          Q  => addr_fc,
          clk => clk,
          reset => reset
          );
ht_in_ff : FF
  generic map(N => 16)
  port map(
          D  => h_t_next,
          Q  => h_t,
          clk => clk,
          reset => reset
          );
weight_fc_ff : FF
  generic map(N => 32)
  port map(
          D  => weight_fc_next,
          Q  => weight_fc,
          clk => clk,
          reset => reset
          );
end Behavioral;

