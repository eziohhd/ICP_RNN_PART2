----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/04/16 21:39:29
-- Design Name: 
-- Module Name: sigmoid - Behavioral
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
--use ieee.std_logic_signed.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sigmoid is
--    generic(MED_WL:integer:=24;
--            MED_FL:integer:=13;
--            SIG_WL:integer:=1;
--            SIG_FL:integer:=7
--            );
    port(
         clk  : in std_logic; 
         reset: in std_logic;
         h_prev_done_g : in std_logic;
--         u_in        : in std_logic_vector(MED_WL-1 downto 0);
--         r_in        : in std_logic_vector(MED_WL-1 downto 0); 
         u_in        : in std_logic_vector(15 downto 0);
         r_in        : in std_logic_vector(15 downto 0);
         r_u_valid   : out std_logic;       
--         u_t         : out std_logic_vector(SIG_WL-1 downto 0);
--         r_t         : out std_logic_vector(SIG_WL-1 downto 0)
         u_t         : out std_logic_vector(15 downto 0);
         r_t         : out std_logic_vector(15 downto 0)
         );
end sigmoid;

architecture Behavioral of sigmoid is
type state_type is (idle, sig);
signal current_state, next_state: state_type;
--signal temp_u, temp_r:  std_logic_vector(SIG_WL-1 downto 0);
signal temp_u, temp_r:  std_logic_vector(15 downto 0);
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
    
     process(current_state,h_prev_done_g,u_in,r_in)
    begin
        temp_u<=(others=>'0');
        temp_r<=(others=>'0');
        next_state<=current_state;
        case current_state is 
            when idle=>
                if h_prev_done_g='1' then
                    next_state<=sig;
                else
                    next_state<=idle;
                end if;
            when sig=>
--                if signed(u_in)<shift_left(to_signed(-5,4),MED_FL-1) then
--                    temp_u<=(others=>'0');
--                else if signed(u_in)>shift_left(to_signed(5,4),MED_FL-1) then
--                        temp_u<=std_logic_vector(shift_left(to_signed(1,SIG_WL-SIG_FL),SIG_FL)); 
--                     else 
--                        temp_u<=std_logic_vector(shift_right((signed(u_in)*shift_left(to_signed(13,5),MED_FL-6)+shift_left(to_signed(1,2),MED_FL-1)),MED_FL-SIG_FL));
--                     end if;
--                end if;
--                if signed(r_in)<shift_left(to_signed(-5,4),MED_FL-1) then
--                    temp_r<=(others=>'0');
--                else if signed(r_in)>shift_left(to_signed(5,4),MED_FL-1) then
--                        temp_r<=std_logic_vector(shift_left(to_signed(1,SIG_WL-SIG_FL),SIG_FL)); 
--                     else 
--                        temp_r<=std_logic_vector(shift_right((signed(r_in)*shift_left(to_signed(13,5),MED_FL-6)+shift_left(to_signed(1,2),MED_FL-1)),MED_FL-SIG_FL));
--                     end if;
--                end if;
                if signed(u_in)<shift_left(to_signed(-5,16),5) then
                    temp_u<=(others=>'0');
                else if signed(u_in)>shift_left(to_signed(5,16),5) then
                        temp_u<=std_logic_vector(shift_left(to_signed(1,16),6)); 
                     else 
                        temp_u<=std_logic_vector(resize(shift_right(signed(u_in)*to_signed(13,16)+shift_left(to_signed(1,16),11),6),16));
                     end if;
                end if;
                 if signed(r_in)<shift_left(to_signed(-5,16),5) then
                    temp_r<=(others=>'0');
                else if signed(r_in)>shift_left(to_signed(5,16),5) then
                        temp_r<=std_logic_vector(shift_left(to_signed(1,16),6)); 
                     else 
                        temp_r<=std_logic_vector(resize(shift_right(signed(r_in)*to_signed(13,16)+shift_left(to_signed(1,16),11),6),16));
                     end if;
                end if;
                next_state<=idle;
         end case;
     end process;
--output_stage
r_u_valid<='1' when current_state=sig else
           '0';
u_t<=temp_u when current_state=sig else
     (others=>'0');
r_t<=temp_r when current_state=sig else
     (others=>'0');
end Behavioral;
