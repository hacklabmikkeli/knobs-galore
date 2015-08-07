--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity input_buffer is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;KEYS_IN:       in  std_logic_vector(4 downto 0)
            ;KEYS_PROBE:    out std_logic_vector(7 downto 0)
            ;KEYS_OUT:      out std_logic_vector(36 downto 0)
            );
end entity;

architecture input_buffer_impl of input_buffer is
    signal key_buf: std_logic_vector(36 downto 0) := (others => '0');
    signal probe_clock: unsigned(2 downto 0) := (others => '0');
    signal is_probing: std_logic := '1';


begin

    with probe_clock select KEYS_PROBE <=
        "1ZZZZZZZ" when "000",
        "Z1ZZZZZZ" when "001",
        "ZZ1ZZZZZ" when "010",
        "ZZZ1ZZZZ" when "011",
        "ZZZZ1ZZZ" when "100",
        "ZZZZZ1ZZ" when "101",
        "ZZZZZZ1Z" when "110",
        "ZZZZZZZ1" when "111",
        "ZZZZZZZZ" when others;

    process(CLK)
    begin
        if EN = '1' and rising_edge(CLK) then
            if is_probing = '1' then
                if probe_clock < 7 then
                    probe_clock <= probe_clock + 1;
                else
                    probe_clock <= (others => '0');
                end if;

                is_probing <= '0';
            else
                for j in 7 downto 0 loop
                    for i in 4 downto 0 loop
                        if to_integer(probe_clock) = j then
                            if KEYS_IN(i) = '1' then
                                KEYS_OUT(i * 8 + j) <= '1';
                            else
                                KEYS_OUT(i * 8 + j) <= '0';
                            end if;
                        end if;
                    end loop;
                end loop;

                is_probing <= '1';
            end if;
        end if;
    end process;
end architecture;
