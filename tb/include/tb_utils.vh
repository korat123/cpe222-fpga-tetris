// tb_utils.vh — shared testbench helpers. Requires `integer errors = 0;` in the testbench.
`ifndef TB_UTILS_VH
`define TB_UTILS_VH
// `CHECK(cond, "msg") : count a failure and print it when cond is false
`define CHECK(cond, msg) if (!(cond)) begin errors = errors + 1; $display("CHECK FAILED at %0t: %s", $time, msg); end
// `TB_FINISH("tb_name") : print the single PASS/FAIL line CI looks for, then stop
`define TB_FINISH(name) begin if (errors == 0) $display("TB_PASS %s", name); else $display("TB_FAIL %s: %0d check(s) failed", name, errors); $finish; end
`endif
