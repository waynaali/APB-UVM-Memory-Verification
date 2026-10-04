TEST = apb_all_test

compile:
	vcs -sverilog -f build.flist \
		-ntb_opts uvm-1.2 \
		+UVM_TESTNAME=$(TEST) \
		-full64 \
		-debug_all

sim:
	./simv +UVM_TESTNAME=$(TEST)

run: compile sim

clean:
	rm -rf simv simv.daidir csrc ucli.key vc_hdrs.h DVEfiles \
		*.vpd *.vdb *.vcd

.PHONY: compile sim run clean