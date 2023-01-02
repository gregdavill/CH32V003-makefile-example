TARGET_EXEC ?= example.elf

TRIPLE := riscv-none-elf
AS := $(TRIPLE)-gcc
CC := $(TRIPLE)-gcc
CXX := $(TRIPLE)-g++
DUMP := $(TRIPLE)-objdump
SIZE := $(TRIPLE)-size

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src \
			./vendor/Core ./vendor/Debug ./vendor/Peripheral ./vendor/Startup ./vendor/User 

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.S)
SRCS += ./libs/printf/printf.c

OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d) libs/printf
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

FLAGS ?= -march=rv32ec_zicsr -mabi=ilp32e -Os -ffunction-sections -fdata-sections -Wall  -g 
FLAGS += -DPRINTF_DISABLE_SUPPORT_FLOAT -DPRINTF_DISABLE_SUPPORT_EXPONENTIAL -DPRINTF_DISABLE_SUPPORT_LONG_LONG
ASFLAGS ?= $(FLAGS) -x assembler $(INC_FLAGS) -MMD -MP
CFLAGS ?=  $(FLAGS) $(INC_FLAGS) -std=gnu99 -MMD -MP
CXXFLAGS ?=  $(FLAGS) $(INC_FLAGS) -std=gnu99 -MMD -MP
# Ugly hack, use non '_zicsr' march in the link command to select correct libgcc version
LDFLAGS ?= $(FLAGS) -march=rv32ec -T ./vendor/Ld/Link.ld -nostartfiles -Xlinker --gc-sections -Wl,-Map,"$(BUILD_DIR)/$(TARGET_EXEC:.elf=.map)" --specs=nano.specs 

all: $(BUILD_DIR)/$(TARGET_EXEC) $(BUILD_DIR)/$(TARGET_EXEC:.elf=.lst)
	$(SIZE) $<

$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	@echo "LINK $@"
	@$(CC) $(LDFLAGS) -o $@ $(OBJS)

%.lst: %.elf
	@echo "DISASM $@"
	@$(DUMP) -DS $< > $@ 

# assembly
$(BUILD_DIR)/%.S.o: %.S
	@echo "AS $<"
	@$(MKDIR_P) $(dir $@)
	@$(AS) $(ASFLAGS) -c $< -o $@

# c source
$(BUILD_DIR)/%.c.o: %.c
	@echo "CC $<"
	@$(MKDIR_P) $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	@echo "CXX $<"
	@$(MKDIR_P) $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@


.PHONY: clean

clean:
	$(RM) -r $(BUILD_DIR)

-include $(DEPS)

MKDIR_P ?= mkdir -p
