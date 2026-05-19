package com.laptopdb.backend.dto;

import java.math.BigDecimal;

import com.laptopdb.backend.entity.Cpu;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CpuResponse {

    private final Integer id;
    private final String brand;
    private final String series;
    private final String modelName;
    private final Integer coreCount;
    private final Integer threadCount;
    private final Integer cacheMb;
    private final BigDecimal baseClockGhz;
    private final BigDecimal boostClockGhz;

    public static CpuResponse from(Cpu cpu) {
        return CpuResponse.builder()
                .id(cpu.getId())
                .brand(cpu.getBrand())
                .series(cpu.getSeries())
                .modelName(cpu.getModelName())
                .coreCount(cpu.getCoreCount())
                .threadCount(cpu.getThreadCount())
                .cacheMb(cpu.getCacheMb())
                .baseClockGhz(cpu.getBaseClockGhz())
                .boostClockGhz(cpu.getBoostClockGhz())
                .build();
    }
}