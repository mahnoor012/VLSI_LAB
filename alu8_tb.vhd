library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu8_tb is
end alu8_tb;

architecture sim of alu8_tb is
    component alu8 port (
        a0,a1,a2,a3,a4,a5,a6,a7 : in  std_logic;
        b0,b1,b2,b3,b4,b5,b6,b7 : in  std_logic;
        op3,op2,op1,op0         : in  std_logic;
        y0,y1,y2,y3,y4,y5,y6,y7 : out std_logic;
        cout, zero              : out std_logic);
    end component;

    signal a0,a1,a2,a3,a4,a5,a6,a7 : std_logic := '0';
    signal b0,b1,b2,b3,b4,b5,b6,b7 : std_logic := '0';
    signal op3,op2,op1,op0         : std_logic := '0';
    signal y0,y1,y2,y3,y4,y5,y6,y7 : std_logic;
    signal cout, zero              : std_logic;
begin
    DUT : alu8 port map (
        a0,a1,a2,a3,a4,a5,a6,a7,
        b0,b1,b2,b3,b4,b5,b6,b7,
        op3,op2,op1,op0,
        y0,y1,y2,y3,y4,y5,y6,y7,
        cout, zero);

    stim : process
        variable errors : integer := 0;

        -- a_v, b_v : input, op_v : opcode, exp_y : expected result, exp_c : expected cout (0/1)
        procedure check (name : string; a_v, b_v, op_v, exp_y, exp_c : integer) is
            variable av : unsigned(7 downto 0) := to_unsigned(a_v, 8);
            variable bv : unsigned(7 downto 0) := to_unsigned(b_v, 8);
            variable ov : unsigned(3 downto 0) := to_unsigned(op_v, 4);
            variable yv : unsigned(7 downto 0);
            variable exp_z : std_logic;
            variable exp_cs : std_logic;
        begin
            a0 <= av(0); a1 <= av(1); a2 <= av(2); a3 <= av(3);
            a4 <= av(4); a5 <= av(5); a6 <= av(6); a7 <= av(7);
            b0 <= bv(0); b1 <= bv(1); b2 <= bv(2); b3 <= bv(3);
            b4 <= bv(4); b5 <= bv(5); b6 <= bv(6); b7 <= bv(7);
            op0 <= ov(0); op1 <= ov(1); op2 <= ov(2); op3 <= ov(3);
            wait for 10 ns;

            yv := unsigned(std_logic_vector'(y7 & y6 & y5 & y4 & y3 & y2 & y1 & y0));

            if exp_y = 0 then exp_z := '1'; else exp_z := '0'; end if;
            if exp_c = 1 then exp_cs := '1'; else exp_cs := '0'; end if;

            if to_integer(yv) = exp_y and cout = exp_cs and zero = exp_z then
                report "PASS  " & name & "  A=" & integer'image(a_v) & " B=" & integer'image(b_v)
                       & " Y=" & integer'image(to_integer(yv));
            else
                errors := errors + 1;
                report "FAIL  " & name & "  A=" & integer'image(a_v) & " B=" & integer'image(b_v)
                       & " got Y=" & integer'image(to_integer(yv))
                       & " (expected " & integer'image(exp_y) & ")"
                       & " cout=" & std_logic'image(cout)
                       & " zero=" & std_logic'image(zero)
                       severity error;
            end if;
        end procedure;
    begin
        --      name     A    B   op   Y    cout
        check("AND ",   12,  10,  0,   8,   0);
        check("OR  ",   12,  10,  1,  14,   0);
        check("NOT ",   15,   0,  2, 240,   0);
        check("XOR ",   12,  10,  3,   6,   0);
        check("XNOR",   12,  10,  4, 249,   0);

        check("INC ",    7,   0,  5,   8,   0);
        check("INC ",  255,   0,  5,   0,   1);   -- overflow
        check("DEC ",    8,   0,  6,   7,   0);
        check("DEC ",    0,   0,  6, 255,   1);   -- borrow

        check("ADD ",   15,   1,  7,  16,   0);
        check("ADD ",  255,   1,  7,   0,   1);   -- carry
        check("ADD ",  200, 100,  7,  44,   1);   -- 300 mod 256

        check("SUB ",    5,   3,  8,   2,   0);
        check("SUB ",    3,   5,  8, 254,   1);   -- borrow
        check("SUB ",   10,  10,  8,   0,   0);   -- zero result

        check("INVLD",   5,   3, 15,   0,   0);   -- unused opcode -> Y = 0

        if errors = 0 then
            report "ALL TESTS PASSED" severity note;
        else
            report integer'image(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process;
end sim;