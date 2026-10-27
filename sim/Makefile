TEST = apb_wr_rd_test
COV  = -cm line+cond+fsm+tgl+assert

compile:
	vcs -sverilog -f build.flist \
		-ntb_opts uvm-1.2 \
		-full64 \
		-debug_all \
		$(COV)

sim:
	./simv +UVM_TESTNAME=$(TEST) $(COV) -cm_name $(TEST)

run: compile sim

wr_rd:
	$(MAKE) run TEST=apb_wr_rd_test

boundary:
	$(MAKE) run TEST=apb_boundary_test

b2b:
	$(MAKE) run TEST=apb_b2b_test

strobe:
	$(MAKE) run TEST=apb_strobe_test

error:
	$(MAKE) run TEST=apb_error_test

random:
	$(MAKE) run TEST=apb_random_test

stress:
	$(MAKE) run TEST=apb_stress_test

# Saare tests ek ke baad ek (compile sirf ek baar)
all: compile
	$(MAKE) sim TEST=apb_wr_rd_test
	$(MAKE) sim TEST=apb_boundary_test
	$(MAKE) sim TEST=apb_b2b_test
	$(MAKE) sim TEST=apb_strobe_test
	$(MAKE) sim TEST=apb_error_test
	$(MAKE) sim TEST=apb_random_test
	$(MAKE) sim TEST=apb_stress_test

# Waveform (last chali hui test ki waveform.vpd)
wave:
	dve -full64 -vpd waveform.vpd &

# Coverage report (simv.vdb ke saare tests merge hoke)
cov:
	urg -full64 -dir simv.vdb -report coverage_report
	@echo "Report: coverage_report/dashboard.html"

# Coverage GUI
cov_gui:
	dve -full64 -cov -dir simv.vdb &

clean:
	rm -rf simv simv.daidir csrc ucli.key vc_hdrs.h DVEfiles \
		*.vpd *.vdb *.vcd coverage_report urgReport

.PHONY: compile sim run wr_rd boundary b2b strobe error random stress all wave cov cov_gui clean