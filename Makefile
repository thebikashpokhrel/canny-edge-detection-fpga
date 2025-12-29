# Compiler and simulator
IVERILOG = iverilog
VVP     = vvp

# Source and testbench
SRC = src/gaussian_blur.v
TB  = testbench/tb_gaussian_blur.v

# Simulation folder
SIMDIR = sim
OUT   = $(SIMDIR)/sim_gaussian_blur

all: gaussian

gaussian:
	mkdir -p $(SIMDIR)
	$(IVERILOG) -o $(OUT) $(TB) $(SRC)
	$(VVP) $(OUT)

clean:
	rm -rf $(SIMDIR)/*
