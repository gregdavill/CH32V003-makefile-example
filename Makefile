TARGET_EXEC ?= example.elf

AS := riscv-none-embed-gcc
CC := riscv-none-embed-gcc
CXX := riscv-none-embed-g++
SIZE := riscv-none-embed-size

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src ./vendor/Core ./vendor/Debug ./vendor/Peripheral ./vendor/Startup ./vendor/User

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.S)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

FLAGS ?= -march=rv32ec -mabi=ilp32e -Os -ffunction-sections -fdata-sections -Wall -g
ASFLAGS ?= $(FLAGS) -x assembler $(INC_FLAGS) -MMD -MP
CPPFLAGS ?=  $(FLAGS) $(INC_FLAGS) -std=gnu99 -MMD -MP
LDFLAGS ?= $(FLAGS) -T ./vendor/Ld/Link.ld -nostartfiles -Xlinker --gc-sections -Wl,-Map,"$(BUILD_DIR)/$(TARGET_EXEC:.%=.map)" --specs=nano.specs --specs=nosys.specs

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
