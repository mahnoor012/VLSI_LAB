library ieee;
use ieee.std_logic_1164.all;

entity gc_acc_tb is
end gc_acc_tb;

architecture sim of gc_acc_tb is
    component gc_acc port (
        clk, reset, we : in std_logic;
        d0,d1,d2,d3,d4,d5,d6,d7 : in std_logic;
        q0,q1,q2,q3,q4,q5,q6,q7 : out std_logic;
        z : out std_logic);
    end component;

    signal clk, reset, we : std_logic := '0';
    signal d0,d1,d2,d3,d4,d5,d6,d7 : std_logic := '0';
    signal q0,q1,q2,q3,q4,q5,q6,q7 : std_logic;
    signal z : std_logic;

    function hex4 (v : std_logic_vector(3 downto 0)) return character is
    begin
        case v is
            when "0000" => return '0'; when "0001" => return '1';
            when "0010" => return '2'; when "0011" => return '3';
            when "0100" => return '4'; when "0101" => return '5';
            when "0110" => return '6'; when "0111" => return '7';
            when "1000" => return '8'; when "1001" => return '9';
            when "1010" => return 'A'; when "1011" => return 'B';
            when "1100" => return 'C'; when "1101" => return 'D';
            when "1110" => return 'E'; when "1111" => return 'F';
            when others => return 'X';
        end case;
    end function;

    function hex8 (v : std_logic_vector(7 downto 0)) return string is
    begin
        return "0x" & hex4(v(7 downto 4)) & hex4(v(3 downto 0));
    end function;
begin
    DUT : gc_acc port map (clk, reset, we,
        d0,d1,d2,d3,d4,d5,d6,d7,
        q0,q1,q2,q3,q4,q5,q6,q7, z);

    -- clock: rising edges at 5, 15, 25 ... ns
    clk_gen : process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    stim : process
        variable errors : integer := 0;

        procedure step (name : string; rst, we_v : std_logic;
                        d_v, exp_q : std_logic_vector(7 downto 0); exp_z : std_logic) is
            variable q_v : std_logic_vector(7 downto 0);
        begin
            reset <= rst; we <= we_v;
            d0 <= d_v(0); d1 <= d_v(1); d2 <= d_v(2); d3 <= d_v(3);
            d4 <= d_v(4); d5 <= d_v(5); d6 <= d_v(6); d7 <= d_v(7);
            wait until rising_edge(clk);
            wait for 2 ns;

            q_v := q7 & q6 & q5 & q4 & q3 & q2 & q1 & q0;
            if q_v = exp_q and z = exp_z then
                report "PASS  " & name & "  ACC=" & hex8(q_v) & "  Z=" & std_logic'image(z);
            else
                errors := errors + 1;
                report "FAIL  " & name & "  got ACC=" & hex8(q_v) & " Z=" & std_logic'image(z)
                       & "  expected ACC=" & hex8(exp_q) & " Z=" & std_logic'image(exp_z) severity error;
            end if;
        end procedure;
    begin
        --         name            RESET we   D          exp ACC     exp Z
        step("reset            ", '1', '0', x"00", x"00", '1');
        step("load 0xF3        ", '0', '1', x"F3", x"F3", '0');
        step("hold (we = 0)    ", '0', '0', x"AA", x"F3", '0');   -- D changes, ACC must not
        step("load 0x00 -> Z=1 ", '0', '1', x"00", x"00", '1');
        step("load 0x40        ", '0', '1', x"40", x"40", '0');
        step("hold, D = 0x00   ", '0', '0', x"00", x"40", '0');   -- Z must stay 0
        step("reset priority   ", '1', '1', x"55", x"00", '1');   -- RESET beats the load
        step("load 0x00 again  ", '0', '1', x"00", x"00", '1');
        step("load 0x10        ", '0', '1', x"10", x"10", '0');

        if errors = 0 then
            report "ACC/Z: ALL TESTS PASSED" severity note;
        else
            report integer'image(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process;
end sim;