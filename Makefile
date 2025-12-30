# Compiler and simulator
IVERILOG = iverilog
VVP      = vvp

# Source files
GAUSSIAN_BLUR = src/gaussian_blur.v
SOBEL         = src/sobel_operator.v
NMS           = src/non_maxima_suppression.v

# Testbenches
TB_GAUSSIAN_BLUR = testbench/tb_gaussian_blur.v
TB_SOBEL_OPERATOR = testbench/tb_sobel_operator.v
TB_NMS = testbench/tb_non_maxima_suppression.v  

# Simulation folder
SIMDIR = sim

# Output binaries
OUT_GAUSSIAN_BLUR = $(SIMDIR)/sim_gaussian_blur
OUT_SOBEL_OPERATOR = $(SIMDIR)/sim_sobel_operator
OUT_NMS = $(SIMDIR)/sim_nms

# Default target
all: gaussian sobel nms

# Gaussian blur
gaussian:
	mkdir -p $(SIMDIR)
	$(IVERILOG) -o $(OUT_GAUSSIAN_BLUR) $(TB_GAUSSIAN_BLUR) $(GAUSSIAN_BLUR)
	$(VVP) $(OUT_GAUSSIAN_BLUR)

# Sobel operator
sobel:
	mkdir -p $(SIMDIR)
	$(IVERILOG) -o $(OUT_SOBEL_OPERATOR) $(TB_SOBEL_OPERATOR) $(SOBEL)
	$(VVP) $(OUT_SOBEL_OPERATOR)

# Non-Maximum Suppression
nms:
	mkdir -p $(SIMDIR)
	$(IVERILOG) -o $(OUT_NMS) $(TB_NMS) $(NMS)
	$(VVP) $(OUT_NMS)

# Clean simulation outputs
clean:
	rm -rf $(SIMDIR)/*
