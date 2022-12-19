TARGET_EXEC ?= example.elf

TRIPLE := riscv-none-elf
AS := $(TRIPLE)-gcc
CC := $(TRIPLE)-gcc
CXX := $(TRIPLE)-g++
SIZE := $(TRIPLE)-size

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src ./vendor/Core ./vendor/Debug ./vendor/Peripheral ./vendor/Startup ./vendor/User

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.S)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

FLAGS ?= -march=rv32ec_zicsr -mabi=ilp32e -Os -ffunction-sections -fdata-sections -Wall -g -mcmodel=medany -mpreferred-stack-boundary=2 --specs=nano.specs 
ASFLAGS ?= $(FLAGS) -x assembler $(INC_FLAGS) -MMD -MP
CPPFLAGS ?=  $(FLAGS) $(INC_FLAGS) -std=gnu99 -MMD -MP
# Ugly hack, use non '_zicsr' march in the link command to select correct libgcc version
LDFLAGS ?= $(FLAGS) -march=rv32ec -T ./vendor/Ld/Link.ld -nostartfiles -Xlinker --gc-sections -Wl,-Map,"$(BUILD_DIR)/$(TARGET_EXEC:.%=.map)"

all: $(BUILD_DIR)/$(TARGET_EXEC)
	$(SIZE) $<

$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	@echo "LN $@"
	@$(CC) $(OBJS) -o $@ $(LDFLAGS)

# assembly
$(BUILD_DIR)/%.S.o: %.S
	@echo "AS $<"
	@$(MKDIR_P) $(dir $@)
	@$(CC) $(ASFLAGS) -c $< -o $@

# c source
$(BUILD_DIR)/%.c.o: %.c
	@echo "CC $<"
	@$(MKDIR_P) $(dir $@)
	@$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	@echo "CXX $<"
	@$(MKDIR_P) $(dir $@)
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@


.PHONY: clean

clean:
	$(RM) -r $(BUILD_DIR)

-include $(DEPS)

MKDIR_P ?= mkdir -p
