library ieee;
use ieee.std_logic_1164.all;

entity cpu8_gate_tb is
end cpu8_gate_tb;

architecture sim of cpu8_gate_tb is
    component cpu8_gate port (
        clk, reset              : in  std_logic;
        q0,q1,q2,q3,q4,q5,q6,q7 : out std_logic;
        z                       : out std_logic;
        pc0,pc1,pc2,pc3         : out std_logic);
    end component;

    signal clk, reset : std_logic := '0';
    signal q0,q1,q2,q3,q4,q5,q6,q7 : std_logic;
    signal z : std_logic;
    signal pc0,pc1,pc2,pc3 : std_logic;

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
begin
    DUT : cpu8_gate port map (clk, reset, q0,q1,q2,q3,q4,q5,q6,q7, z, pc0,pc1,pc2,pc3);

    -- clock: 10 ns period, rising edges at 5, 15, 25 ... ns
    clk_gen : process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    stim : process
        variable errors : integer := 0;

        procedure check (cyc : integer; name : string;
                         exp_acc : std_logic_vector(7 downto 0);
                         exp_z   : std_logic;
                         exp_pc  : std_logic_vector(3 downto 0)) is
            variable q_v  : std_logic_vector(7 downto 0);
            variable pc_v : std_logic_vector(3 downto 0);
        begin
            wait until rising_edge(clk);
            wait for 2 ns;                      -- let outputs settle
            q_v  := q7 & q6 & q5 & q4 & q3 & q2 & q1 & q0;
            pc_v := pc3 & pc2 & pc1 & pc0;
            if q_v = exp_acc and z = exp_z and pc_v = exp_pc then
                report "PASS cycle " & integer'image(cyc) & "  " & name
                       & "  ACC=0x" & hex4(q_v(7 downto 4)) & hex4(q_v(3 downto 0))
                       & "  Z=" & std_logic'image(z) & "  PC=" & hex4(pc_v);
            else
                errors := errors + 1;
                report "FAIL cycle " & integer'image(cyc) & "  " & name
                       & "  got ACC=0x" & hex4(q_v(7 downto 4)) & hex4(q_v(3 downto 0))
                       & " Z=" & std_logic'image(z) & " PC=" & hex4(pc_v)
                       & "  expected ACC=0x" & hex4(exp_acc(7 downto 4)) & hex4(exp_acc(3 downto 0))
                       & " Z=" & std_logic'image(exp_z) & " PC=" & hex4(exp_pc) severity error;
            end if;
        end procedure;
    begin
        reset <= '1';
        check(0, "RESET     ", x"00", '1', x"0");
        reset <= '0';

        check(1, "LDI 0xF3  ", x"F3", '0', x"1");
        check(2, "AND 0x3C  ", x"30", '0', x"2");
        check(3, "XOR 0x11  ", x"21", '0', x"3");
        check(4, "SHR       ", x"10", '0', x"4");
        check(5, "ADD 0x30  ", x"40", '0', x"5");
        check(6, "XOR 0x40  ", x"00", '1', x"6");
        check(7, "NOP       ", x"00", '1', x"7");   -- ROM is 000 here, nothing changes

        if errors = 0 then
            report "ALL TESTS PASSED" severity note;
        else
            report integer'image(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process;
end sim;