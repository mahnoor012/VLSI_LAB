library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_pc_tb is
end gc_pc_tb;

architecture sim of gc_pc_tb is
    component gc_pc port (clk, reset : in std_logic; p0, p1, p2, p3 : out std_logic); end component;
    signal clk, reset : std_logic := '0';
    signal p0, p1, p2, p3 : std_logic;
begin
    DUT : gc_pc port map (clk, reset, p0, p1, p2, p3);

    -- clock: rising edges at 5, 15, 25 ... ns
    clk_gen : process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    stim : process
        variable errors : integer := 0;

        procedure tick (rst : std_logic; exp_pc : integer) is
            variable pc_v : std_logic_vector(3 downto 0);
        begin
            reset <= rst;
            wait until rising_edge(clk);
            wait for 2 ns;
            pc_v := p3 & p2 & p1 & p0;
            if to_integer(unsigned(pc_v)) = exp_pc then
                report "PASS  RESET=" & std_logic'image(rst) & "  PC=" & integer'image(exp_pc);
            else
                errors := errors + 1;
                report "FAIL  RESET=" & std_logic'image(rst) & "  got PC="
                       & integer'image(to_integer(unsigned(pc_v)))
                       & "  expected " & integer'image(exp_pc) severity error;
            end if;
        end procedure;
    begin
        tick('1', 0);                       -- reset
        for n in 1 to 15 loop               -- counts 1 .. 15
            tick('0', n);
        end loop;
        tick('0', 0);                       -- 15 + 1 wraps to 0
        tick('0', 1);
        tick('0', 2);
        tick('0', 3);
        tick('1', 0);                       -- RESET in the middle of counting
        tick('0', 1);                       -- counting restarts

        if errors = 0 then
            report "PC: ALL TESTS PASSED" severity note;
        else
            report integer'image(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process;
end sim;