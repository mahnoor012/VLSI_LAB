library ieee;
use ieee.std_logic_1164.all;

---------------- Basic gates ----------------
entity and_gate is port (a, b : in std_logic; y : out std_logic); end and_gate;
architecture rtl of and_gate is begin y <= a and b; end rtl;

library ieee; use ieee.std_logic_1164.all;
entity or_gate is port (a, b : in std_logic; y : out std_logic); end or_gate;
architecture rtl of or_gate is begin y <= a or b; end rtl;

library ieee; use ieee.std_logic_1164.all;
entity not_gate is port (a : in std_logic; y : out std_logic); end not_gate;
architecture rtl of not_gate is begin y <= not a; end rtl;

library ieee; use ieee.std_logic_1164.all;
entity xor_gate is port (a, b : in std_logic; y : out std_logic); end xor_gate;
architecture rtl of xor_gate is begin y <= a xor b; end rtl;

library ieee; use ieee.std_logic_1164.all;
entity xnor_gate is port (a, b : in std_logic; y : out std_logic); end xnor_gate;
architecture rtl of xnor_gate is begin y <= a xnor b; end rtl;

---------------- Full adder ----------------
library ieee; use ieee.std_logic_1164.all;
entity full_adder is
    port (a, b, cin : in std_logic; sum, cout : out std_logic);
end full_adder;
architecture rtl of full_adder is
begin
    sum  <= a xor b xor cin;
    cout <= (a and b) or (cin and (a xor b));
end rtl;

---------------- 1-bit ALU slice ----------------
library ieee; use ieee.std_logic_1164.all;
entity alu_slice is
    port (
        a, b, cin : in  std_logic;
        is_and, is_or, is_not, is_xor, is_xnor : in std_logic;
        is_add, is_sub, is_dec, is_arith       : in std_logic;
        y, cout   : out std_logic
    );
end alu_slice;

architecture struct of alu_slice is
    component and_gate  port (a, b : in std_logic; y : out std_logic); end component;
    component or_gate   port (a, b : in std_logic; y : out std_logic); end component;
    component not_gate  port (a : in std_logic; y : out std_logic);    end component;
    component xor_gate  port (a, b : in std_logic; y : out std_logic); end component;
    component xnor_gate port (a, b : in std_logic; y : out std_logic); end component;
    component full_adder port (a, b, cin : in std_logic; sum, cout : out std_logic); end component;

    signal w_and, w_or, w_not, w_xor, w_xnor, w_sum, bx : std_logic;
begin
    -- logic unit
    AND_U  : and_gate  port map (a, b, w_and);
    OR_U   : or_gate   port map (a, b, w_or);
    NOT_U  : not_gate  port map (a, w_not);
    XOR_U  : xor_gate  port map (a, b, w_xor);
    XNOR_U : xnor_gate port map (a, b, w_xnor);

    -- arithmetic unit: B input select (ADD: b, SUB: not b, DEC: 1, INC: 0)
    bx <= (is_add and b) or (is_sub and not b) or is_dec;
    FA_U : full_adder port map (a, bx, cin, w_sum, cout);

    -- output select
    y <= (is_and  and w_and)  or (is_or  and w_or)  or (is_not and w_not)
      or (is_xor  and w_xor)  or (is_xnor and w_xnor) or (is_arith and w_sum);
end struct;

---------------- Top: 8-bit ALU ----------------
library ieee; use ieee.std_logic_1164.all;
entity alu8 is
    port (
        a0,a1,a2,a3,a4,a5,a6,a7 : in  std_logic;
        b0,b1,b2,b3,b4,b5,b6,b7 : in  std_logic;
        op3,op2,op1,op0         : in  std_logic;
        y0,y1,y2,y3,y4,y5,y6,y7 : out std_logic;
        cout, zero              : out std_logic
    );
end alu8;

architecture struct of alu8 is
    component alu_slice port (
        a, b, cin : in std_logic;
        is_and, is_or, is_not, is_xor, is_xnor : in std_logic;
        is_add, is_sub, is_dec, is_arith       : in std_logic;
        y, cout   : out std_logic);
    end component;

    signal is_and, is_or, is_not, is_xor, is_xnor : std_logic;
    signal is_inc, is_dec, is_add, is_sub, is_arith : std_logic;
    signal c0,c1,c2,c3,c4,c5,c6,c7,c8 : std_logic;
    signal r0,r1,r2,r3,r4,r5,r6,r7    : std_logic;
begin
    -- opcode decode
    is_and  <= not op3 and not op2 and not op1 and not op0; -- 0000
    is_or   <= not op3 and not op2 and not op1 and     op0; -- 0001
    is_not  <= not op3 and not op2 and     op1 and not op0; -- 0010
    is_xor  <= not op3 and not op2 and     op1 and     op0; -- 0011
    is_xnor <= not op3 and     op2 and not op1 and not op0; -- 0100
    is_inc  <= not op3 and     op2 and not op1 and     op0; -- 0101
    is_dec  <= not op3 and     op2 and     op1 and not op0; -- 0110
    is_add  <= not op3 and     op2 and     op1 and     op0; -- 0111
    is_sub  <=     op3 and not op2 and not op1 and not op0; -- 1000
    is_arith <= is_inc or is_dec or is_add or is_sub;

    c0 <= is_sub or is_inc;  -- carry-in

    S0 : alu_slice port map (a0,b0,c0, is_and,is_or,is_not,is_xor,is_xnor, is_add,is_sub,is_dec,is_arith, r0,c1);
    S1 : alu_slice port map (a1,b1,c1, is_and,is_or,is_not,is_xor,is_xnor, is_add,is_sub,is_dec,is_arith, r1,c2);
    S2 : alu_slice port map (a2,b2,c2, is_and,is_or,is_not,is_xor,is_xnor, is_add,is_sub,is_dec,is_arith, r2,c3);
    S3 : alu_slice port map (a3,b3,c3, is_and,is_or,is_not,is_xor,is_xnor, is_add,is_sub,is_dec,is_arith, r3,c4);
    S4 : alu_slice port map (a4,b4,c4, is_and,is_or,is_not,is_xor,is_xnor, is_add,is_sub,is_dec,is_arith, r4,c5);
    S5 : alu_slice port map (a5,b5,c5, is_and,is_or,is_not,is_xor,is_xnor, is_add,is_sub,is_dec,is_arith, r5,c6);
    S6 : alu_slice port map (a6,b6,c6, is_and,is_or,is_not,is_xor,is_xnor, is_add,is_sub,is_dec,is_arith, r6,c7);
    S7 : alu_slice port map (a7,b7,c7, is_and,is_or,is_not,is_xor,is_xnor, is_add,is_sub,is_dec,is_arith, r7,c8);

    y0 <= r0; y1 <= r1; y2 <= r2; y3 <= r3;
    y4 <= r4; y5 <= r5; y6 <= r6; y7 <= r7;

    -- flags: carry for ADD/INC, borrow for SUB/DEC
    cout <= ((is_add or is_inc) and c8) or ((is_sub or is_dec) and not c8);
    zero <= not (r0 or r1 or r2 or r3 or r4 or r5 or r6 or r7);
end struct;