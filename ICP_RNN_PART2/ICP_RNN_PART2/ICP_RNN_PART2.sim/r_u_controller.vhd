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

entity r_u_controller is 
  generic(MED_WL:integer:=24;
          MED_FL:integer:=13
          );
  Port (
        clk  : in std_logic; 
        reset: in std_logic;
        GRU_en: in std_logic;
        input_done_g  : in std_logic;
        h_prev_done_g : in std_logic;
        op_done_g     : in std_logic;
        input1      : in std_logic_vector(31 downto 0);
        input2      : in std_logic_vector(31 downto 0);
        input3      : in std_logic_vector(31 downto 0);
        input4      : in std_logic_vector(31 downto 0);
        weight_u1   : in std_logic_vector(31 downto 0);
        weight_u2   : in std_logic_vector(31 downto 0);
        weight_r1   : in std_logic_vector(31 downto 0);
        weight_r2   : in std_logic_vector(31 downto 0);
        bias        : in std_logic_vector(31 downto 0);
        output_u    : out std_logic_vector(15 downto 0);--10-bit for integer, 6-bit for fractional
        output_r    : out std_logic_vector(15 downto 0)  --10-bit for integer, 6-bit for fractional
        );
end r_u_controller;

architecture Behavioral of r_u_controller is
------------------alias-------------------------------------------------
alias x1 is input1(31 downto 16);
alias x2 is input1(15 downto 0);
alias x3 is input2(31 downto 16);
alias x4 is input2(15 downto 0);
alias x5 is input3(31 downto 16);
alias x6 is input3(15 downto 0);
alias x7 is input4(31 downto 16);
alias x8 is input4(15 downto 0);
alias wu1 is weight_u1(31 downto 24);
alias wu2 is weight_u1(23 downto 16);
alias wu3 is weight_u1(15 downto 8);
alias wu4 is weight_u1(7 downto 0);
alias wu5 is weight_u2(31 downto 24);
alias wu6 is weight_u2(23 downto 16);
alias wu7 is weight_u2(15 downto 8);
alias wu8 is weight_u2(7 downto 0);
alias wr1 is weight_r1(31 downto 24);
alias wr2 is weight_r1(23 downto 16);
alias wr3 is weight_r1(15 downto 8);
alias wr4 is weight_r1(7 downto 0);
alias wr5 is weight_r2(31 downto 24);
alias wr6 is weight_r2(23 downto 16);
alias wr7 is weight_r2(15 downto 8);
alias wr8 is weight_r2(7 downto 0);
alias bu:std_logic_vector(7 downto 0) is bias(31 downto 24);
alias br:std_logic_vector(7 downto 0) is bias(23 downto 16);
------------------signals-------------------------------------------------
type state_type is (idle, first_op, op);
signal current_state, next_state: state_type;
signal temp_u, temp_r: std_logic_vector(MED_WL-1 downto 0);
signal p_u, p_u_next: std_logic_vector(MED_WL-1 downto 0);
signal p_r, p_r_next: std_logic_vector(MED_WL-1 downto 0);

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
    
    process(current_state,GRU_en,input_done_g, h_prev_done_g,op_done_g, p_u, p_r,bu,br)
    begin
        temp_u<=(others=>'0');
        temp_r<=(others=>'0');
        next_state<=current_state;
        case current_state is 
            when idle=>
                if GRU_en='1' then
                    next_state<=first_op;
                else
                    next_state<=idle;
                end if;
            when first_op=>
            if bu(7)='0' then 
                temp_u<=std_logic_vector(to_signed(0,MED_WL-MED_FL-1)) & bu & std_logic_vector(to_unsigned(0,MED_FL-7));
            else 
                temp_u<=std_logic_vector(to_signed(-1,MED_WL-MED_FL-1)) & bu & std_logic_vector(to_unsigned(0,MED_FL-7));
            end if;
            if br(7)='0' then 
                temp_r<=std_logic_vector(to_signed(0,MED_WL-MED_FL-1)) & br & std_logic_vector(to_unsigned(0,MED_FL-7));
            else 
                temp_r<=std_logic_vector(to_signed(-1,MED_WL-MED_FL-1)) & br & std_logic_vector(to_unsigned(0,MED_FL-7));
            end if;
                next_state<=op;
            when op=>
                temp_u<=p_u;
                temp_r<=p_r;
                    if h_prev_done_g='1' then
                        if op_done_g='1' then
                            next_state<=idle;
                        else 
                            next_state<=first_op;
                        end if;
                    else
                        next_state<=op;
                    end if;
                
         end case;
     end process;

u_result : FF
  generic map(N => MED_WL)
  port map(
          D  => p_u_next,       
          Q  => p_u,
          clk => clk,
          reset => reset
          );
r_result : FF
  generic map(N => MED_WL)
  port map(
          D  => p_r_next,       
          Q  => p_r,
          clk => clk,
          reset => reset
          );
--next-state logic
With current_state select
    p_u_next<=(others=>'0') when idle,
              std_logic_vector(resize(shift_right(signed(x1)*signed(wu1)+signed(x2)*signed(wu2)+signed(x3)*signed(wu3)+signed(x4)*signed(wu4)+signed(x5)*signed(wu5)+signed(x6)*signed(wu6)+signed(x7)*signed(wu7)+signed(x8)*signed(wu8),20-MED_FL)+signed(temp_u),MED_WL)) when others; 
With current_state select
    p_r_next<=(others=>'0') when idle,
              std_logic_vector(resize(shift_right(signed(x1)*signed(wr1)+signed(x2)*signed(wr2)+signed(x3)*signed(wr3)+signed(x4)*signed(wr4)+signed(x5)*signed(wr5)+signed(x6)*signed(wr6)+signed(x7)*signed(wr7)+signed(x8)*signed(wr8),20-MED_FL)+signed(temp_r),MED_WL)) when others; 

--output logic
output_u<=p_u(MED_WL-MED_FL+11 downto MED_FL-6);

output_r<=p_r(MED_WL-MED_FL+11 downto MED_FL-6);

end Behavioral;
